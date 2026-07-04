import 'package:dio/dio.dart';
import '../../../../common/auth/server_token_manager.dart';
import '../models/DayTimeDetails.dart';

class DayTimeDetailsApi {
  static const _baseUrl = "https://chackchack.shop";

  /// 특정 주(week) + 특정 날짜(date)의 근무 시간대 조회
  /// GET /api/work-places/{workPlaceId}/week-schedules/{weekScheduleId}/days/{date}/time-details
  static Future<DayTimeDetailsResponse> getDayTimeDetails({
    required int workPlaceId,
    required int weekScheduleId,
    required DateTime date,
  }) async {
    final token = await ServerTokenManager.getAccessToken();

    if (token == null || token.isEmpty) {
      throw Exception("인증이 필요합니다. 다시 로그인해주세요.");
    }

    final dateStr =
        "${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";

    final dio = Dio();

    try {
      final res = await dio.get(
        "$_baseUrl/api/work-places/$workPlaceId/week-schedules/$weekScheduleId/days/$dateStr/time-details",
        options: Options(
          headers: {"Authorization": "Bearer $token"},
        ),
      );

      return DayTimeDetailsResponse.fromJson(res.data);
    } on DioException catch (e) {
      final message =
      e.response?.data is Map ? e.response?.data["message"] : null;
      throw Exception(message ?? "근무 시간대 조회 실패 (${e.response?.statusCode})");
    }
  }
}