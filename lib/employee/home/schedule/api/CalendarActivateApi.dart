import 'package:dio/dio.dart';
import '../../../../common/auth/server_token_manager.dart';
import '../models/CalendarActivate.dart';

class CalendarActivateApi {
  static const _baseUrl = "https://chackchack.shop";

  /// GET /api/work-places/{workPlaceId}/schedule-conditions/calendar-activate
  static Future<CalendarActivateResponse> getCalendarActivate({
    required int workPlaceId,
  }) async {
    final token = await ServerTokenManager.getAccessToken();

    if (token == null || token.isEmpty) {
      throw Exception("인증이 필요합니다. 다시 로그인해주세요.");
    }

    final dio = Dio();

    try {
      final res = await dio.get(
        "$_baseUrl/api/work-places/$workPlaceId/schedule-conditions/calendar-activate",
        options: Options(
          headers: {"Authorization": "Bearer $token"},
        ),
      );

      return CalendarActivateResponse.fromJson(res.data);
    } on DioException catch (e) {
      final message =
      e.response?.data is Map ? e.response?.data["message"] : null;
      throw Exception(message ?? "캘린더 정보 조회 실패 (${e.response?.statusCode})");
    }
  }
}