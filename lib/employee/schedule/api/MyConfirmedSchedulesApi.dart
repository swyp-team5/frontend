import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../../../common/auth/server_token_manager.dart';
import '../models/MyConfirmedSchedulesResponse.dart';
import 'employee_schedule_error.dart';

class MyConfirmedSchedulesApi {
  final Dio dio;

  MyConfirmedSchedulesApi({Dio? dio})
    : dio = dio ?? ServerTokenManager.authorizedDio;

  /// 내 확정 근무표 조회
  /// GET /api/me/confirmed-schedules?from={from}&to={to}
  Future<MyConfirmedSchedulesResponse> getMyConfirmedSchedules({
    required DateTime from,
    required DateTime to,
  }) async {
    String fmt(DateTime d) =>
        "${d.year.toString().padLeft(4, '0')}-"
        "${d.month.toString().padLeft(2, '0')}-"
        "${d.day.toString().padLeft(2, '0')}";

    try {
      final res = await dio.get(
        "/api/me/confirmed-schedules",
        queryParameters: {"from": fmt(from), "to": fmt(to)},
      );

      return MyConfirmedSchedulesResponse.fromJson(res.data);
    } on DioException catch (e) {
      debugPrint("🔴 [MyConfirmedSchedulesApi] 실패: ${e.response?.data}");
      if (e.response?.statusCode == 401 ||
          e.error is AuthSessionExpiredException) {
        throw const EmployeeScheduleException("로그인이 만료됐어요. 다시 로그인해주세요.");
      }
      throw const EmployeeScheduleException(
        "내 근무표를 불러오지 못했어요. 잠시 후 다시 시도해주세요.",
      );
    }
  }
}
