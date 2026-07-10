import 'package:dio/dio.dart';

import '../../../common/auth/server_token_manager.dart';
import '../model/WorkChangeRequestResponse.dart';

class WorkChangeRequestApi {
  static const String _baseUrl = "https://chackchack.shop";

  final Dio _dio = Dio(
    BaseOptions(baseUrl: _baseUrl),
  );

  Future<WorkChangeRequestResponse> requestShiftSwap({
    required int workPlaceId,
    required int requestAssignmentId,
    required int targetAssignmentId,
    required String reason,
  }) async {
    final token = await ServerTokenManager.getValidAccessToken();

    if (token == null) {
      throw Exception("로그인 정보가 만료되었습니다. 다시 로그인해주세요.");
    }

    try {
      final response = await _dio.post(
        "/api/work-places/$workPlaceId/work-change-requests/shift-swap",
        data: {
          "requestAssignmentId": requestAssignmentId,
          "targetAssignmentId": targetAssignmentId,
          "reason": reason,
        },
        options: Options(
          headers: {
            "Authorization": "Bearer $token",
          },
        ),
      );

      return WorkChangeRequestResponse.fromJson(response.data);
    } on DioException catch (e) {
      final data = e.response?.data;
      final message = (data is Map && data["message"] != null)
          ? data["message"].toString()
          : "교대 신청에 실패했습니다.";
      throw Exception(message);
    }
  }
}