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
    required String platform,
    required String appVersion,
  }) async {
    final url = Uri.parse("$baseUrl/api/auth/social-login");

    final Map<String, dynamic> body = {
      "provider": provider,
      "device": {
        "deviceId": deviceId,
        "platform": platform,
        "appVersion": appVersion,
      },
    };

    // provider별 필요한 값만 추가
    if (idToken != null) {
      body["idToken"] = idToken;
    }

    if (accessToken != null) {
      body["accessToken"] = accessToken;
    }

    if (authorizationCode != null) {
      body["authorizationCode"] = authorizationCode;
    }

    return await http.post(
      url,
      headers: {
        "Content-Type": "application/json",
      },
      body: jsonEncode(body),
    );
  }
}