import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../../../../common/auth/server_token_manager.dart';
import '../models/ConfirmedSchedulesResponse.dart';

class ConfirmedSchedulesApi {
  static const _baseUrl = "https://chackchack.shop";

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

    String fmt(DateTime d) =>
        "${d.year.toString().padLeft(4, '0')}-"
            "${d.month.toString().padLeft(2, '0')}-"
            "${d.day.toString().padLeft(2, '0')}";

    final dio = Dio();

    try {
      final res = await dio.get(
        "$_baseUrl/api/work-places/$workPlaceId/confirmed-schedules",
        queryParameters: {
          "from": fmt(from),
          "to": fmt(to),
        },
        options: Options(headers: {"Authorization": "Bearer $token"}),
      );

      return ConfirmedSchedulesResponse.fromJson(res.data);
    } on DioException catch (e) {
      debugPrint("🔴 [ConfirmedSchedulesApi] 실패: ${e.response?.data}");
      final message =
      e.response?.data is Map ? e.response?.data["message"] : null;
      throw Exception(message ?? "확정 근무표 조회 실패 (${e.response?.statusCode})");
    }
  }
}