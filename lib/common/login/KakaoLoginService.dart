import 'dart:convert';
import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:kakao_flutter_sdk_user/kakao_flutter_sdk_user.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../../api/auth_sociallLogin_api.dart';

class KakaoLoginService {
  static Future<Map<String, dynamic>> login() async {
    try {
      print("===== 1. Kakao Login Start =====");

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

      print("===== 2. Kakao Token Success =====");
      print(token.accessToken);

      final packageInfo = await PackageInfo.fromPlatform();

      print("===== 3. PackageInfo Success =====");
      print(packageInfo.version);

      String deviceId = "";
      String platform = Platform.isAndroid ? "ANDROID" : "IOS";

      if (Platform.isAndroid) {
        try {
          print("===== 4. DeviceInfo Start =====");

          final deviceInfo = DeviceInfoPlugin();
          final info = await deviceInfo.androidInfo;

          print("===== 5. DeviceInfo Success =====");

          print("id = ${info.id}");
          print("model = ${info.model}");
          print("sdk = ${info.version.sdkInt}");

          deviceId = info.id ?? "";
        } catch (e, s) {
          print("===== DeviceInfo Error =====");
          print(e);
          print(s);

          /// device_info_plus가 죽으면 임시 UUID 사용
          deviceId = "emulator-device";
        }
      } else {
        try {
          final deviceInfo = DeviceInfoPlugin();
          final info = await deviceInfo.iosInfo;

          deviceId = info.identifierForVendor ?? "";
        } catch (_) {
          deviceId = "ios-device";
        }
      }

      print("===== 6. Device =====");
      print(deviceId);
      print(platform);

      final response = await AuthSocialLoginApi.socialLogin(
        provider: "KAKAO",
        accessToken: token.accessToken,
        deviceId: deviceId,
        platform: platform,
        appVersion: packageInfo.version,
      );

      print("===== 7. Status =====");
      print(response.statusCode);

      print("===== 8. Body =====");
      print(response.body);

      final result = jsonDecode(response.body);

      print("===== 9. Parsed =====");
      print(result);

      return {
        "provider": "KAKAO",
        "accessToken": result["accessToken"], // 서버 JWT
        "refreshToken": result["refreshToken"], // 서버 RefreshToken
        "member": result["member"],
        "deviceId": deviceId,
        "platform": platform,
        "appVersion": packageInfo.version,
      };
    } catch (e, stack) {
      print("===== LOGIN ERROR =====");
      print(e);
      print(stack);
      rethrow;
    }
  }
}