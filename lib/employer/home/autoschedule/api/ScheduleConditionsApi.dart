import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../../../../common/auth/server_token_manager.dart';
import '../models/ScheduleConditionsLatestResponse.dart';

class ScheduleConditionsApi {
  /// 최근 저장된 스케줄 조건(그룹별 근무 시간대) 조회
  /// GET /api/work-places/{workPlaceId}/schedule-conditions/latest
  static Future<ScheduleConditionsLatestResponse> getLatest({
    required int workPlaceId,
  }) async {
    final token = await ServerTokenManager.getValidAccessToken();

    if (token == null || token.isEmpty) {
      throw Exception("인증이 필요합니다. 다시 로그인해주세요.");
    }

    try {
      final res = await ServerTokenManager.authorizedDio.get(
        "/api/work-places/$workPlaceId/schedule-conditions/latest",
      );

      // ⭐ 원인 파악용: 실제 서버 응답을 그대로 출력
      debugPrint("=== schedule-conditions/latest raw response ===");
      debugPrint(res.data.toString());

      return ScheduleConditionsLatestResponse.fromJson(res.data);
    } on DioException catch (e) {
      final message =
      e.response?.data is Map ? e.response?.data["message"] : null;
      throw Exception(message ?? "스케줄 조건 조회 실패 (${e.response?.statusCode})");
    } catch (e, stack) {
      // ⭐ fromJson 파싱 단계에서 나는 에러를 여기서 한 번 더 잡아서 위치 확인
      debugPrint("=== schedule-conditions/latest 파싱 실패 ===");
      debugPrint("error: $e");
      debugPrint("stack: $stack");
      rethrow;
    }
  }

  /// 스케줄 조건 초기화
  /// DELETE /api/work-places/{workPlaceId}/schedule-conditions/{weekScheduleId}
  /// 성공 시 204 No Content
  static Future<void> resetConditions({
    required int workPlaceId,
    required int weekScheduleId,
  }) async {
    final token = await ServerTokenManager.getValidAccessToken();

    if (token == null || token.isEmpty) {
      throw Exception("인증이 필요합니다. 다시 로그인해주세요.");
    }

    final url =
        "/api/work-places/$workPlaceId/schedule-conditions/$weekScheduleId";

    debugPrint("📤 [schedule-conditions DELETE] 요청 URL: $url");

    try {
      final res = await ServerTokenManager.authorizedDio.delete(url);

      debugPrint(
          "✅ [schedule-conditions DELETE] 성공 — statusCode: ${res.statusCode}");

      if (res.statusCode != 204) {
        throw Exception("스케줄 조건 초기화 실패 (${res.statusCode})");
      }
    } on DioException catch (e) {
      debugPrint(
          "🔴 [schedule-conditions DELETE] 실패 — statusCode: ${e.response?.statusCode}");
      debugPrint("🔴 [schedule-conditions DELETE] 실패 — 응답 body: ${e.response?.data}");

      final message =
      e.response?.data is Map ? e.response?.data["message"] : null;
      throw Exception(
        message ?? "스케줄 조건 초기화 실패 (${e.response?.statusCode})",
      );
    }
  }
}