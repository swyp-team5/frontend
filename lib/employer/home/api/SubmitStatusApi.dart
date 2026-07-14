import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../../../../common/auth/server_token_manager.dart';
import '../model/SubmitStatus.dart';

class SubmitStatusApi {
  static const _baseUrl = "https://chackchack.shop";

  /// GET /api/work-places/{workPlaceId}/week-schedules/{weekScheduleId}/worker-select/status
  /// 권한: OWNER
  static Future<SubmitStatusResponse> getStatus({
    required int workPlaceId,
    required int weekScheduleId,
  }) async {
    final token = await ServerTokenManager.getAccessToken();

    if (token == null || token.isEmpty) {
      throw Exception("인증이 필요합니다. 다시 로그인해주세요.");
    }

    final url =
        "$_baseUrl/api/work-places/$workPlaceId/week-schedules/$weekScheduleId/worker-select/status";

    debugPrint("📤 [worker-select/status] 요청 URL: $url");

    final dio = Dio();

    try {
      final res = await dio.get(
        url,
        options: Options(
          headers: {"Authorization": "Bearer $token"},
        ),
      );

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

  // 근무 불가 제출 반려 — 반려되면 서버에서 해당 근무자의 제출 데이터가
  // 물리 삭제되므로, 성공하면 프론트도 그 근무자를 "미제출"로 취급하면 된다.
  /// POST /api/work-places/{workPlaceId}/week-schedules/{weekScheduleId}/worker-select/{memberId}/reject
  /// 권한: OWNER
  static Future<void> rejectSubmission({
    required int workPlaceId,
    required int weekScheduleId,
    required int memberId,
  }) async {
    final token = await ServerTokenManager.getAccessToken();

    if (token == null || token.isEmpty) {
      throw Exception("인증이 필요합니다. 다시 로그인해주세요.");
    }

    final url =
        "$_baseUrl/api/work-places/$workPlaceId/week-schedules/$weekScheduleId/worker-select/$memberId/reject";

    debugPrint("📤 [worker-select/reject] 요청 URL: $url");

    final dio = Dio();

    try {
      final res = await dio.post(
        url,
        options: Options(
          headers: {"Authorization": "Bearer $token"},
        ),
      );

      debugPrint("✅ [worker-select/reject] 성공 — statusCode: ${res.statusCode}");
      debugPrint("✅ [worker-select/reject] 응답 body: ${res.data}");
    } on DioException catch (e) {
      debugPrint("🔴 [worker-select/reject] 실패 — statusCode: ${e.response?.statusCode}");
      debugPrint("🔴 [worker-select/reject] 실패 — 응답 body: ${e.response?.data}");

      throw Exception(_rejectErrorMessage(e));
    }
  }

  // 17-3 명세서의 "주요 에러" 표를 기준으로 상태코드별 메시지를 구분한다.
  // - 404가 4가지 케이스(사업장/스케줄/근무자/제출 정보)로 나뉘는데, 상태코드만으로는
  //   구분이 안 되므로 서버가 내려주는 message를 우선 사용한다.
  // - 서버 응답에 message가 없거나 파싱 실패 시에만 상태코드 기준 기본 문구로 대체한다.
  static String _rejectErrorMessage(DioException e) {
    final statusCode = e.response?.statusCode;
    final data = e.response?.data;
    final serverMessage = data is Map ? data["message"]?.toString() : null;

    if (serverMessage != null && serverMessage.isNotEmpty) {
      return serverMessage;
    }

    switch (statusCode) {
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