import 'dart:convert';
import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:kakao_flutter_sdk_user/kakao_flutter_sdk_user.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../../api/auth_sociallLogin_api.dart';

class KakaoLoginService {
  static Future<Map<String, dynamic>> login() async {
    OAuthToken kakaoToken;

    // -----------------------------
    // 카카오 로그인
    // -----------------------------
    if (await isKakaoTalkInstalled()) {
      try {
        kakaoToken = await UserApi.instance.loginWithKakaoTalk();
      } catch (_) {
        kakaoToken = await UserApi.instance.loginWithKakaoAccount();
      }
    } else {
      kakaoToken = await UserApi.instance.loginWithKakaoAccount();
    }

    // -----------------------------
    // 디바이스 정보
    // -----------------------------
    final packageInfo = await PackageInfo.fromPlatform();

    String deviceId = "";
    final platform = Platform.isAndroid ? "ANDROID" : "IOS";

    if (Platform.isAndroid) {
      final info = await DeviceInfoPlugin().androidInfo;
      deviceId = info.id;
    } else {
      final info = await DeviceInfoPlugin().iosInfo;
      deviceId = info.identifierForVendor ?? "ios-device";
    }

    // -----------------------------
    // 서버 로그인
    // -----------------------------
    final response = await AuthSocialLoginApi.socialLogin(
      provider: "KAKAO",
      accessToken: kakaoToken.accessToken,
      deviceId: deviceId,
      platform: platform,
      appVersion: packageInfo.version,
    );

    print("========== SERVER LOGIN ==========");
    print("STATUS : ${response.statusCode}");
    print("BODY : ${response.body}");

    final result = jsonDecode(response.body);

    if (response.statusCode != 200) {
      throw Exception(result["message"] ?? "서버 로그인 실패");
    }

    return {
      "provider": "KAKAO",

      // 서버 JWT
      "serverAccessToken": result["accessToken"],
      "serverRefreshToken": result["refreshToken"],

      // 카카오 토큰
      "kakaoAccessToken": kakaoToken.accessToken,

      // 기기정보
      "deviceId": deviceId,
      "platform": platform,
      "appVersion": packageInfo.version,

      // 회원정보
      "member": result["member"],
    };
  }
}