import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:chack_chack/common/auth/auth_session_events.dart';
import 'package:chack_chack/common/auth/model/social_auth_models.dart';
import 'package:chack_chack/common/auth/server_token_manager.dart';
import 'package:chack_chack/common/auth/session/auth_session_store.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  test('returns a valid access token without refreshing', () async {
    final token = _jwt(
      role: 'OWNER',
      expiresAt: DateTime.now().add(const Duration(minutes: 30)),
    );
    final store = _MemoryAuthSessionStore(
      AuthSession(
        accessToken: token,
        refreshToken: 'refresh-1',
        deviceId: 'device-1',
      ),
    );
    final refreshClient = _FakeTokenRefreshClient(
      onRefresh: (_, _) => throw StateError('refresh should not be called'),
    );
    final manager = ServerTokenManager(
      store: store,
      refreshClient: refreshClient,
    );

    expect(await manager.resolveValidAccessToken(), token);
    expect(refreshClient.callCount, 0);
    expect(ServerTokenManager.roleFromToken(token), AuthMemberRole.owner);
  });

  test('refresh sends refreshToken and deviceId and rotates tokens', () async {
    final expiredAccessToken = _jwt(
      role: 'OWNER',
      expiresAt: DateTime.now().subtract(const Duration(minutes: 1)),
    );
    final validOwnerAccessToken = _jwt(
      role: 'OWNER',
      expiresAt: DateTime.now().add(const Duration(minutes: 30)),
    );
    final store = _MemoryAuthSessionStore(
      AuthSession(
        accessToken: expiredAccessToken,
        refreshToken: 'refresh-1',
        deviceId: 'device-1',
      ),
    );
    final refreshClient = _FakeTokenRefreshClient(
      onRefresh: (refreshToken, deviceId) async {
        expect(refreshToken, 'refresh-1');
        expect(deviceId, 'device-1');
        return RefreshTokens(
          accessToken: validOwnerAccessToken,
          refreshToken: 'refresh-2',
        );
      },
    );
    final manager = ServerTokenManager(
      store: store,
      refreshClient: refreshClient,
    );

    expect(await manager.resolveValidAccessToken(), validOwnerAccessToken);
    expect((await store.read())?.refreshToken, 'refresh-2');
    expect((await store.read())?.deviceId, 'device-1');
  });

  test('rejected refresh clears auth session only', () async {
    SharedPreferences.setMockInitialValues({'selectedWorkPlaceId': 7});
    final store = _MemoryAuthSessionStore(
      AuthSession(
        accessToken: _jwt(
          role: 'WORKER',
          expiresAt: DateTime.now().subtract(const Duration(minutes: 1)),
        ),
        refreshToken: 'invalid-refresh',
        deviceId: 'device-1',
      ),
    );
    final manager = ServerTokenManager(
      store: store,
      refreshClient: _RejectedTokenRefreshClient(),
    );

    expect(await manager.resolveValidAccessToken(), isNull);
    expect(await store.read(), isNull);
    final preferences = await SharedPreferences.getInstance();
    expect(preferences.getInt('selectedWorkPlaceId'), 7);
  });

  test('invalid token has no role and is expired', () {
    expect(ServerTokenManager.roleFromToken('invalid'), isNull);
    expect(ServerTokenManager.isExpired('invalid'), isTrue);
  });

  test('transient refresh failure preserves the existing session', () async {
    final session = AuthSession(
      accessToken: _jwt(
        role: 'WORKER',
        expiresAt: DateTime.now().subtract(const Duration(minutes: 1)),
      ),
      refreshToken: 'refresh-1',
      deviceId: 'device-1',
    );
    final store = _MemoryAuthSessionStore(session);
    final manager = ServerTokenManager(
      store: store,
      refreshClient: _FakeTokenRefreshClient(
        onRefresh: (_, _) => throw DioException(
          requestOptions: RequestOptions(path: '/api/auth/token/refresh'),
          response: Response(
            requestOptions: RequestOptions(path: '/api/auth/token/refresh'),
            statusCode: 503,
          ),
        ),
      ),
    );

    await expectLater(
      manager.resolveValidAccessToken(),
      throwsA(isA<DioException>()),
    );
    expect(await store.read(), same(session));
  });

  test('rejected refresh clears the session and emits expiry once', () async {
    final store = _MemoryAuthSessionStore(
      AuthSession(
        accessToken: _jwt(
          role: 'WORKER',
          expiresAt: DateTime.now().subtract(const Duration(minutes: 1)),
        ),
        refreshToken: 'expired-refresh',
        deviceId: 'device-1',
      ),
    );
    final events = AuthSessionEvents();
    var expiryCount = 0;
    final subscription = events.onExpired.listen((_) => expiryCount += 1);
    addTearDown(subscription.cancel);
    addTearDown(events.close);
    final requestOptions = RequestOptions(path: '/api/auth/token/refresh');
    final manager = ServerTokenManager(
      store: store,
      refreshClient: _FakeTokenRefreshClient(
        onRefresh: (_, _) => throw DioException(
          requestOptions: requestOptions,
          response: Response(requestOptions: requestOptions, statusCode: 401),
        ),
      ),
      sessionEvents: events,
    );

    expect(await manager.resolveValidAccessToken(), isNull);
    expect(await store.read(), isNull);
    expect(expiryCount, 1);

    expect(await manager.resolveValidAccessToken(), isNull);
    expect(expiryCount, 1);
  });

  test(
    'authorized Dio refreshes a 401 and retries with rotated tokens',
    () async {
      final oldAccessToken = _jwt(
        role: 'WORKER',
        expiresAt: DateTime.now().add(const Duration(minutes: 30)),
      );
      final newAccessToken = _jwt(
        role: 'WORKER',
        expiresAt: DateTime.now().add(const Duration(hours: 1)),
      );
      final store = _MemoryAuthSessionStore(
        AuthSession(
          accessToken: oldAccessToken,
          refreshToken: 'refresh-1',
          deviceId: 'device-1',
        ),
      );
      final refreshClient = _FakeTokenRefreshClient(
        onRefresh: (refreshToken, deviceId) async {
          expect(refreshToken, 'refresh-1');
          expect(deviceId, 'device-1');
          return RefreshTokens(
            accessToken: newAccessToken,
            refreshToken: 'refresh-2',
          );
        },
      );
      final adapter = _SequenceAdapter((options, callCount) {
        if (callCount == 1) {
          expect(options.headers['Authorization'], 'Bearer $oldAccessToken');
          return ResponseBody.fromString(
            '{"code":"4002","message":"invalid access token"}',
            401,
            headers: {
              Headers.contentTypeHeader: ['application/json'],
            },
          );
        }
        expect(options.headers['Authorization'], 'Bearer $newAccessToken');
        return ResponseBody.fromString(
          '{"ok":true}',
          200,
          headers: {
            Headers.contentTypeHeader: ['application/json'],
          },
        );
      });
      final dio = Dio()..httpClientAdapter = adapter;
      final manager = ServerTokenManager(
        store: store,
        refreshClient: refreshClient,
      );

      final response = await manager
          .createAuthorizedDio(dio: dio)
          .get('/secure');

      expect(response.data, {'ok': true});
      expect(adapter.callCount, 2);
      expect(refreshClient.callCount, 1);
      expect((await store.read())?.accessToken, newAccessToken);
      expect((await store.read())?.refreshToken, 'refresh-2');
    },
  );

  test('concurrent expired-token requests share one refresh', () async {
    final refreshedAccessToken = _jwt(
      role: 'WORKER',
      expiresAt: DateTime.now().add(const Duration(minutes: 30)),
    );
    final store = _MemoryAuthSessionStore(
      AuthSession(
        accessToken: _jwt(
          role: 'WORKER',
          expiresAt: DateTime.now().subtract(const Duration(minutes: 1)),
        ),
        refreshToken: 'refresh-1',
        deviceId: 'device-1',
      ),
    );
    final refreshClient = _FakeTokenRefreshClient(
      onRefresh: (_, _) async {
        await Future<void>.delayed(const Duration(milliseconds: 10));
        return RefreshTokens(
          accessToken: refreshedAccessToken,
          refreshToken: 'refresh-2',
        );
      },
    );
    final manager = ServerTokenManager(
      store: store,
      refreshClient: refreshClient,
    );

    final tokens = await Future.wait(
      List.generate(10, (_) => manager.resolveValidAccessToken()),
    );

    expect(tokens, everyElement(refreshedAccessToken));
    expect(refreshClient.callCount, 1);
  });

  test('logout during refresh does not restore the cleared session', () async {
    final refreshStarted = Completer<void>();
    final refreshResult = Completer<RefreshTokens>();
    final store = _MemoryAuthSessionStore(
      AuthSession(
        accessToken: _jwt(
          role: 'WORKER',
          expiresAt: DateTime.now().subtract(const Duration(minutes: 1)),
        ),
        refreshToken: 'refresh-1',
        deviceId: 'device-1',
      ),
    );
    final manager = ServerTokenManager(
      store: store,
      refreshClient: _FakeTokenRefreshClient(
        onRefresh: (_, _) {
          refreshStarted.complete();
          return refreshResult.future;
        },
      ),
    );

    final refreshing = manager.resolveValidAccessToken();
    await refreshStarted.future;
    await manager.clearSession();
    refreshResult.complete(
      RefreshTokens(
        accessToken: _jwt(
          role: 'WORKER',
          expiresAt: DateTime.now().add(const Duration(minutes: 30)),
        ),
        refreshToken: 'refresh-2',
      ),
    );

    expect(await refreshing, isNull);
    expect(await store.read(), isNull);
  });

  test('new login during refresh is not overwritten by the old result', () async {
    final refreshStarted = Completer<void>();
    final refreshResult = Completer<RefreshTokens>();
    final store = _MemoryAuthSessionStore(
      AuthSession(
        accessToken: _jwt(
          role: 'WORKER',
          expiresAt: DateTime.now().subtract(const Duration(minutes: 1)),
        ),
        refreshToken: 'refresh-1',
        deviceId: 'device-1',
      ),
    );
    final generation = AuthSessionGeneration();
    final manager = ServerTokenManager(
      store: store,
      refreshClient: _FakeTokenRefreshClient(
        onRefresh: (_, _) {
          refreshStarted.complete();
          return refreshResult.future;
        },
      ),
      authGeneration: generation,
    );
    final loginManager = ServerTokenManager(
      store: store,
      authGeneration: generation,
    );
    final newSession = AuthSession(
      accessToken: _jwt(
        role: 'OWNER',
        expiresAt: DateTime.now().add(const Duration(minutes: 30)),
      ),
      refreshToken: 'other-account-refresh',
      deviceId: 'device-2',
    );

    final refreshing = manager.resolveValidAccessToken();
    await refreshStarted.future;
    await loginManager.saveSession(newSession);
    refreshResult.complete(
      RefreshTokens(
        accessToken: _jwt(
          role: 'WORKER',
          expiresAt: DateTime.now().add(const Duration(minutes: 30)),
        ),
        refreshToken: 'refresh-2',
      ),
    );

    expect(await refreshing, newSession.accessToken);
    expect(await store.read(), same(newSession));
  });

  test('late 401 from an old login is not retried as a new account', () async {
    final firstRequestStarted = Completer<void>();
    final firstResponse = Completer<ResponseBody>();
    final store = _MemoryAuthSessionStore(
      AuthSession(
        accessToken: _jwt(
          role: 'WORKER',
          expiresAt: DateTime.now().add(const Duration(minutes: 30)),
        ),
        refreshToken: 'refresh-1',
        deviceId: 'device-1',
      ),
    );
    final refreshClient = _FakeTokenRefreshClient(
      onRefresh: (_, _) async => throw StateError('must not refresh'),
    );
    final adapter = _SequenceAdapter((_, callCount) {
      if (callCount == 1) {
        firstRequestStarted.complete();
        return firstResponse.future;
      }
      return ResponseBody.fromString('{"ok":true}', 200);
    });
    final dio = Dio()..httpClientAdapter = adapter;
    final generation = AuthSessionGeneration();
    final manager = ServerTokenManager(
      store: store,
      refreshClient: refreshClient,
      authGeneration: generation,
    );
    final loginManager = ServerTokenManager(
      store: store,
      authGeneration: generation,
    );

    final request = manager.createAuthorizedDio(dio: dio).post(
      '/account-sensitive-action',
      data: {'value': 1},
    );
    await firstRequestStarted.future;
    await loginManager.saveSession(
      AuthSession(
        accessToken: _jwt(
          role: 'OWNER',
          expiresAt: DateTime.now().add(const Duration(minutes: 30)),
        ),
        refreshToken: 'other-account-refresh',
        deviceId: 'device-2',
      ),
    );
    firstResponse.complete(
      ResponseBody.fromString(
        '{"message":"unauthorized"}',
        401,
        headers: {
          Headers.contentTypeHeader: ['application/json'],
        },
      ),
    );

    await expectLater(
      request,
      throwsA(
        isA<DioException>().having(
          (error) => error.response?.statusCode,
          'statusCode',
          401,
        ),
      ),
    );
    expect(adapter.callCount, 1);
    expect(refreshClient.callCount, 0);
  });

  test('retry keeps its original generation before onRequest runs', () async {
    final generation = AuthSessionGeneration();
    final store = _MemoryAuthSessionStore(
      AuthSession(
        accessToken: _jwt(
          role: 'WORKER',
          expiresAt: DateTime.now().add(const Duration(minutes: 30)),
        ),
        refreshToken: 'refresh-1',
        deviceId: 'device-1',
      ),
    );
    final requestManager = ServerTokenManager(
      store: store,
      authGeneration: generation,
    );
    final loginManager = ServerTokenManager(
      store: store,
      authGeneration: generation,
    );
    final adapter = _SequenceAdapter(
      (_, _) => ResponseBody.fromString('{"ok":true}', 200),
    );
    final dio = Dio()..httpClientAdapter = adapter;
    final authorizedDio = requestManager.createAuthorizedDio(dio: dio);

    await loginManager.saveSession(
      AuthSession(
        accessToken: _jwt(
          role: 'OWNER',
          expiresAt: DateTime.now().add(const Duration(minutes: 30)),
        ),
        refreshToken: 'other-account-refresh',
        deviceId: 'device-2',
      ),
    );

    await expectLater(
      authorizedDio.get(
        '/retried-old-account-request',
        options: Options(
          extra: {
            'serverAuthGeneration': 0,
            'retried': true,
          },
        ),
      ),
      throwsA(
        isA<DioException>().having(
          (error) => error.error,
          'error',
          isA<AuthSessionChangedException>(),
        ),
      ),
    );
    expect(adapter.callCount, 0);
  });

  test('explicit logout suppresses the global expiry event', () async {
    final store = _MemoryAuthSessionStore(
      AuthSession(
        accessToken: _jwt(
          role: 'WORKER',
          expiresAt: DateTime.now().subtract(const Duration(minutes: 1)),
        ),
        refreshToken: 'expired-refresh',
        deviceId: 'device-1',
      ),
    );
    final events = AuthSessionEvents();
    var expiryCount = 0;
    final subscription = events.onExpired.listen((_) => expiryCount += 1);
    addTearDown(subscription.cancel);
    addTearDown(events.close);
    final manager = ServerTokenManager(
      store: store,
      refreshClient: _RejectedTokenRefreshClient(),
      sessionEvents: events,
    );

    final token = await manager.suppressExpiryNotifications(
      manager.resolveValidAccessToken,
    );

    expect(token, isNull);
    expect(await store.read(), isNull);
    expect(expiryCount, 0);
  });

  test('saving a new login session allows a later expiry event', () async {
    final events = AuthSessionEvents();
    var expiryCount = 0;
    final subscription = events.onExpired.listen((_) => expiryCount += 1);
    addTearDown(subscription.cancel);
    addTearDown(events.close);
    final manager = ServerTokenManager(
      store: _MemoryAuthSessionStore(null),
      sessionEvents: events,
    );

    events.notifyExpired();
    events.notifyExpired();
    await manager.saveSession(
      const AuthSession(
        accessToken: 'new-access',
        refreshToken: 'new-refresh',
        deviceId: 'device-1',
      ),
    );
    events.notifyExpired();

    expect(expiryCount, 2);
  });
}

class _MemoryAuthSessionStore implements AuthSessionStore {
  AuthSession? session;

  _MemoryAuthSessionStore(this.session);

  @override
  Future<void> clear() async {
    session = null;
  }

  @override
  Future<AuthSession?> read() async => session;

  @override
  Future<void> write(AuthSession value) async {
    session = value;
  }
}

class _FakeTokenRefreshClient implements TokenRefreshClient {
  final Future<RefreshTokens> Function(String, String) onRefresh;
  int callCount = 0;

  _FakeTokenRefreshClient({required this.onRefresh});

  @override
  Future<RefreshTokens> refresh(String refreshToken, String deviceId) {
    callCount += 1;
    return onRefresh(refreshToken, deviceId);
  }
}

class _RejectedTokenRefreshClient implements TokenRefreshClient {
  @override
  Future<RefreshTokens> refresh(String refreshToken, String deviceId) async {
    final requestOptions = RequestOptions(path: '/api/auth/token/refresh');
    throw DioException(
      requestOptions: requestOptions,
      response: Response(requestOptions: requestOptions, statusCode: 401),
    );
  }
}

class _SequenceAdapter implements HttpClientAdapter {
  final FutureOr<ResponseBody> Function(
    RequestOptions options,
    int callCount,
  ) handler;
  int callCount = 0;

  _SequenceAdapter(this.handler);

  @override
  void close({bool force = false}) {}

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    callCount += 1;
    return await handler(options, callCount);
  }
}

String _jwt({required String role, required DateTime expiresAt}) {
  String encode(Map<String, Object> value) =>
      base64Url.encode(utf8.encode(jsonEncode(value))).replaceAll('=', '');

  return '${encode({'alg': 'HS256', 'typ': 'JWT'})}.'
      '${encode({'exp': expiresAt.millisecondsSinceEpoch ~/ 1000, 'role': role, 'typ': 'ACCESS'})}.signature';
}
