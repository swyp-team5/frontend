import 'package:dio/dio.dart';
import '../../../../common/auth/server_token_manager.dart';
import '../models/ConfirmedWeekScheduleResponse.dart';

class ConfirmedWeekScheduleApi {
  static const _baseUrl = "https://chackchack.shop";

  /// 시안 확정
  /// POST /api/work-places/{workPlaceId}/week-schedules/{weekScheduleId}/confirmed-week-schedules
  static Future<ConfirmedWeekScheduleResponse> confirm({
    required int workPlaceId,
    required int weekScheduleId,
    required int scheduleGenerationRunId,
    required int schedulePreviewId,
    required int selectedCandidateNo,
  }) async {
    final token = await ServerTokenManager.getAccessToken();

    if (token == null || token.isEmpty) {
      throw Exception("인증이 필요합니다. 다시 로그인해주세요.");
    }

    final dio = Dio();

    try {
      final res = await dio.post(
        "$_baseUrl/api/work-places/$workPlaceId/week-schedules/$weekScheduleId/confirmed-week-schedules",
        data: {
          "scheduleGenerationRunId": scheduleGenerationRunId,
          "schedulePreviewId": schedulePreviewId,
          "selectedCandidateNo": selectedCandidateNo,
        },
        options: Options(headers: {"Authorization": "Bearer $token"}),
      );

      return ConfirmedWeekScheduleResponse.fromJson(res.data);
    } on DioException catch (e) {
      final message =
      e.response?.data is Map ? e.response?.data["message"] : null;
      throw Exception(message ?? "시안 확정 실패 (${e.response?.statusCode})");
    }
  }
}