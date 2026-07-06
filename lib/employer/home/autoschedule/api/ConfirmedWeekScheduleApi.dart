import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import '../../../../common/auth/server_token_manager.dart';
import '../models/ConfirmedWeekScheduleResponse.dart';

class ConfirmedWeekScheduleApi {
  static final Dio _dio = Dio(
    BaseOptions(baseUrl: "https://chackchack.shop"),
  );

  /// POST /api/work-places/{workPlaceId}/week-schedules/{weekScheduleId}/confirmed-week-schedules
  static Future<ConfirmedWeekScheduleResponse> confirm({
    required int workPlaceId,
    required int weekScheduleId,
    required int scheduleGenerationRunId,
    required int schedulePreviewId,
    required int selectedCandidateNo,
  }) async {
    final url =
        "/api/work-places/$workPlaceId/week-schedules/$weekScheduleId/confirmed-week-schedules";

    final requestBody = {
      "scheduleGenerationRunId": scheduleGenerationRunId,
      "schedulePreviewId": schedulePreviewId,
      "selectedCandidateNo": selectedCandidateNo,
    };

    debugPrint("📤 [ConfirmedWeekScheduleApi] 요청 URL: ${_dio.options.baseUrl}$url");
    debugPrint("📤 [ConfirmedWeekScheduleApi] 요청 body: $requestBody");

    final token = await ServerTokenManager.getAccessToken();

    try {
      final response = await _dio.post(
        url,
        options: Options(
          headers: {
            "Authorization": "Bearer $token",
            "Content-Type": "application/json",
          },
        ),
        data: requestBody,
      );

      debugPrint("🟢 [ConfirmedWeekScheduleApi] 성공 — statusCode: ${response.statusCode}");
      debugPrint("🟢 [ConfirmedWeekScheduleApi] 응답 body: ${response.data}");

      return ConfirmedWeekScheduleResponse.fromJson(response.data);
    } on DioException catch (e) {
      debugPrint("🔴 [ConfirmedWeekScheduleApi] 실패 — statusCode: ${e.response?.statusCode}");
      debugPrint("🔴 [ConfirmedWeekScheduleApi] 실패 — 응답 body: ${e.response?.data}");

      final message =
      e.response?.data is Map ? e.response?.data["message"] : null;
      throw Exception(message ?? "스케줄 확정 실패 (${e.response?.statusCode})");
    } catch (e, stackTrace) {
      debugPrint("🔴 [ConfirmedWeekScheduleApi] 알 수 없는 예외: $e");
      debugPrint("🔴 [ConfirmedWeekScheduleApi] 스택트레이스: $stackTrace");
      rethrow;
    }
  }
}