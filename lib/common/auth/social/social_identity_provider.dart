import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:chack_chack/common/auth/config/auth_environment.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:kakao_flutter_sdk_user/kakao_flutter_sdk_user.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

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

abstract class InstallationIdStore {
  Future<String?> read();

  Future<void> write(String installationId);
}

class SecureInstallationIdStore implements InstallationIdStore {
  static const _key = 'social_installation_id';

  final FlutterSecureStorage storage;

  SecureInstallationIdStore({FlutterSecureStorage? storage})
    : storage = storage ?? FlutterSecureStorage(aOptions: AndroidOptions());

  @override
  Future<String?> read() => storage.read(key: _key);

  @override
  Future<void> write(String installationId) {
    return storage.write(key: _key, value: installationId);
  }
}

class InstallationIdProvider {
  final InstallationIdStore store;
  final List<int> Function(int length) randomBytes;

  Future<String>? _installationId;

  InstallationIdProvider({
    InstallationIdStore? store,
    List<int> Function(int length)? randomBytes,
  }) : store = store ?? SecureInstallationIdStore(),
       randomBytes = randomBytes ?? _secureRandomBytes;

  Future<String> load() {
    return _installationId ??= _load();
  }

  Future<String> _load() async {
    final existing = await store.read();
    if (existing != null && existing.isNotEmpty) {
      return existing;
    }

    final generated = base64UrlEncode(randomBytes(24)).replaceAll('=', '');
    await store.write(generated);
    return generated;
  }

  static List<int> _secureRandomBytes(int length) {
    final random = Random.secure();
    return List<int>.generate(length, (_) => random.nextInt(256));
  }
}

class DeviceContextProvider {
  final InstallationIdProvider installationIdProvider;

  DeviceContextProvider({InstallationIdProvider? installationIdProvider})
    : installationIdProvider =
          installationIdProvider ?? InstallationIdProvider();

  Future<DevicePayload> load() async {
    final platform = Platform.isAndroid
        ? 'ANDROID'
        : Platform.isIOS
        ? 'IOS'
        : null;
    if (platform == null) {
      throw const SocialProviderException('지원하지 않는 플랫폼이에요.');
    }

    final packageInfo = await PackageInfo.fromPlatform();
    final installationId = await installationIdProvider.load();
    debugPrint('[SocialAuth][Device] context ready platform=$platform');
    return DevicePayload(
      deviceId: installationId,
      platform: platform,
      appVersion: packageInfo.version,
    );
  }
}

class GoogleSocialIdentityProvider implements SocialIdentityProvider {
  static const serverClientId = AuthEnvironment.googleServerClientId;

  final GoogleSignIn googleSignIn;
  final DeviceContextProvider deviceContextProvider;

  GoogleSocialIdentityProvider({
    GoogleSignIn? googleSignIn,
    DeviceContextProvider? deviceContextProvider,
  }) : googleSignIn =
           googleSignIn ??
           GoogleSignIn(
             scopes: const ['email', 'profile'],
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
    } catch (error) {
      debugPrint('[SocialAuth][google] failure type=${error.runtimeType}');
      throw const SocialProviderException('Google 로그인에 실패했어요.');
    }
  }
}

class AppleSocialIdentityProvider implements SocialIdentityProvider {
  static const _androidClientId = 'com.chackchack.signin';
  static final _androidRedirectUri = Uri.parse(
    'https://chackchack.shop/api/auth/apple/callback',
  );

  final DeviceContextProvider deviceContextProvider;

  AppleSocialIdentityProvider({DeviceContextProvider? deviceContextProvider})
    : deviceContextProvider = deviceContextProvider ?? DeviceContextProvider();

  @override
  Future<SocialCredential?> authenticate() async {
    try {
      final credential = await SignInWithApple.getAppleIDCredential(
        scopes: const [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
        webAuthenticationOptions: Platform.isAndroid
            ? WebAuthenticationOptions(
                clientId: _androidClientId,
                redirectUri: _androidRedirectUri,
              )
            : null,
      );

      final idToken = credential.identityToken;
      final authorizationCode = credential.authorizationCode;
      if (idToken == null || idToken.isEmpty || authorizationCode.isEmpty) {
        throw const SocialProviderException('Apple 인증 정보를 확인하지 못했어요.');
      }

      return SocialCredential.apple(
        idToken: idToken,
        authorizationCode: authorizationCode,
        device: await deviceContextProvider.load(),
      );
    } on SignInWithAppleAuthorizationException catch (error) {
      if (error.code == AuthorizationErrorCode.canceled) {
        return null;
      }
      debugPrint(
        '[SocialAuth][apple] authorization failure code=${error.code.name}',
      );
      throw const SocialProviderException('Apple 로그인에 실패했어요.');
    } on SocialProviderException {
      rethrow;
    } catch (error) {
      debugPrint('[SocialAuth][apple] failure type=${error.runtimeType}');
      throw const SocialProviderException('Apple 로그인에 실패했어요.');
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
      debugPrint('[SocialAuth][kakao] SDK access token acquired');
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
      if (error is KakaoAuthException) {
        debugPrint(
          '[SocialAuth][kakao] SDK auth failure '
          'cause=${error.error.name} description=${error.errorDescription}',
        );
      } else if (error is KakaoClientException) {
        debugPrint(
          '[SocialAuth][kakao] SDK client failure reason=${error.reason.name}',
        );
      } else {
        debugPrint('[SocialAuth][kakao] SDK failure type=${error.runtimeType}');
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
