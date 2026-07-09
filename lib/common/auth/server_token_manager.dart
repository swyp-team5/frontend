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
}
