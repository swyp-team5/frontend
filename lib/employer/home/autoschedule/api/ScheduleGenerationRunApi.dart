import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../../../../common/auth/server_token_manager.dart';
import '../models/ScheduleGenerationRun.dart';

class ScheduleGenerationRunApi {
  static const _baseUrl = "https://chackchack.shop";

  /// POST /api/work-places/{workPlaceId}/week-schedules/{weekScheduleId}/schedule-generation-runs
  /// 사장(OWNER)만 호출 가능
  static Future<ScheduleGenerationRunResponse> generate({
    required int workPlaceId,
    required int weekScheduleId,
  }) async {
    final token = await ServerTokenManager.getAccessToken();

    if (token == null || token.isEmpty) {
      throw Exception("인증이 필요합니다. 다시 로그인해주세요.");
    }

    final url =
        "$_baseUrl/api/work-places/$workPlaceId/week-schedules/$weekScheduleId/schedule-generation-runs";

    debugPrint("📤 [schedule-generation-runs] 요청 URL: $url");

    final dio = Dio();

    try {
      final res = await dio.post(
        url,
        options: Options(
          headers: {
            "Authorization": "Bearer $token",
            "Content-Type": "application/json",
          },
        ),
      );

      debugPrint("✅ [schedule-generation-runs] 성공 — statusCode: ${res.statusCode}");
      debugPrint("✅ [schedule-generation-runs] 응답 body: ${res.data}");

      final parsed = ScheduleGenerationRunResponse.fromJson(res.data);

      debugPrint(
          "✅ [schedule-generation-runs] 파싱 완료 — runId=${parsed.scheduleGenerationRunId}, previewId=${parsed.schedulePreviewId}, candidateCount=${parsed.candidateCount}, status=${parsed.status}");

      return parsed;
    } on DioException catch (e) {
      debugPrint(
          "🔴 [schedule-generation-runs] 실패 — statusCode: ${e.response?.statusCode}");
      debugPrint("🔴 [schedule-generation-runs] 실패 — 응답 body: ${e.response?.data}");

      final code = e.response?.data is Map ? e.response?.data["code"] : null;
      final message =
      e.response?.data is Map ? e.response?.data["message"] : null;

      throw Exception(
        message ?? "자동 스케줄 생성 실패 (${e.response?.statusCode ?? code})",
      );
    }
  }
}