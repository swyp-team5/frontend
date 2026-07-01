import 'package:shared_preferences/shared_preferences.dart';

class ServerTokenManager {
  static const _accessTokenKey = "server_access_token";
  static const _refreshTokenKey = "server_refresh_token";

  static Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
  }) async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setString(_accessTokenKey, accessToken);
    await prefs.setString(_refreshTokenKey, refreshToken);

    await prefs.reload(); // 🔥 중요 (flush 보장)

    final check = prefs.getString(_accessTokenKey);
    print("===== SAVE CHECK =====");
    print(check);
  }

  static Future<String> getAccessToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.reload(); // 🔥 중요

    final token = prefs.getString(_accessTokenKey);

    print("===== TOKEN LOAD =====");
    print(token);

    if (token == null || token.isEmpty) {
      throw Exception("로그인 토큰 없음 (재로그인 필요)");
    }

    return token;
  }

  static Future<String> getRefreshToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.reload();

    final token = prefs.getString(_refreshTokenKey);

    if (token == null || token.isEmpty) {
      throw Exception("refresh token 없음");
    }

    return token;
  }

  static Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
}