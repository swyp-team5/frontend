import 'dart:convert';
import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:kakao_flutter_sdk_user/kakao_flutter_sdk_user.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../../api/auth_sociallLogin_api.dart';

class KakaoLoginService {
  static Future<Map<String, dynamic>> login() async {
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

    String deviceId = "";
    final platform = Platform.isAndroid ? "ANDROID" : "IOS";

    if (Platform.isAndroid) {
      try {
        final info = await DeviceInfoPlugin().androidInfo;
        deviceId = info.id;
      } catch (_) {
        deviceId = "emulator-device";
      }
    } else {
      try {
        final info = await DeviceInfoPlugin().iosInfo;
        deviceId = info.identifierForVendor ?? "ios-device";
      } catch (_) {
        deviceId = "ios-device";
      }
    }

    final response = await AuthSocialLoginApi.socialLogin(
      provider: "KAKAO",
      accessToken: token.accessToken,
      deviceId: deviceId,
      platform: platform,
      appVersion: packageInfo.version,
    );

    if (response.statusCode != 200) {
      throw Exception(response.body);
    }

    final body = jsonDecode(response.body);

    print(body);

    //------------------------------------------------
    // 서버 응답 구조 대응
    //------------------------------------------------

    final data = body["data"] ?? body;

    final accessToken = data["accessToken"];
    final refreshToken = data["refreshToken"];
    final member = data["member"];

    if (accessToken == null) {
      throw Exception("서버에서 accessToken을 받지 못했습니다.");
    }

    return {
      "provider": "KAKAO",
      "accessToken": accessToken,
      "refreshToken": refreshToken,
      "member": member,
      "deviceId": deviceId,
      "platform": platform,
      "appVersion": packageInfo.version,
    };
  }
}