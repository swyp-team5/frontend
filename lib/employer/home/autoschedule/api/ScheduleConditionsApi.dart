import 'package:dio/dio.dart';
import '../../../../common/auth/server_token_manager.dart';
import '../models/ScheduleConditionsLatestResponse.dart';

class ScheduleConditionsApi {
  static const _baseUrl = "https://chackchack.shop";

  /// GET /api/work-places/{workPlaceId}/schedule-conditions/latest
  static Future<ScheduleConditionsLatestResponse> getLatest({
    required int workPlaceId,
  }) async {
    final token = await ServerTokenManager.getAccessToken();

    if (token == null || token.isEmpty) {
      throw Exception("인증이 필요합니다. 다시 로그인해주세요.");
    }

    final dio = Dio();

    try {
      final res = await dio.get(
        "$_baseUrl/api/work-places/$workPlaceId/schedule-conditions/latest",
        options: Options(
          headers: {"Authorization": "Bearer $token"},
        ),
      );

      return ScheduleConditionsLatestResponse.fromJson(res.data);
    } on DioException catch (e) {
      final message =
      e.response?.data is Map ? e.response?.data["message"] : null;
      throw Exception(message ?? "스케줄 조건 조회 실패 (${e.response?.statusCode})");
    }
  }
}