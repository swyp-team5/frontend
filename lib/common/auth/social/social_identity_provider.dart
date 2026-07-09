import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:kakao_flutter_sdk_user/kakao_flutter_sdk_user.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../model/social_auth_models.dart';

abstract class SocialIdentityProvider {
  Future<SocialCredential?> authenticate();
}

class SocialProviderException implements Exception {
  final String message;
  final bool isConfigurationError;

  const SocialProviderException(
    this.message, {
    this.isConfigurationError = false,
  });

  @override
  String toString() => message;
}

class DeviceContextProvider {
  final DeviceInfoPlugin deviceInfo;

  DeviceContextProvider({DeviceInfoPlugin? deviceInfo})
    : deviceInfo = deviceInfo ?? DeviceInfoPlugin();

  Future<DevicePayload> load() async {
    final packageInfo = await PackageInfo.fromPlatform();
    if (Platform.isAndroid) {
      final info = await deviceInfo.androidInfo;
      return DevicePayload(
        deviceId: info.id,
        platform: 'ANDROID',
        appVersion: packageInfo.version,
      );
    }
    if (Platform.isIOS) {
      final info = await deviceInfo.iosInfo;
      final deviceId = info.identifierForVendor;
      if (deviceId == null || deviceId.isEmpty) {
        throw const SocialProviderException('기기 정보를 확인하지 못했어요.');
      }
      return DevicePayload(
        deviceId: deviceId,
        platform: 'IOS',
        appVersion: packageInfo.version,
      );
    }
    throw const SocialProviderException('지원하지 않는 플랫폼이에요.');
  }
}

class GoogleSocialIdentityProvider implements SocialIdentityProvider {
  static const serverClientId = String.fromEnvironment(
    'GOOGLE_SERVER_CLIENT_ID',
  );

  final GoogleSignIn googleSignIn;
  final DeviceContextProvider deviceContextProvider;

  GoogleSocialIdentityProvider({
    GoogleSignIn? googleSignIn,
    DeviceContextProvider? deviceContextProvider,
  }) : googleSignIn =
           googleSignIn ??
           GoogleSignIn(
             scopes: const ['email'],
             serverClientId: serverClientId.isEmpty ? null : serverClientId,
           ),
       deviceContextProvider = deviceContextProvider ?? DeviceContextProvider();

  @override
  Future<SocialCredential?> authenticate() async {
    if (serverClientId.isEmpty) {
      throw const SocialProviderException(
        'Google 로그인 설정이 완료되지 않았어요.',
        isConfigurationError: true,
      );
    }

    try {
      final account = await googleSignIn.signIn();
      if (account == null) {
        return null;
      }
      final authentication = await account.authentication;
      final idToken = authentication.idToken;
      if (idToken == null || idToken.isEmpty) {
        throw const SocialProviderException('Google 인증 정보를 확인하지 못했어요.');
      }
      return SocialCredential.google(
        idToken: idToken,
        device: await deviceContextProvider.load(),
      );
    } on SocialProviderException {
      rethrow;
    } catch (_) {
      throw const SocialProviderException('Google 로그인에 실패했어요.');
    }
  }
}

class KakaoSocialIdentityProvider implements SocialIdentityProvider {
  final DeviceContextProvider deviceContextProvider;

  KakaoSocialIdentityProvider({DeviceContextProvider? deviceContextProvider})
    : deviceContextProvider = deviceContextProvider ?? DeviceContextProvider();

  @override
  Future<SocialCredential?> authenticate() async {
    try {
      final token = await _login();
      if (token == null) {
        return null;
      }
      return SocialCredential.kakao(
        accessToken: token.accessToken,
        device: await deviceContextProvider.load(),
      );
    } on SocialProviderException {
      rethrow;
    } catch (error) {
      if (_isCancelled(error)) {
        return null;
      }
      throw const SocialProviderException('카카오 로그인에 실패했어요.');
    }
  }

  Future<OAuthToken?> _login() async {
    if (!await isKakaoTalkInstalled()) {
      return _loginWithAccount();
    }

    try {
      return await UserApi.instance.loginWithKakaoTalk();
    } catch (error) {
      if (_isCancelled(error)) {
        return null;
      }
      return _loginWithAccount();
    }
  }

  Future<OAuthToken?> _loginWithAccount() async {
    try {
      return await UserApi.instance.loginWithKakaoAccount();
    } catch (error) {
      if (_isCancelled(error)) {
        return null;
      }
      rethrow;
    }
  }

  bool _isCancelled(Object error) {
    return (error is KakaoClientException &&
            error.reason == ClientErrorCause.cancelled) ||
        (error is KakaoAuthException &&
            error.error == AuthErrorCause.accessDenied);
  }
}
