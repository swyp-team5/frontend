import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import '../../../../common/auth/server_token_manager.dart';
import '../models/SchedulePreviewResponse.dart';

class SchedulePreviewApi {
  static final Dio _dio = Dio(
    BaseOptions(baseUrl: "https://chackchack.shop"),
  );

  /// GET /api/work-places/{workPlaceId}/week-schedules/{weekScheduleId}/schedule-generation-runs/{runId}/preview
  static Future<SchedulePreviewResponse> getPreview({
    required int workPlaceId,
    required int weekScheduleId,
    required int runId,
  }) async {
    final url =
        "/api/work-places/$workPlaceId/week-schedules/$weekScheduleId/schedule-generation-runs/$runId/preview";

    debugPrint("📤 [SchedulePreviewApi] 요청 URL: ${_dio.options.baseUrl}$url");
    debugPrint(
        "📤 [SchedulePreviewApi] 파라미터: workPlaceId=$workPlaceId, weekScheduleId=$weekScheduleId, runId=$runId");

    final token = await ServerTokenManager.getAccessToken();

    try {
      final response = await _dio.get(
        url,
        options: Options(
          headers: {
            "Authorization": "Bearer $token",
          },
        ),
      );

      debugPrint("🟢 [SchedulePreviewApi] 성공 — statusCode: ${response.statusCode}");
      debugPrint("🟢 [SchedulePreviewApi] 응답 body: ${response.data}");

      final result = SchedulePreviewResponse.fromJson(response.data);

      debugPrint(
          "🟢 [SchedulePreviewApi] 파싱 완료 — candidateCount=${result.candidateCount}, candidates=${result.candidates.length}개");

      return result;
    } on DioException catch (e) {
      debugPrint("🔴 [SchedulePreviewApi] 실패 — statusCode: ${e.response?.statusCode}");
      debugPrint("🔴 [SchedulePreviewApi] 실패 — 응답 body: ${e.response?.data}");

      final message =
      e.response?.data is Map ? e.response?.data["message"] : null;
      throw Exception(message ?? "스케줄 미리보기 조회 실패 (${e.response?.statusCode})");
    } catch (e, stackTrace) {
      debugPrint("🔴 [SchedulePreviewApi] 알 수 없는 예외: $e");
      debugPrint("🔴 [SchedulePreviewApi] 스택트레이스: $stackTrace");
      rethrow;
    }
  }
}