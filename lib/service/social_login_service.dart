import 'dart:convert';
import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:kakao_flutter_sdk_user/kakao_flutter_sdk_user.dart';

import '../api/auth_sociallLogin_api.dart';

class SocialLoginService {
  static Future<Map<String, String>> _deviceInfo() async {
    final deviceInfo = DeviceInfoPlugin();
    final packageInfo = await PackageInfo.fromPlatform();

    String deviceId;
    String platform;

    if (Platform.isAndroid) {
      final info = await deviceInfo.androidInfo;
      deviceId = info.id;
      platform = "ANDROID";
    } else {
      final info = await deviceInfo.iosInfo;
      deviceId = info.identifierForVendor ?? "";
      platform = "IOS";
    }

    return {
      "deviceId": deviceId,
      "platform": platform,
      "appVersion": packageInfo.version,
    };
  }

  /// GOOGLE
  static Future<Map<String, dynamic>> googleLogin() async {
    final googleSignIn = GoogleSignIn(
      scopes: ['email'],
    );

    final account = await googleSignIn.signIn();

    if (account == null) {
      throw Exception("Google 로그인 취소");
    }

    final auth = await account.authentication;

    if (auth.idToken == null) {
      throw Exception("Google idToken 없음");
    }

    final device = await _deviceInfo();

    final response = await AuthSocialLoginApi.socialLogin(
      provider: "GOOGLE",
      idToken: auth.idToken,
      accessToken: null,
      authorizationCode: null,
      deviceId: device["deviceId"]!,
      platform: device["platform"]!,
      appVersion: device["appVersion"]!,
    );

    return jsonDecode(response.body);
  }

  /// KAKAO
  static Future<Map<String, dynamic>> kakaoLogin() async {
    try {
      OAuthToken token;

      if (await isKakaoTalkInstalled()) {
        try {
          token = await UserApi.instance.loginWithKakaoTalk();
        } catch (_) {
          // 카카오톡 로그인 실패 → 카카오계정 로그인
          token = await UserApi.instance.loginWithKakaoAccount();
        }
      } else {
        token = await UserApi.instance.loginWithKakaoAccount();
      }

      final device = await _deviceInfo();

      final response = await AuthSocialLoginApi.socialLogin(
        provider: "KAKAO",
        accessToken: token.accessToken,
        deviceId: device["deviceId"]!,
        platform: device["platform"]!,
        appVersion: device["appVersion"]!,
      );

      if (response.statusCode != 200) {
        throw Exception(response.body);
      }

      return jsonDecode(response.body);
    } catch (e) {
      rethrow;
    }
  }

  /// APPLE
  static Future<Map<String, dynamic>> appleLogin() async {
    final credential = await SignInWithApple.getAppleIDCredential(
      scopes: [
        AppleIDAuthorizationScopes.email,
        AppleIDAuthorizationScopes.fullName,
      ],
    );

    final device = await _deviceInfo();

    final response = await AuthSocialLoginApi.socialLogin(
      provider: "APPLE",
      idToken: credential.identityToken,
      accessToken: null,
      authorizationCode: credential.authorizationCode,
      deviceId: device["deviceId"]!,
      platform: device["platform"]!,
      appVersion: device["appVersion"]!,
    );

    return jsonDecode(response.body);
  }
}