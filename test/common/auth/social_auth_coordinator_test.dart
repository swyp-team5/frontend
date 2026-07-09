import 'package:chack_chack/common/auth/api/social_auth_api.dart';
import 'package:chack_chack/common/auth/model/social_auth_models.dart';
import 'package:chack_chack/common/auth/session/auth_session_store.dart';
import 'package:chack_chack/common/auth/social/social_auth_coordinator.dart';
import 'package:chack_chack/common/auth/social/social_identity_provider.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const device = DevicePayload(
    deviceId: 'device-1',
    platform: 'ANDROID',
    appVersion: '1.0.0',
  );
  const googleCredential = SocialCredential.google(
    idToken: 'google-id-token',
    device: device,
  );
  const kakaoCredential = SocialCredential.kakao(
    accessToken: 'kakao-access-token',
    device: device,
  );
  const ownerLoginResponse = AuthResponse.loginSuccess(
    accessToken: 'server-access',
    refreshToken: 'server-refresh',
    member: AuthMember(
      memberId: 1,
      name: 'owner',
      role: AuthMemberRole.owner,
      status: 'ACTIVE',
    ),
  );

  test('LOGIN_SUCCESS persists server session', () async {
    final sessionSaver = _FakeSessionSaver();
    final coordinator = SocialAuthCoordinator(
      providers: {SocialAuthProvider.google: _FakeProvider(googleCredential)},
      api: _FakeAuthClient(ownerLoginResponse),
      sessionSaver: sessionSaver,
    );

    final outcome = await coordinator.authenticate(SocialAuthProvider.google);

    expect(outcome.type, SocialAuthOutcomeType.loginSuccess);
    expect(outcome.member?.role, AuthMemberRole.owner);
    expect(sessionSaver.savedSession?.accessToken, 'server-access');
    expect(sessionSaver.savedSession?.deviceId, 'device-1');
  });

  test('SIGNUP_REQUIRED returns credential without saving tokens', () async {
    final sessionSaver = _FakeSessionSaver();
    final coordinator = SocialAuthCoordinator(
      providers: {SocialAuthProvider.kakao: _FakeProvider(kakaoCredential)},
      api: _FakeAuthClient(const AuthResponse.signupRequired()),
      sessionSaver: sessionSaver,
    );

    final outcome = await coordinator.authenticate(SocialAuthProvider.kakao);

    expect(outcome.type, SocialAuthOutcomeType.signupRequired);
    expect(outcome.credential, same(kakaoCredential));
    expect(sessionSaver.savedSession, isNull);
  });

  test('provider cancellation does not call backend', () async {
    final api = _FakeAuthClient(ownerLoginResponse);
    final coordinator = SocialAuthCoordinator(
      providers: {SocialAuthProvider.google: _FakeProvider(null)},
      api: api,
      sessionSaver: _FakeSessionSaver(),
    );

    final outcome = await coordinator.authenticate(SocialAuthProvider.google);

    expect(outcome.type, SocialAuthOutcomeType.cancelled);
    expect(api.callCount, 0);
  });

  test('rejects a provider that was not configured', () async {
    final coordinator = SocialAuthCoordinator(
      providers: const {},
      api: _FakeAuthClient(ownerLoginResponse),
      sessionSaver: _FakeSessionSaver(),
    );

    await expectLater(
      coordinator.authenticate(SocialAuthProvider.google),
      throwsA(isA<SocialProviderException>()),
    );
  });
}

class _FakeProvider implements SocialIdentityProvider {
  final SocialCredential? result;

  _FakeProvider(this.result);

  @override
  Future<SocialCredential?> authenticate() async => result;
}

class _FakeAuthClient implements SocialAuthClient {
  final AuthResponse response;
  int callCount = 0;

  _FakeAuthClient(this.response);

  @override
  Future<AuthResponse> login(SocialCredential credential) async {
    callCount += 1;
    return response;
  }
}

class _FakeSessionSaver implements AuthSessionSaver {
  AuthSession? savedSession;

  @override
  Future<void> saveSession(AuthSession session) async {
    savedSession = session;
  }
}
