import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../../auth/server_token_manager.dart';
import '../model/FcmTokenResponse.dart';

class FcmTokenApi {
  static final Dio _dio = Dio(
    BaseOptions(baseUrl: "https://chackchack.shop"),
  );

  /// FCM 토큰 등록 또는 갱신
  /// POST /api/fcm-tokens
  /// - 로그인한 회원의 토큰만 등록/갱신
  /// - 같은 member_id + device_id가 이미 있으면 기존 row를 갱신 (새로 만들지 않음)
  /// - 다시 등록하면 status는 ACTIVE가 됨
  static Future<FcmTokenResponse> register({
    required String deviceId,
    required String token,
    required String platform, // "ANDROID" | "IOS"
    required String appVersion,
  }) async {
    final accessToken = await ServerTokenManager.getAccessToken();

    if (accessToken == null || accessToken.isEmpty) {
      throw Exception("인증이 필요합니다. 다시 로그인해주세요.");
    }

    debugPrint("📤 [FcmTokenApi] 요청 URL: ${_dio.options.baseUrl}/api/fcm-tokens");
    debugPrint(
        "📤 [FcmTokenApi] 파라미터: deviceId=$deviceId, platform=$platform, appVersion=$appVersion");

    try {
      final res = await _dio.post(
        "/api/fcm-tokens",
        data: {
          "deviceId": deviceId,
          "token": token,
          "platform": platform,
          "appVersion": appVersion,
        },
        options: Options(
          headers: {"Authorization": "Bearer $accessToken"},
        ),
      );

      debugPrint("✅ [FcmTokenApi] 성공 — statusCode: ${res.statusCode}");
      debugPrint("✅ [FcmTokenApi] 응답 body: ${res.data}");

      final parsed = FcmTokenResponse.fromJson(res.data);

      debugPrint(
          "✅ [FcmTokenApi] 파싱 완료 — fcmTokenId=${parsed.fcmTokenId}, status=${parsed.status}");

      return parsed;
    } on DioException catch (e) {
      debugPrint("🔴 [FcmTokenApi] 실패 — statusCode: ${e.response?.statusCode}");
      debugPrint("🔴 [FcmTokenApi] 실패 — 응답 body: ${e.response?.data}");

      final message =
      e.response?.data is Map ? e.response?.data["message"] : null;
      throw Exception(message ?? "FCM 토큰 등록 실패 (${e.response?.statusCode})");
    }
  }

  // FCM 토큰 비활성화
  // - 로그인한 회원 본인 소유의 deviceId 토큰만 비활성화 대상이 된다.
  // - 토큰이 이미 없어도 서버가 204를 내려주는 idempotent API라 별도 "없음" 예외 처리는 하지 않는다.
  // - 다른 회원의 같은 deviceId 토큰에는 영향 없음 (서버가 member 기준으로 필터링).
  /// DELETE /api/fcm-tokens/devices/{deviceId}
  static Future<void> deactivate({
    required String deviceId,
  }) async {
    final accessToken = await ServerTokenManager.getAccessToken();

    if (accessToken == null || accessToken.isEmpty) {
      throw Exception("인증이 필요합니다. 다시 로그인해주세요.");
    }

    debugPrint(
        "📤 [FcmTokenApi] 요청 URL: ${_dio.options.baseUrl}/api/fcm-tokens/devices/$deviceId");

    try {
      final res = await _dio.delete(
        "/api/fcm-tokens/devices/$deviceId",
        options: Options(
          headers: {"Authorization": "Bearer $accessToken"},
        ),
      );

      debugPrint("✅ [FcmTokenApi] 비활성화 성공 — statusCode: ${res.statusCode}");
    } on DioException catch (e) {
      debugPrint(
          "🔴 [FcmTokenApi] 비활성화 실패 — statusCode: ${e.response?.statusCode}");
      debugPrint("🔴 [FcmTokenApi] 비활성화 실패 — 응답 body: ${e.response?.data}");

      final message =
      e.response?.data is Map ? e.response?.data["message"] : null;
      throw Exception(message ?? "FCM 토큰 비활성화 실패 (${e.response?.statusCode})");
    }
  }

}