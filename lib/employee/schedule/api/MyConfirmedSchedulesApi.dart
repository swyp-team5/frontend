import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../../../common/auth/server_token_manager.dart';
import '../models/MyConfirmedSchedulesResponse.dart';

class MyConfirmedSchedulesApi {
  static const _baseUrl = "https://chackchack.shop";

  /// 내 확정 근무표 조회
  /// GET /api/me/confirmed-schedules?from={from}&to={to}
  static Future<MyConfirmedSchedulesResponse> getMyConfirmedSchedules({
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
        "$_baseUrl/api/me/confirmed-schedules",
        queryParameters: {
          "from": fmt(from),
          "to": fmt(to),
        },
        options: Options(headers: {"Authorization": "Bearer $token"}),
      );

      return MyConfirmedSchedulesResponse.fromJson(res.data);
    } on DioException catch (e) {
      debugPrint("🔴 [MyConfirmedSchedulesApi] 실패: ${e.response?.data}");
      final message =
      e.response?.data is Map ? e.response?.data["message"] : null;
      throw Exception(message ?? "내 확정 근무표 조회 실패 (${e.response?.statusCode})");
    }
  }
}