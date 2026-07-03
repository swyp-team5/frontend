import 'dart:convert';
import 'package:dio/dio.dart';
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
  }

  static Future<String?> getAccessToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_accessTokenKey);
  }

  static Future<String?> getRefreshToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_refreshTokenKey);
  }

  static Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }

  /// JWT의 exp(초)를 파싱해서 만료 여부 확인
  static bool isExpired(String token) {
    try {
      final parts = token.split('.');
      if (parts.length != 3) return true;

      final payload = utf8.decode(
        base64Url.decode(base64Url.normalize(parts[1])),
      );
      final Map<String, dynamic> data = jsonDecode(payload);
      
      // 'Null' is not a subtype of type 'int' 오류를 방지하기 위해 num으로 받고 toInt() 처리
      final dynamic expValue = data['exp'];
      if (expValue == null) return true;
      
      final int exp = (expValue as num).toInt();

      final expDate = DateTime.fromMillisecondsSinceEpoch(exp * 1000);
      // 만료 10초 전이면 미리 만료로 취급 (여유 버퍼)
      return DateTime.now().isAfter(
        expDate.subtract(const Duration(seconds: 10)),
      );
    } catch (_) {
      return true;
    }
  }

  /// 유효한 accessToken 반환. 만료됐으면 자동으로 refresh 시도.
  static Future<String?> getValidAccessToken() async {
    final access = await getAccessToken();
    if (access == null) return null;

    if (!isExpired(access)) return access;

    // 만료됐으면 refresh 시도
    return refreshAccessToken();
  }

  /// refreshToken으로 새 accessToken 발급
  static Future<String?> refreshAccessToken() async {
    final refreshToken = await getRefreshToken();
    if (refreshToken == null) return null;

    try {
      // 인터셉터 없는 별도 Dio 인스턴스 사용 (무한루프 방지)
      final refreshDio = Dio();

      final response = await refreshDio.post(
        "https://chackchack.shop/api/auth/refresh",
        data: {"refreshToken": refreshToken},
      );

      final newAccessToken = response.data["accessToken"];
      final newRefreshToken = response.data["refreshToken"] ?? refreshToken;

      if (newAccessToken != null) {
        await saveTokens(
          accessToken: newAccessToken,
          refreshToken: newRefreshToken,
        );
        return newAccessToken;
      }
      return null;
    } catch (e) {
      // refresh도 실패 → 재로그인 필요
      await clear();
      return null;
    }
  }
}
