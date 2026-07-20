import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../../../common/auth/server_token_manager.dart';
import '../model/ConfirmedSchedule.dart';

/// GET /api/me/confirmed-schedules 연동
///
/// 지난 확정 근무, 이번 주 진행 중 일정, 다음 주 확정 일정 모두
/// from/to 범위만 바꿔서 이 API 하나로 조회한다.
class ScheduleApi {
  static final Dio _dio = ServerTokenManager.authorizedDio;

  static Future<ConfirmedScheduleResponse> fetchConfirmedSchedules({
    required DateTime from,
    required DateTime to,
  }) async {
    final token = await ServerTokenManager.getValidAccessToken();

    if (token == null || token.isEmpty) {
      // 로그인 세션이 끊긴 경우. 재로그인 유도가 필요하면 여기서 처리.
      throw Exception("로그인이 필요합니다. 다시 로그인해주세요.");
    }

    final fromStr = _formatDate(from);
    final toStr = _formatDate(to);

    if (kDebugMode) {
      debugPrint(
        "[ScheduleApi] GET /api/me/confirmed-schedules?from=$fromStr&to=$toStr",
      );
    }

    try {
      final response = await _dio.get(
        "/api/me/confirmed-schedules",
        queryParameters: {
          "from": fromStr,
          "to": toStr,
        },
        options: Options(
          headers: {
            "Authorization": "Bearer $token",
          },
        ),
      );

      if (kDebugMode) {
        debugPrint(
          "[ScheduleApi] status=${response.statusCode} body=${response.data}",
        );
      }

      return ConfirmedScheduleResponse.fromJson(
        response.data as Map<String, dynamic>,
      );
    } on DioException catch (e) {
      debugPrint("===== ScheduleApi DioException =====");
      debugPrint("status = ${e.response?.statusCode}");
      debugPrint("body = ${e.response?.data}");

      final status = e.response?.statusCode;

      if (status == 401 || status == 403) {
        throw Exception("인증이 만료됐습니다. 다시 로그인해주세요.");
      }

      if (status == 404) {
        throw Exception("요청 경로를 찾을 수 없습니다 (status: 404).");
      }

      throw Exception(
        "확정 근무 일정 조회 실패 (status: $status, body: ${e.response?.data})",
      );
    }
  }

  /// DateTime -> "yyyy-MM-dd"
  static String _formatDate(DateTime date) {
    final y = date.year.toString().padLeft(4, '0');
    final m = date.month.toString().padLeft(2, '0');
    final d = date.day.toString().padLeft(2, '0');
    return "$y-$m-$d";
  }
}
