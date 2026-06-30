import 'dart:convert';
import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:kakao_flutter_sdk_user/kakao_flutter_sdk_user.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../../api/auth_sociallLogin_api.dart';

class KakaoLoginService {
  static Future<Map<String, dynamic>> login() async {
    try {
      OAuthToken token;

      if (await isKakaoTalkInstalled()) {
        try {
          token = await UserApi.instance.loginWithKakaoTalk();
        } catch (_) {
          token = await UserApi.instance.loginWithKakaoAccount();
        }
      } else {
        token = await UserApi.instance.loginWithKakaoAccount();
      }

      final packageInfo = await PackageInfo.fromPlatform();
      final deviceInfo = DeviceInfoPlugin();

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

      final response = await AuthSocialLoginApi.socialLogin(
        provider: "KAKAO",
        accessToken: token.accessToken,
        deviceId: deviceId,
        platform: platform,
        appVersion: packageInfo.version,
      );

      final result = jsonDecode(response.body);

      if (response.statusCode != 200) {
        throw Exception(result["message"]);
      }

      /// 로그인 성공 후 필요한 값도 같이 반환
      return {
        "provider": "KAKAO",
        "accessToken": token.accessToken,
        "deviceId": deviceId,
        "platform": platform,
        "appVersion": packageInfo.version,
      };
    } catch (e) {
      throw Exception("카카오 로그인 오류 : $e");
    }
  }
}