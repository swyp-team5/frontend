import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:chack_chack/common/account/account_settings_api.dart';
import 'package:chack_chack/common/auth/session/auth_session_store.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('logout sends refresh token and device id', () async {
    final adapter = _FakeAdapter((options) {
      expect(options.method, 'POST');
      expect(options.path, '/api/auth/logout');
      expect(options.data, {
        'refreshToken': 'refresh-token',
        'deviceId': 'device-1',
      });
      return ResponseBody.fromString('', 204);
    });
    final api = AccountSettingsApi(
      dio: Dio()..httpClientAdapter = adapter,
      sessionLoader: () async => const AuthSession(
        accessToken: 'access-token',
        refreshToken: 'refresh-token',
        deviceId: 'device-1',
      ),
      accessTokenLoader: () async => 'access-token',
    );

    await api.logout();

    expect(adapter.callCount, 1);
  });

  test('withdrawal sends bearer access token', () async {
    final adapter = _FakeAdapter((options) {
      expect(options.method, 'DELETE');
      expect(options.path, '/api/members/me');
      expect(options.headers['Authorization'], 'Bearer access-token');
      return ResponseBody.fromString('', 204);
    });
    final api = AccountSettingsApi(
      dio: Dio()..httpClientAdapter = adapter,
      sessionLoader: () async => const AuthSession(
        accessToken: 'access-token',
        refreshToken: 'refresh-token',
        deviceId: 'device-1',
      ),
      accessTokenLoader: () async => 'access-token',
    );

    await api.withdraw();

    expect(adapter.callCount, 1);
  });

  test('loads social provider from profile response', () async {
    final adapter = _FakeAdapter((options) {
      expect(options.method, 'GET');
      expect(options.path, '/api/members/me/profile');
      expect(options.headers['Authorization'], 'Bearer access-token');
      return ResponseBody.fromString(
        jsonEncode({'name': '테스터', 'socialProvider': 'KAKAO'}),
        200,
        headers: {
          Headers.contentTypeHeader: [Headers.jsonContentType],
        },
      );
    });
    final api = AccountSettingsApi(
      dio: Dio()..httpClientAdapter = adapter,
      sessionLoader: () async => const AuthSession(
        accessToken: 'access-token',
        refreshToken: 'refresh-token',
        deviceId: 'device-1',
      ),
      accessTokenLoader: () async => 'access-token',
    );

    final provider = await api.loadSocialProvider();

    expect(provider, SocialAccountProvider.kakao);
    expect(adapter.callCount, 1);
  });
}

class _FakeAdapter implements HttpClientAdapter {
  final ResponseBody Function(RequestOptions options) handler;
  int callCount = 0;

  _FakeAdapter(this.handler);

  @override
  void close({bool force = false}) {}

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    if (requestStream != null) {
      final bytes = await requestStream.expand((chunk) => chunk).toList();
      if (bytes.isNotEmpty && options.data == null) {
        options.data = jsonDecode(utf8.decode(bytes));
      }
    }
    callCount += 1;
    return handler(options);
  }
}
