import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AuthSession {
  final String accessToken;
  final String refreshToken;
  final String deviceId;

  const AuthSession({
    required this.accessToken,
    required this.refreshToken,
    required this.deviceId,
  });
}

abstract class AuthSessionStore {
  Future<AuthSession?> read();

  Future<void> write(AuthSession session);

  Future<void> clear();
}

abstract class AuthSessionSaver {
  Future<void> saveSession(AuthSession session);
}

class SecureAuthSessionStore implements AuthSessionStore {
  static const _sessionKey = 'server_auth_session';
  static const _accessTokenKey = 'server_access_token';
  static const _refreshTokenKey = 'server_refresh_token';
  static const _deviceIdKey = 'server_device_id';

  final FlutterSecureStorage _storage;

  SecureAuthSessionStore({FlutterSecureStorage? storage})
    : _storage = storage ?? FlutterSecureStorage(aOptions: AndroidOptions());

  @override
  Future<AuthSession?> read() async {
    final encodedSession = await _storage.read(key: _sessionKey);
    if (encodedSession != null) {
      final session = _decodeSession(encodedSession);
      if (session != null) {
        return session;
      }
      await _storage.delete(key: _sessionKey);
    }

    final values = await Future.wait([
      _storage.read(key: _accessTokenKey),
      _storage.read(key: _refreshTokenKey),
      _storage.read(key: _deviceIdKey),
    ]);

    final accessToken = values[0];
    final refreshToken = values[1];
    final deviceId = values[2];
    if (accessToken == null || refreshToken == null || deviceId == null) {
      return null;
    }
    final session = AuthSession(
      accessToken: accessToken,
      refreshToken: refreshToken,
      deviceId: deviceId,
    );
    await write(session);
    return session;
  }

  @override
  Future<void> write(AuthSession session) async {
    await _storage.write(
      key: _sessionKey,
      value: jsonEncode({
        'accessToken': session.accessToken,
        'refreshToken': session.refreshToken,
        'deviceId': session.deviceId,
      }),
    );
    await _deleteLegacyKeys();
  }

  @override
  Future<void> clear() async {
    await _storage.delete(key: _sessionKey);
    await _deleteLegacyKeys();
  }

  AuthSession? _decodeSession(String encodedSession) {
    try {
      final data = jsonDecode(encodedSession);
      if (data is! Map) {
        return null;
      }
      final accessToken = data['accessToken'];
      final refreshToken = data['refreshToken'];
      final deviceId = data['deviceId'];
      if (accessToken is! String ||
          accessToken.isEmpty ||
          refreshToken is! String ||
          refreshToken.isEmpty ||
          deviceId is! String ||
          deviceId.isEmpty) {
        return null;
      }
      return AuthSession(
        accessToken: accessToken,
        refreshToken: refreshToken,
        deviceId: deviceId,
      );
    } catch (_) {
      return null;
    }
  }

  Future<void> _deleteLegacyKeys() async {
    await Future.wait([
      _storage.delete(key: _accessTokenKey),
      _storage.delete(key: _refreshTokenKey),
      _storage.delete(key: _deviceIdKey),
    ]);
  }
}
