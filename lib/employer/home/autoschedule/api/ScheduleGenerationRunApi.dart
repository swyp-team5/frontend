import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../../../../common/auth/server_token_manager.dart';
import '../models/ScheduleGenerationRun.dart';

/// 서버 message를 분석해 어떤 원인/액션으로 안내해야 할지 구분하기 위한 타입
enum ScheduleGenerationGuidance {
  checkSubmitStatus,            // 제출 완료 근무자가 없음 → 제출 현황 확인
  fixMinMaxCount,                // 최소 근무 횟수 > 최대 근무 횟수
  adjustRequiredOrMin,           // 필요 근무 횟수 vs 최소 횟수 합계 불일치 (2가지 메시지 공통)
  reduceRequiredOrIncreaseMax,   // 필요 근무 횟수가 최대 횟수 합계 초과
  checkUnavailableSlot,          // 특정 시간대에 필요 인원 배정 불가
  checkMemberUnavailable,        // 특정 근무자가 최소 근무 횟수를 채울 수 없음
  reviewUnavailableWithMax,      // 근무 불가 조건 + 최대 근무 횟수로 슬롯을 못 채움
  simplifyCondition,             // 탐색 한도 초과
  reviewAllConditions,           // 최소/최대 + 근무 불가 조건을 동시 만족하는 조합 없음
  unknown,                       // 매칭 안 되는 메시지 (신규/변경 대비)
}

/// 조건을 만족하는 스케줄 후보가 없을 때(409 / code 4005) 던지는 전용 예외
class NoScheduleCandidateException implements Exception {
  final String message;
  final ScheduleGenerationGuidance guidance;

  NoScheduleCandidateException(this.message)
      : guidance = _resolveGuidance(message);

  static ScheduleGenerationGuidance _resolveGuidance(String message) {
    if (message.contains("제출 완료 근무자가 없습니다")) {
      return ScheduleGenerationGuidance.checkSubmitStatus;
    }
    if (message.contains("최소 근무 횟수가 최대 근무 횟수보다 큽니다")) {
      return ScheduleGenerationGuidance.fixMinMaxCount;
    }
    if (message.contains("전체 필요 근무 횟수가 근무자별 최소 근무 횟수 합계보다 적습니다") ||
        message.contains("전체 근무 슬롯 수가 근무자별 최소 근무 횟수 합계보다 적습니다")) {
      return ScheduleGenerationGuidance.adjustRequiredOrMin;
    }
    if (message.contains("전체 필요 근무 횟수가 근무자별 최대 근무 횟수 합계를 초과합니다")) {
      return ScheduleGenerationGuidance.reduceRequiredOrIncreaseMax;
    }
    if (message.contains("시간대에 필요한 인원을 배정할 수 없습니다")) {
      return ScheduleGenerationGuidance.checkUnavailableSlot;
    }
    if (RegExp(r"근무자 \d+번은 근무 불가 조건").hasMatch(message)) {
      return ScheduleGenerationGuidance.checkMemberUnavailable;
    }
    if (message.contains("근무자별 최대 근무 횟수 안에서 모든 슬롯을 채울 수 없습니다")) {
      return ScheduleGenerationGuidance.reviewUnavailableWithMax;
    }
    if (message.contains("탐색 한도를 초과했습니다")) {
      return ScheduleGenerationGuidance.simplifyCondition;
    }
    if (message.contains("동시에 만족하는 조합이 없습니다")) {
      return ScheduleGenerationGuidance.reviewAllConditions;
    }
    return ScheduleGenerationGuidance.unknown;
  }

  /// UI에 보여줄 안내 문구 (서버 message + 액션 가이드 결합)
  String get guidanceText {
    switch (guidance) {
      case ScheduleGenerationGuidance.checkSubmitStatus:
        return "$message\n근무자 제출 현황을 확인해주세요.";
      case ScheduleGenerationGuidance.fixMinMaxCount:
        return "$message\n스케줄 조건의 최소/최대 근무 횟수를 확인해주세요.";
      case ScheduleGenerationGuidance.adjustRequiredOrMin:
        return "$message\n필요 근무 인원 또는 최소 근무 횟수를 조정해주세요.";
      case ScheduleGenerationGuidance.reduceRequiredOrIncreaseMax:
        return "$message\n필요 근무 인원을 줄이거나 최대 근무 횟수를 늘려주세요.";
      case ScheduleGenerationGuidance.checkUnavailableSlot:
        return "$message\n해당 시간대의 근무 불가 제출 또는 필요 인원을 확인해주세요.";
      case ScheduleGenerationGuidance.checkMemberUnavailable:
        return "$message\n해당 근무자의 근무 불가 제출 또는 최소 근무 횟수를 확인해주세요.";
      case ScheduleGenerationGuidance.reviewUnavailableWithMax:
        return "$message\n근무 불가 제출, 필요 인원, 최대 근무 횟수를 확인해주세요.";
      case ScheduleGenerationGuidance.simplifyCondition:
        return "$message\n근무 시간대나 필요 인원을 줄여 조건을 단순화해주세요.";
      case ScheduleGenerationGuidance.reviewAllConditions:
        return "$message\n전체 스케줄 조건을 다시 검토해주세요.";
      case ScheduleGenerationGuidance.unknown:
        return message;
    }
  }

  @override
  String toString() => message;
}

class ScheduleGenerationRunApi {
  /// POST /api/work-places/{workPlaceId}/week-schedules/{weekScheduleId}/schedule-generation-runs
  /// 사장(OWNER)만 호출 가능
  static Future<ScheduleGenerationRunResponse> generate({
    required int workPlaceId,
    required int weekScheduleId,
  }) async {
    final token = await ServerTokenManager.getValidAccessToken();

    if (token == null || token.isEmpty) {
      throw Exception("인증이 필요합니다. 다시 로그인해주세요.");
    }

    final url =
        "/api/work-places/$workPlaceId/week-schedules/$weekScheduleId/schedule-generation-runs";

    debugPrint("📤 [schedule-generation-runs] 요청 URL: $url");

    try {
      final res = await ServerTokenManager.authorizedDio.post(url);

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
        final exception = NoScheduleCandidateException(
          message ?? "조건을 만족하는 스케줄 후보가 없습니다.",
        );

        debugPrint(
            "🟠 [schedule-generation-runs] 후보 없음 — guidance=${exception.guidance}");
        debugPrint(
            "🟠 [schedule-generation-runs] 안내 문구: ${exception.guidanceText}");

        throw exception;
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
    final token = await ServerTokenManager.getValidAccessToken();

    if (token == null || token.isEmpty) {
      throw Exception("인증이 필요합니다. 다시 로그인해주세요.");
    }

    final url =
        "/api/work-places/$workPlaceId/week-schedules/$weekScheduleId/schedule-generation-runs/regenerate";

    debugPrint("📤 [schedule-generation-runs/regenerate] 요청 URL: $url");

    try {
      final res = await ServerTokenManager.authorizedDio.post(url);

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
        final exception = NoScheduleCandidateException(
          message ?? "조건을 만족하는 스케줄 후보가 없습니다.",
        );

        debugPrint(
            "🟠 [schedule-generation-runs/regenerate] 후보 없음 — guidance=${exception.guidance}");
        debugPrint(
            "🟠 [schedule-generation-runs/regenerate] 안내 문구: ${exception.guidanceText}");

        throw exception;
      }

      throw Exception(
        message ?? "스케줄 재생성 실패 (${e.response?.statusCode ?? code})",
      );
    }
  }
}