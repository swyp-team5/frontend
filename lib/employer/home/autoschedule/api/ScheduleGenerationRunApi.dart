import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../../../../common/auth/server_token_manager.dart';
import '../models/ScheduleGenerationRun.dart';

/// 조건을 만족하는 스케줄 후보가 없을 때(409 / code 4005) 던지는 전용 예외
class NoScheduleCandidateException implements Exception {
  final String message;
  NoScheduleCandidateException(this.message);

  @override
  String toString() => message;
}

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

      final data = e.response?.data;
      final code = data is Map ? data["code"] : null;
      final message = data is Map ? data["message"] : null;

      debugPrint("🔍 [schedule-generation-runs] code 값=$code, 타입=${code.runtimeType}");

      if (e.response?.statusCode == 409 && code?.toString() == "4005") {
        throw NoScheduleCandidateException(
          message ?? "조건을 만족하는 스케줄 후보가 없습니다.",
        );
      }

      throw Exception(
        message ?? "자동 스케줄 생성 실패 (${e.response?.statusCode ?? code})",
      );
    }
  }

  /// POST /api/work-places/{workPlaceId}/week-schedules/{weekScheduleId}/schedule-generation-runs/regenerate
  /// 사장(OWNER)만 호출 가능
  static Future<ScheduleGenerationRunResponse> regenerate({
    required int workPlaceId,
    required int weekScheduleId,
  }) async {
    final token = await ServerTokenManager.getAccessToken();

    if (token == null || token.isEmpty) {
      throw Exception("인증이 필요합니다. 다시 로그인해주세요.");
    }

    final url =
        "$_baseUrl/api/work-places/$workPlaceId/week-schedules/$weekScheduleId/schedule-generation-runs/regenerate";

    debugPrint("📤 [schedule-generation-runs/regenerate] 요청 URL: $url");

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

      debugPrint(
          "✅ [schedule-generation-runs/regenerate] 성공 — statusCode: ${res.statusCode}");
      debugPrint(
          "✅ [schedule-generation-runs/regenerate] 응답 body: ${res.data}");

      final parsed = ScheduleGenerationRunResponse.fromJson(res.data);

      debugPrint(
          "✅ [schedule-generation-runs/regenerate] 파싱 완료 — runId=${parsed.scheduleGenerationRunId}, previewId=${parsed.schedulePreviewId}, candidateCount=${parsed.candidateCount}, status=${parsed.status}");

      return parsed;
    } on DioException catch (e) {
      debugPrint(
          "🔴 [schedule-generation-runs/regenerate] 실패 — statusCode: ${e.response?.statusCode}");
      debugPrint(
          "🔴 [schedule-generation-runs/regenerate] 실패 — 응답 body: ${e.response?.data}");

      final data = e.response?.data;
      final code = data is Map ? data["code"] : null;
      final message = data is Map ? data["message"] : null;

      debugPrint("🔍 [schedule-generation-runs/regenerate] code 값=$code, 타입=${code.runtimeType}");

      if (e.response?.statusCode == 409 && code?.toString() == "4005") {
        throw NoScheduleCandidateException(
          message ?? "조건을 만족하는 스케줄 후보가 없습니다.",
        );
      }

      throw Exception(
        message ?? "스케줄 재생성 실패 (${e.response?.statusCode ?? code})",
      );
    }
  }
}