import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../../auth/server_token_manager.dart';
import '../model/AlarmResponse.dart';

// 알림함(Alarm) 조회 API
// - "공지사항(Notice)" API(notice_api.dart 등)와는 별개 도메인이라 이름을 Alarm으로 구분했다.
// - 본인 알림만 대상이며, 9.4(단건 읽음) / 9.5(전체 읽음) / 9.6(테스트 푸시)는
//   이후 단계에서 이 클래스에 메서드로 이어서 추가한다.
class AlarmApi {

  // 알림함 커서 기반 목록 조회
  // - cursorId를 넘기면 그보다 작은 알림부터 조회한다 (notification_id DESC 정렬).
  // - 첫 페이지는 cursorId 없이 호출하면 된다.
  /// GET /api/notifications?cursorId=&size=
  static Future<AlarmPageResponse> getList({
    int? cursorId,
    int size = 20,
  }) async {
    final accessToken = await ServerTokenManager.getValidAccessToken();

    if (accessToken == null || accessToken.isEmpty) {
      throw Exception("인증이 필요합니다. 다시 로그인해주세요.");
    }

    debugPrint("📤 [AlarmApi] 목록 조회 — cursorId=$cursorId, size=$size");

    try {
      final res = await ServerTokenManager.authorizedDio.get(
        "/api/notifications",
        queryParameters: {
          if (cursorId != null) "cursorId": cursorId,
          "size": size,
        },
      );

      debugPrint("✅ [AlarmApi] 목록 조회 성공 — 응답 body: ${res.data}");

      return AlarmPageResponse.fromJson(res.data);
    } on DioException catch (e) {
      debugPrint("🔴 [AlarmApi] 목록 조회 실패 — statusCode: ${e.response?.statusCode}");
      debugPrint("🔴 [AlarmApi] 목록 조회 실패 — 응답 body: ${e.response?.data}");

      final message =
      e.response?.data is Map ? e.response?.data["message"] : null;
      throw Exception(message ?? "알림함 조회 실패 (${e.response?.statusCode})");
    }
  }

  // 알림 단건 읽음 처리
  // - 이미 읽은 알림이면 서버가 기존 readAt을 그대로 유지한 채 응답한다.
  // - 다른 회원의 알림 ID를 넘기면 서버가 존재 자체를 노출하지 않고 404를 내려준다.
  /// PATCH /api/notifications/{notificationId}/read
  static Future<AlarmItem> readOne({
    required int notificationId,
  }) async {
    final accessToken = await ServerTokenManager.getValidAccessToken();

    if (accessToken == null || accessToken.isEmpty) {
      throw Exception("인증이 필요합니다. 다시 로그인해주세요.");
    }

    debugPrint("📤 [AlarmApi] 단건 읽음 처리 — notificationId=$notificationId");

    try {
      final res = await ServerTokenManager.authorizedDio.patch(
        "/api/notifications/$notificationId/read",
      );

      debugPrint("✅ [AlarmApi] 단건 읽음 처리 성공 — 응답 body: ${res.data}");

      return AlarmItem.fromJson(res.data);
    } on DioException catch (e) {
      debugPrint(
          "🔴 [AlarmApi] 단건 읽음 처리 실패 — statusCode: ${e.response?.statusCode}");
      debugPrint("🔴 [AlarmApi] 단건 읽음 처리 실패 — 응답 body: ${e.response?.data}");

      final message =
      e.response?.data is Map ? e.response?.data["message"] : null;
      throw Exception(message ?? "알림 읽음 처리 실패 (${e.response?.statusCode})");
    }
  }

  // 전체 알림 읽음 처리
  // - 본인의 미읽음 활성 알림만 대상이며, 다른 회원의 알림에는 영향을 주지 않는다.
  // - 응답 바디가 없으므로(204 No Content) 별도 파싱 없이 성공 여부만 처리한다.
  /// PATCH /api/notifications/read-all
  static Future<void> readAll() async {
    final accessToken = await ServerTokenManager.getValidAccessToken();

    if (accessToken == null || accessToken.isEmpty) {
      throw Exception("인증이 필요합니다. 다시 로그인해주세요.");
    }

    debugPrint("📤 [AlarmApi] 전체 읽음 처리 요청");

    try {
      final res = await ServerTokenManager.authorizedDio.patch(
        "/api/notifications/read-all",
      );

      debugPrint("✅ [AlarmApi] 전체 읽음 처리 성공 — statusCode: ${res.statusCode}");
    } on DioException catch (e) {
      debugPrint(
          "🔴 [AlarmApi] 전체 읽음 처리 실패 — statusCode: ${e.response?.statusCode}");
      debugPrint("🔴 [AlarmApi] 전체 읽음 처리 실패 — 응답 body: ${e.response?.data}");

      final message =
      e.response?.data is Map ? e.response?.data["message"] : null;
      throw Exception(message ?? "전체 읽음 처리 실패 (${e.response?.statusCode})");
    }
  }

}