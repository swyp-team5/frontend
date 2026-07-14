import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../../../../common/auth/server_token_manager.dart';
import '../model/WorkChangeTargetsResponse.dart';

class WorkChangeTargetsApi {
  static const _baseUrl = "https://chackchack.shop";

  static Future<WorkChangeTargetsResponse> fetchWorkers({
    required int workPlaceId,
    required String fromDate,
    required String toDate,
  }) async {
    final token = await ServerTokenManager.getAccessToken();

    if (token == null || token.isEmpty) {
      throw Exception("인증이 필요합니다. 다시 로그인해주세요.");
    }

    final url =
        "$_baseUrl/api/work-places/$workPlaceId/confirmed-schedules/work-change-targets";

    debugPrint("📤 [work-change-targets] 요청 URL: $url ($fromDate ~ $toDate)");

    final dio = Dio();

    try {
      final response = await dio.get(
        url,
        queryParameters: {
          "fromDate": fromDate,
          "toDate": toDate,
        },
        options: Options(
          headers: {
            "Authorization": "Bearer $token",
          },
        ),
      );

      return WorkChangeTargetsResponse.fromJson(response.data);
    } on DioException catch (e) {
      debugPrint("🔴 [work-change-targets] 실패 — statusCode: ${e.response?.statusCode}");
      debugPrint("🔴 [work-change-targets] 실패 — 응답 body: ${e.response?.data}");

      final data = e.response?.data;
      final serverMessage = data is Map ? data["message"]?.toString() : null;

      if (serverMessage != null && serverMessage.isNotEmpty) {
        throw Exception(serverMessage);
      }

      switch (e.response?.statusCode) {
        case 400:
          throw Exception("조회 기간이 올바르지 않습니다. (과거 날짜는 조회할 수 없어요)");
        case 401:
          throw Exception("인증 정보가 올바르지 않습니다. 다시 로그인해주세요.");
        case 403:
          throw Exception("근무자 권한이 없습니다.");
        case 404:
          throw Exception("사업장을 찾을 수 없거나, 승인된 크루가 아닙니다.");
        default:
          throw Exception("근무자 조회 실패 (${e.response?.statusCode})");
      }
    }
  }
}