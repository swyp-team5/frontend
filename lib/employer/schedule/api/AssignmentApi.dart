import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../../../../common/auth/server_token_manager.dart';
import '../models/AssignmentCreateRequest.dart';
import '../models/AssignmentCreateResponse.dart';
import '../models/AssignmentUpdateResponse.dart';
import '../models/class AssignmentUpdateRequest.dart';

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
      debugPrint("🔴 [AssignmentApi.create] status = ${e.response?.statusCode}");
      debugPrint("🔴 [AssignmentApi.create] full response = ${e.response?.data}");

      final message = e.response?.data is Map
          ? e.response?.data["message"]
          : null;

      throw Exception(
        message ?? "근무 추가 실패 (${e.response?.statusCode})",
      );
    }
  }

  /// PUT /api/work-places/{workPlaceId}/confirmed-week-schedules/{confirmedWeekScheduleId}/time-details/{timeDetailId}/assignments
  static Future<AssignmentUpdateResponse> update({
    required int workPlaceId,
    required int confirmedWeekScheduleId,
    required int timeDetailId,
    required AssignmentUpdateRequest request,
  }) async {
    final token = await ServerTokenManager.getAccessToken();

    if (token == null || token.isEmpty) {
      throw Exception("로그인이 필요합니다.");
    }

    final dio = Dio();

    try {
      final response = await dio.put(
        "$_baseUrl/api/work-places/$workPlaceId/confirmed-week-schedules/$confirmedWeekScheduleId/time-details/$timeDetailId/assignments",
        data: request.toJson(),
        options: Options(
          headers: {
            "Authorization": "Bearer $token",
          },
        ),
      );

      return AssignmentUpdateResponse.fromJson(response.data);
    } on DioException catch (e) {
      debugPrint("🔴 [AssignmentApi.update] status = ${e.response?.statusCode}");
      debugPrint("🔴 [AssignmentApi.update] full response = ${e.response?.data}");
      debugPrint("🔴 [AssignmentApi.update] request path = "
          "/api/work-places/$workPlaceId/confirmed-week-schedules/$confirmedWeekScheduleId"
          "/time-details/$timeDetailId/assignments");

      final message = e.response?.data is Map
          ? e.response?.data["message"]
          : null;

      throw Exception(
        message ?? "근무 수정 실패 (${e.response?.statusCode})",
      );
    }
  }
}