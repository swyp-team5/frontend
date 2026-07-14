import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../../../../common/auth/server_token_manager.dart';
import '../models/ConfirmedSchedulesResponse.dart';
import '../models/ConfirmedWeeklyScheduleResponse.dart';

class ConfirmedSchedulesApi {
  static const _baseUrl = "https://chackchack.shop";

  static String _fmt(DateTime d) =>
      "${d.year.toString().padLeft(4, '0')}-"
          "${d.month.toString().padLeft(2, '0')}-"
          "${d.day.toString().padLeft(2, '0')}";

  /// 확정 근무표 조회 (사장 홈 / 주간·월간 화면 공통)
  /// GET /api/work-places/{workPlaceId}/confirmed-schedules?from={from}&to={to}
  static Future<ConfirmedSchedulesResponse> getConfirmedSchedules({
    required int workPlaceId,
    required DateTime from,
    required DateTime to,
  }) async {
    final token = await ServerTokenManager.getAccessToken();

    if (token == null || token.isEmpty) {
      throw Exception("인증이 필요합니다. 다시 로그인해주세요.");
    }

    final dio = Dio();

    try {
      final res = await dio.get(
        "$_baseUrl/api/work-places/$workPlaceId/confirmed-schedules",
        queryParameters: {
          "from": _fmt(from),
          "to": _fmt(to),
        },
        options: Options(headers: {"Authorization": "Bearer $token"}),
      );

      return ConfirmedSchedulesResponse.fromJson(res.data);
    } on DioException catch (e) {
      debugPrint("🔴 [ConfirmedSchedulesApi.getConfirmedSchedules] 실패: ${e.response?.data}");
      throw Exception(_errorMessage(e.response?.statusCode));
    }
  }

  // 서버가 내려주는 raw 메시지/코드 대신, 사용자가 이해하기 쉬운 문구로 바꿔서 보여준다.
  static String _errorMessage(int? statusCode) {
    switch (statusCode) {
      case 400:
        return "조회 기간이 올바르지 않아요.";
      case 401:
        return "로그인이 만료됐어요. 다시 로그인해주세요.";
      case 403:
        return "이 사업장의 스케줄을 조회할 권한이 없어요.";
      case 404:
        return "사업장 정보를 찾을 수 없어요.";
      default:
        return "확정 근무표를 불러오지 못했어요. 잠시 후 다시 시도해주세요.";
    }
  }

  /// 주간 확정 근무표 조회 (confirmedWeekScheduleId를 포함한 응답)
  /// GET /api/work-places/{workPlaceId}/confirmed-schedules/weekly?weekStartDate={weekStartDate}
  static Future<ConfirmedWeeklyScheduleResponse> getConfirmedWeeklySchedule({
    required int workPlaceId,
    required DateTime weekStartDate,
  }) async {
    final token = await ServerTokenManager.getAccessToken();

    if (token == null || token.isEmpty) {
      throw Exception("인증이 필요합니다. 다시 로그인해주세요.");
    }

    final dio = Dio();

    try {
      final res = await dio.get(
        "$_baseUrl/api/work-places/$workPlaceId/confirmed-schedules/weekly",
        queryParameters: {
          "weekStartDate": _fmt(weekStartDate),
        },
        options: Options(headers: {"Authorization": "Bearer $token"}),
      );

      // 🔍 임시 디버깅: 실제 서버 응답 원본을 확인
      debugPrint("🟢 [getConfirmedWeeklySchedule] weekStartDate=${_fmt(weekStartDate)}");
      debugPrint("🟢 [getConfirmedWeeklySchedule] raw response = ${res.data}");

      return ConfirmedWeeklyScheduleResponse.fromJson(res.data);
    } on DioException catch (e) {
      debugPrint("🔴 [ConfirmedSchedulesApi.getConfirmedWeeklySchedule] 실패: ${e.response?.data}");
      throw Exception(_errorMessage(e.response?.statusCode));
    }
  }
}