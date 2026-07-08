import 'dart:convert';

import 'package:chack_chack/common/auth/model/social_auth_models.dart';
import 'package:chack_chack/common/auth/server_token_manager.dart';
import 'package:chack_chack/common/auth/session/auth_session_store.dart';
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

  test('failed refresh clears auth session only', () async {
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
      refreshClient: _FailingTokenRefreshClient(),
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

class _FailingTokenRefreshClient implements TokenRefreshClient {
  @override
  Future<RefreshTokens> refresh(String refreshToken, String deviceId) async {
    throw Exception('refresh rejected');
  }
}

String _jwt({required String role, required DateTime expiresAt}) {
  String encode(Map<String, Object> value) =>
      base64Url.encode(utf8.encode(jsonEncode(value))).replaceAll('=', '');

  return '${encode({'alg': 'HS256', 'typ': 'JWT'})}.'
      '${encode({'exp': expiresAt.millisecondsSinceEpoch ~/ 1000, 'role': role, 'typ': 'ACCESS'})}.signature';
}
