import 'dart:convert';
import 'package:http/http.dart' as http;

class AuthSocialLoginApi {
  static const String baseUrl = "https://chackchack.shop";

  static Future<http.Response> socialLogin({
    required String provider,
    String? idToken,
    String? accessToken,
    String? authorizationCode,
    required String deviceId,
    required String platform, // ANDROID 또는 IOS
    required String appVersion,
  }) async {
    final url = Uri.parse("$baseUrl/api/auth/social-login");

    final Map<String, dynamic> body = {
      "provider": provider.toUpperCase(),
      "device": {
        "deviceId": deviceId,
        "platform": platform.toUpperCase(),
        "appVersion": appVersion,
      },
    };

    // provider별 필요한 토큰만 전송
    if (idToken != null && idToken.isNotEmpty) {
      body["idToken"] = idToken;
    }

    if (accessToken != null && accessToken.isNotEmpty) {
      body["accessToken"] = accessToken;
    }

    if (authorizationCode != null && authorizationCode.isNotEmpty) {
      body["authorizationCode"] = authorizationCode;
    }

    return http.post(
      url,
      headers: const {
        "Content-Type": "application/json",
      },
      body: jsonEncode(body),
    );
  }
}