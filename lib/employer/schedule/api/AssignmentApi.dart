import 'package:dio/dio.dart';

import '../../../../common/auth/server_token_manager.dart';
import '../models/AssignmentCreateRequest.dart';
import '../models/AssignmentCreateResponse.dart';

class AssignmentApi {
  static const _baseUrl = "https://chackchack.shop";

  static Future<AssignmentCreateResponse> create({
    required int workPlaceId,
    required int confirmedWeekScheduleId,
    required AssignmentCreateRequest request,
  }) async {
    final token = await ServerTokenManager.getAccessToken();

    if (token == null || token.isEmpty) {
      throw Exception("로그인이 필요합니다.");
    }

    final dio = Dio();

    try {
      final response = await dio.post(
        "$_baseUrl/api/work-places/$workPlaceId/confirmed-week-schedules/$confirmedWeekScheduleId/assignments",
        data: request.toJson(),
        options: Options(
          headers: {
            "Authorization": "Bearer $token",
          },
        ),
      );

      return AssignmentCreateResponse.fromJson(response.data);
    } on DioException catch (e) {
      final message = e.response?.data is Map
          ? e.response?.data["message"]
          : null;

      throw Exception(
        message ?? "근무 추가 실패 (${e.response?.statusCode})",
      );
    }
  }
}