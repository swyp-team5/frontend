import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../../../../common/auth/server_token_manager.dart';
import '../models/AssignmentCreateRequest.dart';
import '../models/AssignmentCreateResponse.dart';
import '../models/AssignmentUpdateResponse.dart';
import '../models/DeleteAssignmentResponse.dart';
import '../models/AssignmentUpdateRequest.dart';

class AssignmentApi {
  static Future<AssignmentCreateResponse> create({
    required int workPlaceId,
    required int confirmedWeekScheduleId,
    required AssignmentCreateRequest request,
  }) async {
    try {
      final response = await ServerTokenManager.authorizedDio.post(
        "/api/work-places/$workPlaceId/confirmed-week-schedules/$confirmedWeekScheduleId/assignments",
        data: request.toJson(),
      );

      return AssignmentCreateResponse.fromJson(response.data);
    } on DioException catch (e) {
      debugPrint("🔴 [AssignmentApi.create] status = ${e.response?.statusCode}");
      debugPrint("🔴 [AssignmentApi.create] full response = ${e.response?.data}");

      throw Exception(_createErrorMessage(e.response?.statusCode));
    }
  }

  // 서버가 내려주는 raw 메시지/코드 대신, 사용자가 이해하기 쉬운 문구로 바꿔서 보여준다.
  static String _createErrorMessage(int? statusCode) {
    switch (statusCode) {
      case 400:
        return "근무 시간이나 근무자 정보를 다시 확인해주세요.";
      case 401:
        return "로그인이 만료됐어요. 다시 로그인해주세요.";
      case 403:
        return "이 사업장에 근무를 추가할 권한이 없어요.";
      case 404:
        return "선택한 날짜에는 아직 확정된 스케줄이 없어요.";
      default:
        return "근무 추가에 실패했어요. 잠시 후 다시 시도해주세요.";
    }
  }

  /// PUT /api/work-places/{workPlaceId}/confirmed-week-schedules/{confirmedWeekScheduleId}/time-details/{timeDetailId}/assignments
  static Future<AssignmentUpdateResponse> update({
    required int workPlaceId,
    required int confirmedWeekScheduleId,
    required int timeDetailId,
    required AssignmentUpdateRequest request,
  }) async {
    try {
      final response = await ServerTokenManager.authorizedDio.put(
        "/api/work-places/$workPlaceId/confirmed-week-schedules/$confirmedWeekScheduleId/time-details/$timeDetailId/assignments",
        data: request.toJson(),
      );

      return AssignmentUpdateResponse.fromJson(response.data);
    } on DioException catch (e) {
      debugPrint("🔴 [AssignmentApi.update] status = ${e.response?.statusCode}");
      debugPrint("🔴 [AssignmentApi.update] full response = ${e.response?.data}");
      debugPrint("🔴 [AssignmentApi.update] request path = "
          "/api/work-places/$workPlaceId/confirmed-week-schedules/$confirmedWeekScheduleId"
          "/time-details/$timeDetailId/assignments");

      throw Exception(_updateErrorMessage(e.response?.statusCode));
    }
  }

  // 서버가 내려주는 raw 메시지/코드 대신, 사용자가 이해하기 쉬운 문구로 바꿔서 보여준다.
  static String _updateErrorMessage(int? statusCode) {
    switch (statusCode) {
      case 400:
        return "근무 시간이나 근무자 정보를 다시 확인해주세요.";
      case 401:
        return "로그인이 만료됐어요. 다시 로그인해주세요.";
      case 403:
        return "이 근무를 수정할 권한이 없어요.";
      case 404:
        return "수정하려는 근무 정보를 찾을 수 없어요. 새로고침 후 다시 시도해주세요.";
      default:
        return "근무 수정에 실패했어요. 잠시 후 다시 시도해주세요.";
    }
  }

  /// DELETE /api/work-places/{workPlaceId}/confirmed-week-schedules/{confirmedWeekScheduleId}/time-details/{timeDetailId}/assignments
  static Future<DeleteAssignmentResponse> delete({
    required int workPlaceId,
    required int confirmedWeekScheduleId,
    required int timeDetailId,
  }) async {
    try {
      final response = await ServerTokenManager.authorizedDio.delete(
        "/api/work-places/$workPlaceId/confirmed-week-schedules/$confirmedWeekScheduleId/time-details/$timeDetailId/assignments",
      );

      return DeleteAssignmentResponse.fromJson(response.data);
    } on DioException catch (e) {
      debugPrint("🔴 [AssignmentApi.delete] status = ${e.response?.statusCode}");
      debugPrint("🔴 [AssignmentApi.delete] full response = ${e.response?.data}");

      final message = e.response?.data is Map
          ? e.response?.data["message"]
          : null;

      throw Exception(
        message ?? "근무 삭제 실패 (${e.response?.statusCode})",
      );
    }
  }
}