import 'dart:convert';

import 'package:chack_chack/common/auth/session/auth_session_store.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const sessionKey = 'server_auth_session';
  const accessTokenKey = 'server_access_token';
  const refreshTokenKey = 'server_refresh_token';
  const deviceIdKey = 'server_device_id';

  setUp(() {
    FlutterSecureStorage.setMockInitialValues({});
  });

  test('writes the rotated token pair as one secure session value', () async {
    final store = SecureAuthSessionStore();
    const session = AuthSession(
      accessToken: 'access-2',
      refreshToken: 'refresh-2',
      deviceId: 'device-1',
    );

    await store.write(session);

    const storage = FlutterSecureStorage();
    final rawSession = await storage.read(key: sessionKey);
    expect(jsonDecode(rawSession!), {
      'accessToken': 'access-2',
      'refreshToken': 'refresh-2',
      'deviceId': 'device-1',
    });
    expect(await storage.read(key: accessTokenKey), isNull);
    expect(await storage.read(key: refreshTokenKey), isNull);
    expect(await storage.read(key: deviceIdKey), isNull);
  });

  test('migrates a complete legacy token set to one session value', () async {
    FlutterSecureStorage.setMockInitialValues({
      accessTokenKey: 'legacy-access',
      refreshTokenKey: 'legacy-refresh',
      deviceIdKey: 'legacy-device',
    });
    final store = SecureAuthSessionStore();

    final session = await store.read();

    expect(session?.accessToken, 'legacy-access');
    expect(session?.refreshToken, 'legacy-refresh');
    expect(session?.deviceId, 'legacy-device');
    const storage = FlutterSecureStorage();
    expect(await storage.read(key: sessionKey), isNotNull);
    expect(await storage.read(key: accessTokenKey), isNull);
    expect(await storage.read(key: refreshTokenKey), isNull);
    expect(await storage.read(key: deviceIdKey), isNull);
  });
}
