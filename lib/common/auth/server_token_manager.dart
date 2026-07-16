import 'dart:convert';

import 'package:dio/dio.dart';

import 'model/social_auth_models.dart';
import 'session/auth_session_store.dart';

class RefreshTokens {
  final String accessToken;
  final String refreshToken;

  const RefreshTokens({required this.accessToken, required this.refreshToken});
}

abstract class TokenRefreshClient {
  Future<RefreshTokens> refresh(String refreshToken, String deviceId);
}

class DioTokenRefreshClient implements TokenRefreshClient {
  final Dio dio;

  DioTokenRefreshClient({Dio? dio})
      : dio = dio ??
      Dio(
        BaseOptions(
          baseUrl: 'https://chackchack.shop',
          connectTimeout: const Duration(seconds: 10),
          receiveTimeout: const Duration(seconds: 10),
          headers: const {
            'Accept': 'application/json',
            'Content-Type': 'application/json',
          },
        ),
      );

  @override
  Future<RefreshTokens> refresh(String refreshToken, String deviceId) async {
    final response = await dio.post(
      '/api/auth/token/refresh',
      data: {'refreshToken': refreshToken, 'deviceId': deviceId},
    );
    final data = response.data;
    if (data is! Map) {
      throw const FormatException('Invalid refresh response');
    }
    final access = data['accessToken'];
    final rotatedRefresh = data['refreshToken'];
    if (access is! String ||
        access.isEmpty ||
        rotatedRefresh is! String ||
        rotatedRefresh.isEmpty) {
      throw const FormatException('Invalid refresh response');
    }
    return RefreshTokens(accessToken: access, refreshToken: rotatedRefresh);
  }
}

class ServerTokenManager implements AuthSessionSaver {
  static final ServerTokenManager _defaultManager = ServerTokenManager();

  final AuthSessionStore store;
  final TokenRefreshClient refreshClient;

  Future<String?>? _refreshFuture;

  /// 앱 전역에서 재사용할 "인증이 필요한" API 호출용 공용 Dio.
  /// 이 Dio를 쓰면 각 API 파일에서 직접 토큰을 읽어 헤더에 넣거나
  /// 만료 여부를 신경 쓸 필요가 없다 — 인터셉터가 자동으로 처리한다.
  static Dio? _authorizedDio;

  ServerTokenManager({
    AuthSessionStore? store,
    TokenRefreshClient? refreshClient,
  }) : store = store ?? SecureAuthSessionStore(),
        refreshClient = refreshClient ?? DioTokenRefreshClient();

  @override
  Future<void> saveSession(AuthSession session) {
    return store.write(session);
  }

  static Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
    required String deviceId,
  }) {
    return _defaultManager.saveSession(
      AuthSession(
        accessToken: accessToken,
        refreshToken: refreshToken,
        deviceId: deviceId,
      ),
    );
  }

  static Future<String?> getAccessToken() async {
    return (await _defaultManager.store.read())?.accessToken;
  }

  static Future<String?> getRefreshToken() async {
    return (await _defaultManager.store.read())?.refreshToken;
  }

  static Future<void> clear() {
    return _defaultManager.store.clear();
  }

  static bool isExpired(String token) {
    try {
      final data = _decodePayload(token);
      final exp = (data['exp'] as num).toInt();
      final expDate = DateTime.fromMillisecondsSinceEpoch(exp * 1000);
      return DateTime.now().isAfter(
        expDate.subtract(const Duration(seconds: 10)),
      );
    } catch (_) {
      return true;
    }
  }

  static AuthMemberRole? roleFromToken(String token) {
    try {
      switch (_decodePayload(token)['role']) {
        case 'OWNER':
          return AuthMemberRole.owner;
        case 'WORKER':
          return AuthMemberRole.worker;
        default:
          return null;
      }
    } catch (_) {
      return null;
    }
  }

  static Future<String?> getValidAccessToken() {
    return _defaultManager.resolveValidAccessToken();
  }

  static Future<String?> refreshAccessToken() {
    return _defaultManager.refreshSession();
  }

  Future<String?> resolveValidAccessToken() async {
    final session = await store.read();
    if (session == null) {
      return null;
    }
    if (!isExpired(session.accessToken)) {
      return session.accessToken;
    }
    return _refreshOnce(session);
  }

  Future<String?> refreshSession() async {
    final session = await store.read();
    if (session == null) {
      return null;
    }
    return _refreshOnce(session);
  }

  Future<String?> _refreshOnce(AuthSession session) {
    final running = _refreshFuture;
    if (running != null) {
      return running;
    }

    _refreshFuture = _refresh(session).whenComplete(() {
      _refreshFuture = null;
    });

    return _refreshFuture!;
  }

  Future<String?> _refresh(AuthSession session) async {
    try {
      final tokens = await refreshClient.refresh(
        session.refreshToken,
        session.deviceId,
      );
      if (isExpired(tokens.accessToken)) {
        throw const FormatException('Invalid refreshed access token');
      }
      await saveSession(
        AuthSession(
          accessToken: tokens.accessToken,
          refreshToken: tokens.refreshToken,
          deviceId: session.deviceId,
        ),
      );
      return tokens.accessToken;
    } catch (_) {
      await store.clear();
      return null;
    }
  }

  static Map<String, dynamic> _decodePayload(String token) {
    final parts = token.split('.');
    if (parts.length != 3) {
      throw const FormatException('Invalid token');
    }
    final payload = utf8.decode(
      base64Url.decode(base64Url.normalize(parts[1])),
    );
    final data = jsonDecode(payload);
    if (data is! Map<String, dynamic>) {
      throw const FormatException('Invalid token payload');
    }
    return data;
  }

  /// ✅ 인증이 필요한 API 호출에 사용할 공용 Dio.
  ///
  /// - 요청 전: 만료 여부와 상관없이 항상 "유효한" 액세스 토큰을 확보해서
  ///   Authorization 헤더에 자동으로 넣어준다 (만료 시 자동 refresh).
  /// - 그래도 서버가 401을 내려주면(예: 토큰 확인 시점 이후 서버 쪽에서
  ///   즉시 만료/폐기 처리된 경우) 한 번 더 refresh를 시도한 뒤
  ///   원래 요청을 자동으로 재시도한다.
  /// - refresh 자체가 실패하면(리프레시 토큰도 만료 등) 세션을 지우고
  ///   원래 401 에러를 그대로 전달한다. 이 경우 로그인 화면으로 보내는
  ///   처리는 호출부(또는 앱 전역 에러 핸들러)에서 하면 된다.
  static Dio get authorizedDio {
    return _authorizedDio ??= _buildAuthorizedDio();
  }

  static Dio _buildAuthorizedDio() {
    final dio = Dio(
      BaseOptions(
        baseUrl: 'https://chackchack.shop',
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
      ),
    );

    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await getValidAccessToken();
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          handler.next(options);
        },
        onError: (error, handler) async {
          final isUnauthorized = error.response?.statusCode == 401;
          // 재시도 무한 루프 방지용 플래그
          final alreadyRetried =
              error.requestOptions.extra['retried'] == true;

          if (!isUnauthorized || alreadyRetried) {
            handler.next(error);
            return;
          }

          final refreshed = await refreshAccessToken();

          if (refreshed == null) {
            // refresh 자체가 실패 → 세션 만료. 원래 에러를 그대로 전달.
            handler.next(error);
            return;
          }

          try {
            final retryOptions = error.requestOptions;
            retryOptions.headers['Authorization'] = 'Bearer $refreshed';
            retryOptions.extra['retried'] = true;

            final response = await dio.fetch(retryOptions);
            handler.resolve(response);
          } catch (e) {
            handler.next(error);
          }
        },
      ),
    );

    return dio;
  }
}