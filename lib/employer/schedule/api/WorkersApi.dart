import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../../../../common/auth/server_token_manager.dart';
import '../models/WorkersResponse.dart';

class WorkersApi {
  /// 근무자 조회
  static Future<WorkersResponse> getWorkers({
    required int workPlaceId,
  }) async {
    final token = await ServerTokenManager.getValidAccessToken();

    debugPrint("========== Workers API ==========");
    debugPrint("workPlaceId : $workPlaceId");
    debugPrint("token exists : ${token != null}");
    debugPrint("token empty : ${token?.isEmpty}");
    debugPrint("request url : /api/work-places/$workPlaceId/crews");

    if (token == null || token.isEmpty) {
      throw Exception("인증이 필요합니다. 다시 로그인해주세요.");
    }

    try {
      final res = await ServerTokenManager.authorizedDio.get(
        "/api/work-places/$workPlaceId/crews",
      );

      debugPrint("========== Response ==========");
      debugPrint("statusCode : ${res.statusCode}");
      debugPrint("response data :");
      debugPrint(res.data.toString());

      final workersResponse = WorkersResponse.fromJson(res.data);

      debugPrint("========== Parsed ==========");
      debugPrint("worker count : ${workersResponse.workers.length}");

      for (final worker in workersResponse.workers) {
        debugPrint(
          "memberId=${worker.memberId}, "
              "memberName=${worker.memberName}, "
              "submitted=${worker.submitted}",
        );
      }

      return workersResponse;
    } on DioException catch (e) {
      debugPrint("========== Dio Error ==========");
      debugPrint("status : ${e.response?.statusCode}");
      debugPrint("data : ${e.response?.data}");
      debugPrint("message : ${e.message}");

      final message =
      e.response?.data is Map ? e.response?.data["message"] : null;

      throw Exception(
        message ?? "근무자 조회 실패 (${e.response?.statusCode})",
      );
    } catch (e, stack) {
      debugPrint("========== Parsing Error ==========");
      debugPrint(e.toString());
      debugPrint(stack.toString());
      rethrow;
    }
  }
}