import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../../auth/server_token_manager.dart';
import '../model/NotificationSettingsResponse.dart';

// 회원 알림(FCM 푸시) 수신 설정 조회/변경 API
// - OWNER, WORKER 둘 다 호출 가능, JWT 인증 필요.
// - fcmPushEnabled=false이면 PushPolicy.PUSH 알림도 앱 내부 알림함에만 저장되고
//   실제 기기로는 FCM delivery가 생성되지 않는다.
class NotificationSettingsApi {
  static final Dio _dio = Dio(
    BaseOptions(baseUrl: "https://chackchack.shop"),
  );

  // 현재 로그인한 회원의 FCM 푸시 수신 설정 조회
  /// GET /api/members/me/notification-settings
  static Future<NotificationSettingsResponse> getSettings() async {
    final accessToken = await ServerTokenManager.getAccessToken();

    if (accessToken == null || accessToken.isEmpty) {
      throw Exception("인증이 필요합니다. 다시 로그인해주세요.");
    }

    debugPrint(
        "📤 [NotificationSettingsApi] 요청 URL: ${_dio.options.baseUrl}/api/members/me/notification-settings");

    try {
      final res = await _dio.get(
        "/api/members/me/notification-settings",
        options: Options(
          headers: {"Authorization": "Bearer $accessToken"},
        ),
      );

      debugPrint("✅ [NotificationSettingsApi] 조회 성공 — 응답 body: ${res.data}");

      return NotificationSettingsResponse.fromJson(res.data);
    } on DioException catch (e) {
      debugPrint(
          "🔴 [NotificationSettingsApi] 조회 실패 — statusCode: ${e.response?.statusCode}");
      debugPrint("🔴 [NotificationSettingsApi] 조회 실패 — 응답 body: ${e.response?.data}");

      final message =
      e.response?.data is Map ? e.response?.data["message"] : null;
      throw Exception(message ?? "알림 설정 조회 실패 (${e.response?.statusCode})");
    }
  }

  // FCM 푸시 수신 여부 변경
  /// PATCH /api/members/me/notification-settings
  static Future<NotificationSettingsResponse> updateSettings({
    required bool fcmPushEnabled,
  }) async {
    final accessToken = await ServerTokenManager.getAccessToken();

    if (accessToken == null || accessToken.isEmpty) {
      throw Exception("인증이 필요합니다. 다시 로그인해주세요.");
    }

    debugPrint(
        "📤 [NotificationSettingsApi] 변경 요청 — fcmPushEnabled=$fcmPushEnabled");

    try {
      final res = await _dio.patch(
        "/api/members/me/notification-settings",
        data: {
          "fcmPushEnabled": fcmPushEnabled,
        },
        options: Options(
          headers: {"Authorization": "Bearer $accessToken"},
        ),
      );

      debugPrint("✅ [NotificationSettingsApi] 변경 성공 — 응답 body: ${res.data}");

      return NotificationSettingsResponse.fromJson(res.data);
    } on DioException catch (e) {
      debugPrint(
          "🔴 [NotificationSettingsApi] 변경 실패 — statusCode: ${e.response?.statusCode}");
      debugPrint("🔴 [NotificationSettingsApi] 변경 실패 — 응답 body: ${e.response?.data}");

      final message =
      e.response?.data is Map ? e.response?.data["message"] : null;
      throw Exception(message ?? "알림 설정 변경 실패 (${e.response?.statusCode})");
    }
  }
}