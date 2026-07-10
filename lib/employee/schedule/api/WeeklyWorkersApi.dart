import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../../../common/auth/server_token_manager.dart';
import '../models/WeeklyWorkersResponse.dart';

class WeeklyWorkersApi {
  static const _baseUrl = "https://chackchack.shop";

  /// 전체 근무자 주간 확정 근무표 조회
  ///
  /// GET
  /// /api/work-places/{workPlaceId}/confirmed-schedules/weekly-workers
  static Future<WeeklyWorkersResponse> getWeeklyWorkers({
    required int workPlaceId,
    required DateTime weekStartDate,
  }) async {
    final token = await ServerTokenManager.getAccessToken();

    if (token == null || token.isEmpty) {
      throw Exception("인증이 필요합니다.");
    }

    String fmt(DateTime d) =>
        "${d.year.toString().padLeft(4, '0')}-"
            "${d.month.toString().padLeft(2, '0')}-"
            "${d.day.toString().padLeft(2, '0')}";

    final dio = Dio();

    try {
      final res = await dio.get(
        "$_baseUrl/api/work-places/$workPlaceId/confirmed-schedules/weekly-workers",
        queryParameters: {
          "weekStartDate": fmt(weekStartDate),
        },
        options: Options(
          headers: {
            "Authorization": "Bearer $token",
          },
        ),
      );

      return WeeklyWorkersResponse.fromJson(res.data);
    } on DioException catch (e) {
      debugPrint(
        "🔴 [WeeklyWorkersApi] ${e.response?.statusCode}"
            " ${e.response?.data}",
      );

      final message =
      e.response?.data is Map<String, dynamic>
          ? e.response?.data["message"]
          : null;

      throw Exception(
        message ??
            "주간 전체 근무표 조회 실패 (${e.response?.statusCode})",
      );
    }
  }
}