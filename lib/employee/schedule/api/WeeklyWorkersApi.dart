import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../../../common/auth/server_token_manager.dart';
import '../models/WeeklyWorkersResponse.dart';
import 'employee_schedule_error.dart';

class WeeklyWorkersApi {
  final Dio dio;

  WeeklyWorkersApi({Dio? dio}) : dio = dio ?? ServerTokenManager.authorizedDio;

  /// 전체 근무자 주간 확정 근무표 조회
  ///
  /// GET
  /// /api/work-places/{workPlaceId}/confirmed-schedules/weekly-workers
  Future<WeeklyWorkersResponse> getWeeklyWorkers({
    required int workPlaceId,
    required DateTime weekStartDate,
  }) async {
    String fmt(DateTime d) =>
        "${d.year.toString().padLeft(4, '0')}-"
        "${d.month.toString().padLeft(2, '0')}-"
        "${d.day.toString().padLeft(2, '0')}";

    try {
      final res = await dio.get(
        "/api/work-places/$workPlaceId/confirmed-schedules/weekly-workers",
        queryParameters: {"weekStartDate": fmt(weekStartDate)},
      );

      return WeeklyWorkersResponse.fromJson(res.data);
    } on DioException catch (e) {
      debugPrint(
        "🔴 [WeeklyWorkersApi] ${e.response?.statusCode}"
        " ${e.response?.data}",
      );

      if (e.response?.statusCode == 401 ||
          e.error is AuthSessionExpiredException) {
        throw const EmployeeScheduleException("로그인이 만료됐어요. 다시 로그인해주세요.");
      }
      throw const EmployeeScheduleException(
        "전체 근무표를 불러오지 못했어요. 잠시 후 다시 시도해주세요.",
      );
    }
  }
}
