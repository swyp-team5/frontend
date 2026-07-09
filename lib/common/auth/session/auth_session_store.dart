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
  static const _accessTokenKey = 'server_access_token';
  static const _refreshTokenKey = 'server_refresh_token';
  static const _deviceIdKey = 'server_device_id';

  final FlutterSecureStorage _storage;

  SecureAuthSessionStore({FlutterSecureStorage? storage})
      : _storage = storage ?? FlutterSecureStorage(aOptions: AndroidOptions());

  @override
  Future<AuthSession?> read() async {
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
    return AuthSession(
      accessToken: accessToken,
      refreshToken: refreshToken,
      deviceId: deviceId,
    );
  }

  @override
  Future<void> write(AuthSession session) async {
    await _storage.write(key: _accessTokenKey, value: session.accessToken);
    await _storage.write(key: _refreshTokenKey, value: session.refreshToken);
    await _storage.write(key: _deviceIdKey, value: session.deviceId);
  }

  @override
  Future<void> clear() async {
    await _storage.delete(key: _accessTokenKey);
    await _storage.delete(key: _refreshTokenKey);
    await _storage.delete(key: _deviceIdKey);
  }
}