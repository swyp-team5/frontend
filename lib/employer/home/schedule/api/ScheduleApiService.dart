import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../common/auth/server_token_manager.dart';
import '../models/ScheduleCondition.dart';
import '../models/LatestScheduleCondition.dart';

class ScheduleApiService {
  static const _baseUrl = "https://chackchack.shop";

  /// SharedPreferences에 저장할 때 사용하는 key
  static const String activeWeekScheduleIdKey = "activeWeekScheduleId";

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

      final result = ScheduleConditionResponse.fromJson(res.data);

      await _saveActiveWeekScheduleId(result.weekScheduleId);

      return result;
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

      debugPrint("📥 서버 원본 응답: ${res.data}");

      final result = LatestScheduleResponse.fromJson(res.data);

      await _saveActiveWeekScheduleId(result.weekScheduleId);

      return result;
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        await _clearActiveWeekScheduleId();
        return null;
      }

      final message = e.response?.data is Map
          ? e.response?.data["message"]
          : null;

      throw Exception(
        message ?? "최근 스케줄 조회 실패 (${e.response?.statusCode})",
      );
    }
  }

  /// 스케줄 삭제
  static Future<void> deleteScheduleCondition({
    required int workPlaceId,
    required int weekScheduleId,
  }) async {
    final token = await ServerTokenManager.getAccessToken();

    if (token == null || token.isEmpty) {
      throw Exception("인증이 필요합니다. 다시 로그인해주세요.");
    }

    final dio = Dio();

    try {
      await dio.delete(
        "$_baseUrl/api/work-places/$workPlaceId/schedule-conditions/$weekScheduleId",
        options: Options(
          headers: {
            "Authorization": "Bearer $token",
          },
        ),
      );

      final prefs = await SharedPreferences.getInstance();
      final cachedId = prefs.getInt(activeWeekScheduleIdKey);
      if (cachedId == weekScheduleId) {
        await _clearActiveWeekScheduleId();
      }
    } on DioException catch (e) {
      final code = e.response?.data is Map ? e.response?.data["code"] : null;
      final message = e.response?.data is Map ? e.response?.data["message"] : null;

      throw Exception(
        message ?? "스케줄 삭제 실패 (${e.response?.statusCode ?? code})",
      );
    }
  }

  /// weekScheduleId를 SharedPreferences에 저장
  static Future<void> _saveActiveWeekScheduleId(int weekScheduleId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(activeWeekScheduleIdKey, weekScheduleId);
  }

  /// weekScheduleId 로컬 캐시 제거
  static Future<void> _clearActiveWeekScheduleId() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(activeWeekScheduleIdKey);
  }
}