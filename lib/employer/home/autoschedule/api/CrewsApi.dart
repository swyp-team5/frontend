import 'package:dio/dio.dart';
import '../../../../common/auth/server_token_manager.dart';
import '../models/Crew.dart';

class CrewsApi {
  static const _baseUrl = "https://chackchack.shop";

  /// GET /api/work-places/{workPlaceId}/crews
  static Future<CrewsResponse> getCrews({required int workPlaceId}) async {
    final token = await ServerTokenManager.getAccessToken();

    if (token == null || token.isEmpty) {
      throw Exception("인증이 필요합니다. 다시 로그인해주세요.");
    }

    final dio = Dio();

    try {
      final res = await dio.get(
        "$_baseUrl/api/work-places/$workPlaceId/crews",
        options: Options(
          headers: {"Authorization": "Bearer $token"},
        ),
      );

      return CrewsResponse.fromJson(res.data);
    } on DioException catch (e) {
      final message =
      e.response?.data is Map ? e.response?.data["message"] : null;
      throw Exception(
        message ?? "직원 목록 조회 실패 (${e.response?.statusCode})",
      );
    }
  }
}