import 'package:dio/dio.dart';
import '../../../../common/auth/server_token_manager.dart';
import '../models/ScheduleCondition.dart';
import 'package:dio/dio.dart';
import '../models/LatestScheduleCondition.dart';

class ScheduleApiService {
  static const _baseUrl = "https://chackchack.shop";

  static Future<ScheduleConditionResponse> postScheduleConditions({
    required int workPlaceId,
    required ScheduleConditionRequest body,
  }) async {
    final token = await ServerTokenManager.getAccessToken();

    if (token == null || token.isEmpty) {
      throw Exception("인증이 필요합니다. 다시 로그인해주세요.");
    }

    final dio = Dio();

    try {
      final res = await dio.post(
        "$_baseUrl/api/work-places/$workPlaceId/schedule-conditions",
        options: Options(
          headers: {
            "Authorization": "Bearer $token",
            "Content-Type": "application/json",
          },
        ),
        data: body.toJson(),
      );

      return ScheduleConditionResponse.fromJson(res.data);
    } on DioException catch (e) {
      final code = e.response?.data is Map ? e.response?.data["code"] : null;
      final message = e.response?.data is Map ? e.response?.data["message"] : null;

      throw Exception(
        message ?? "스케줄 등록 실패 (${e.response?.statusCode ?? code})",
      );
    }
  }

  /// 최근(최신) 스케줄 조회
  /// 등록된 스케줄이 없으면 null 반환 (404 처리)
  static Future<LatestScheduleResponse?> getLatestScheduleConditions({
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
          headers: {
            "Authorization": "Bearer $token",
          },
        ),
      );

      return LatestScheduleResponse.fromJson(res.data);
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        return null; // 저장된 최근 스케줄 없음
      }

      final message = e.response?.data is Map
          ? e.response?.data["message"]
          : null;

      throw Exception(
        message ?? "최근 스케줄 조회 실패 (${e.response?.statusCode})",
      );
    }
  }
}