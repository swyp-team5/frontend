import 'package:chack_chack/common/auth/api/social_auth_api.dart';
import 'package:chack_chack/common/auth/model/social_auth_models.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

void main() {
  const device = DevicePayload(
    deviceId: 'device-1',
    platform: 'ANDROID',
    appVersion: '1.0.0',
  );

  test('parses LOGIN_SUCCESS and member role', () async {
    final api = SocialAuthApi(
      client: MockClient((request) async {
        expect(request.url.path, '/api/auth/social-login');
        expect(request.body, contains('"provider":"GOOGLE"'));
        expect(request.body, contains('"idToken":"google-id-token"'));
        return http.Response(
          '{"status":"LOGIN_SUCCESS","accessToken":"a","refreshToken":"r",'
          '"member":{"memberId":1,"name":"owner","role":"OWNER","status":"ACTIVE"}}',
          200,
          headers: {'content-type': 'application/json'},
        );
      }),
    );

    final response = await api.login(
      const SocialCredential.google(idToken: 'google-id-token', device: device),
    );

    expect(response.status, AuthStatus.loginSuccess);
    expect(response.member?.role, AuthMemberRole.owner);
  });

  test('parses SIGNUP_REQUIRED without server tokens', () async {
    final api = SocialAuthApi(
      client: MockClient(
        (_) async => http.Response(
          '{"status":"SIGNUP_REQUIRED"}',
          200,
          headers: {'content-type': 'application/json'},
        ),
      ),
    );

    final response = await api.login(
      const SocialCredential.kakao(
        accessToken: 'kakao-access-token',
        device: device,
      ),
    );

    expect(response.status, AuthStatus.signupRequired);
    expect(response.accessToken, isNull);
    expect(response.refreshToken, isNull);
    expect(response.member, isNull);
  });

  test('uses backend message for a failed request', () async {
    final api = SocialAuthApi(
      client: MockClient(
        (_) async => http.Response(
          '{"code":"4002","message":"Google 인증 정보가 올바르지 않습니다."}',
          401,
          headers: {'content-type': 'application/json'},
        ),
      ),
    );

    await expectLater(
      api.login(
        const SocialCredential.google(idToken: 'invalid', device: device),
      ),
      throwsA(
        isA<SocialAuthException>().having(
          (error) => error.message,
          'message',
          'Google 인증 정보가 올바르지 않습니다.',
        ),
      ),
    );
  });

  test('uses a safe fallback for a non-json error', () async {
    final api = SocialAuthApi(
      client: MockClient((_) async => http.Response('Bad Gateway', 502)),
    );

    await expectLater(
      api.login(
        const SocialCredential.kakao(
          accessToken: 'kakao-access-token',
          device: device,
        ),
      ),
      throwsA(
        isA<SocialAuthException>().having(
          (error) => error.message,
          'message',
          '소셜 로그인에 실패했어요.',
        ),
      ),
    );
  });
}
