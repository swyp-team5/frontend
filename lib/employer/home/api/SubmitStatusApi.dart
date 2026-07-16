import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../../../../common/auth/server_token_manager.dart';
import '../model/SubmitStatus.dart';

class SubmitStatusApi {
  /// GET /api/work-places/{workPlaceId}/week-schedules/{weekScheduleId}/worker-select/status
  /// 권한: OWNER
  static Future<SubmitStatusResponse> getStatus({
    required int workPlaceId,
    required int weekScheduleId,
  }) async {
    final token = await ServerTokenManager.getValidAccessToken();

    if (token == null || token.isEmpty) {
      throw Exception("인증이 필요합니다. 다시 로그인해주세요.");
    }

    final url =
        "/api/work-places/$workPlaceId/week-schedules/$weekScheduleId/worker-select/status";

    debugPrint("📤 [worker-select/status] 요청 URL: $url");

    try {
      final res = await ServerTokenManager.authorizedDio.get(url);

      debugPrint("✅ [worker-select/status] 성공 — statusCode: ${res.statusCode}");
      debugPrint("✅ [worker-select/status] 응답 body: ${res.data}");

      return SubmitStatusResponse.fromJson(res.data);
    } on DioException catch (e) {
      debugPrint("🔴 [worker-select/status] 실패 — statusCode: ${e.response?.statusCode}");
      debugPrint("🔴 [worker-select/status] 실패 — 응답 body: ${e.response?.data}");

      final code = e.response?.data is Map ? e.response?.data["code"] : null;
      final message =
      e.response?.data is Map ? e.response?.data["message"] : null;

      throw Exception(
        message ?? "제출 현황 조회 실패 (${e.response?.statusCode ?? code})",
      );
    }
  }

  /// POST /api/work-places/{workPlaceId}/week-schedules/{weekScheduleId}/worker-select/{memberId}/reject
  /// 권한: OWNER
  static Future<void> rejectSubmission({
    required int workPlaceId,
    required int weekScheduleId,
    required int memberId,
  }) async {
    final token = await ServerTokenManager.getValidAccessToken();

    if (token == null || token.isEmpty) {
      throw Exception("인증이 필요합니다. 다시 로그인해주세요.");
    }

    final url =
        "/api/work-places/$workPlaceId/week-schedules/$weekScheduleId/worker-select/$memberId/reject";

    debugPrint("📤 [worker-select/reject] 요청 URL: $url");

    try {
      final res = await ServerTokenManager.authorizedDio.post(url);

      debugPrint("✅ [worker-select/reject] 성공 — statusCode: ${res.statusCode}");
      debugPrint("✅ [worker-select/reject] 응답 body: ${res.data}");
    } on DioException catch (e) {
      debugPrint("🔴 [worker-select/reject] 실패 — statusCode: ${e.response?.statusCode}");
      debugPrint("🔴 [worker-select/reject] 실패 — 응답 body: ${e.response?.data}");

      throw Exception(_rejectErrorMessage(e));
    }
  }

  static String _rejectErrorMessage(DioException e) {
    final statusCode = e.response?.statusCode;
    final data = e.response?.data;
    final serverMessage = data is Map ? data["message"]?.toString() : null;

    if (serverMessage != null && serverMessage.isNotEmpty) {
      return serverMessage;
    }

    switch (statusCode) {
      case 400:
        return "스케줄이 생성되었거나 제출 마감 기한이 지났습니다.";
      case 401:
        return "인증 정보가 올바르지 않습니다. 다시 로그인해주세요.";
      case 403:
        return "권한이 없습니다.";
      case 404:
        return "요청한 정보를 찾을 수 없습니다. 사업장/스케줄/근무자/제출 정보를 다시 확인해주세요.";
      default:
        return "제출 반려 실패 (statusCode: $statusCode)";
    }
  }
}