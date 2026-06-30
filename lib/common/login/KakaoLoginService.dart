import 'dart:convert';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:kakao_flutter_sdk_user/kakao_flutter_sdk_user.dart';

import '../../api/auth_sociallLogin_api.dart';

class KakaoLoginService {
  /// 카카오 로그인 + 서버 로그인
  static Future<Map<String, dynamic>> login() async {
    try {
      OAuthToken token;

      // 카카오톡 설치 여부
      if (await isKakaoTalkInstalled()) {
        try {
          token = await UserApi.instance.loginWithKakaoTalk();
        } catch (_) {
          token = await UserApi.instance.loginWithKakaoAccount();
        }
      } else {
        token = await UserApi.instance.loginWithKakaoAccount();
      }

      // 기기 정보
      final deviceInfo = DeviceInfoPlugin();
      final androidInfo = await deviceInfo.androidInfo;
      final packageInfo = await PackageInfo.fromPlatform();

      // 서버 로그인
      final response = await AuthSocialLoginApi.socialLogin(
        provider: "KAKAO",
        accessToken: token.accessToken,
        deviceId: androidInfo.id,
        platform: "ANDROID",
        appVersion: packageInfo.version,
      );

      if (response.body.isEmpty) {
        throw Exception("서버 응답이 없습니다.");
      }

      final Map<String, dynamic> result =
      jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode == 200) {
        return result;
      } else {
        throw Exception(result["message"] ?? "카카오 로그인 실패");
      }
    } catch (e) {
      throw Exception("카카오 로그인 오류 : $e");
    }
  }
}