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
}