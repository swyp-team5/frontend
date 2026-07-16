import 'package:dio/dio.dart';
import '../../../../common/auth/server_token_manager.dart';
import '../models/ConfirmedWeekScheduleResponse.dart';

class ConfirmedWeekScheduleApi {
  /// 시안 확정
  /// POST /api/work-places/{workPlaceId}/week-schedules/{weekScheduleId}/confirmed-week-schedules
  static Future<ConfirmedWeekScheduleResponse> confirm({
    required int workPlaceId,
    required int weekScheduleId,
    required int scheduleGenerationRunId,
    required int schedulePreviewId,
    required int selectedCandidateNo,
  }) async {
    final token = await ServerTokenManager.getValidAccessToken();

    if (token == null || token.isEmpty) {
      throw Exception("인증이 필요합니다. 다시 로그인해주세요.");
    }

    try {
      final res = await ServerTokenManager.authorizedDio.post(
        "/api/work-places/$workPlaceId/week-schedules/$weekScheduleId/confirmed-week-schedules",
        data: {
          "scheduleGenerationRunId": scheduleGenerationRunId,
          "schedulePreviewId": schedulePreviewId,
          "selectedCandidateNo": selectedCandidateNo,
        },
      );

      return ConfirmedWeekScheduleResponse.fromJson(res.data);
    } on DioException catch (e) {
      final message =
      e.response?.data is Map ? e.response?.data["message"] : null;
      throw Exception(message ?? "시안 확정 실패 (${e.response?.statusCode})");
    }
  }
}