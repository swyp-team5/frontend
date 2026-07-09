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
      final message =
      e.response?.data is Map ? e.response?.data["message"] : null;
      throw Exception(message ?? "확정 근무표 조회 실패 (${e.response?.statusCode})");
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

      return ConfirmedWeeklyScheduleResponse.fromJson(res.data);
    } on DioException catch (e) {
      debugPrint("🔴 [ConfirmedSchedulesApi.getConfirmedWeeklySchedule] 실패: ${e.response?.data}");
      final message =
      e.response?.data is Map ? e.response?.data["message"] : null;
      throw Exception(message ?? "주간 확정 근무표 조회 실패 (${e.response?.statusCode})");
    }
  }
}