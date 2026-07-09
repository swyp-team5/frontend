import 'package:chack_chack/common/auth/model/social_auth_models.dart';
import 'package:chack_chack/common/onboarding/models/signup_request.dart';
import 'package:chack_chack/common/onboarding/providers/signup_provider.dart';
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

  test('prepares Google signup without server tokens', () {
    final notifier = SignupNotifier();

    notifier.prepareSocialSignup(googleCredential);

    expect(notifier.state.provider, SocialProvider.GOOGLE);
    expect(notifier.state.idToken, 'google-id-token');
    expect(notifier.state.accessToken, isNull);
    expect(notifier.state.refreshToken, isNull);
    expect(notifier.state.device.deviceId, 'device-1');
    expect(notifier.state.device.platform, 'ANDROID');
  });

  test('prepares Kakao signup and clears stale Google state', () {
    final notifier = SignupNotifier();
    notifier.prepareSocialSignup(googleCredential);
    notifier
      ..setName('stale name')
      ..setPhoneNumber('01012345678');

    notifier.prepareSocialSignup(kakaoCredential);

    expect(notifier.state.provider, SocialProvider.KAKAO);
    expect(notifier.state.idToken, isNull);
    expect(notifier.state.accessToken, 'kakao-access-token');
    expect(notifier.state.name, isNull);
    expect(notifier.state.phoneNumber, isNull);
  });
}
