import 'package:dio/dio.dart';
import '../../../../common/auth/server_token_manager.dart';
import '../models/WorkerImpossibleResponse.dart';

class WorkerImpossibleApi {
  static Future<WorkerImpossibleResponse> postWorkerSelect({
    required int workPlaceId,
    required int weekScheduleId,
    required List<int> timeDetails,
  }) async {
    final token = await ServerTokenManager.getValidAccessToken();

    if (token == null || token.isEmpty) {
      throw Exception("인증이 필요합니다. 다시 로그인해주세요.");
    }

    final requestBody = {
      "weekScheduleId": weekScheduleId,
      "timeDetails": timeDetails,
    };

    final url = "/api/work-places/$workPlaceId/worker-select";

    debugPrintCompat("📤 [worker-select] 요청 URL: $url");
    debugPrintCompat("📤 [worker-select] 요청 body: $requestBody");

    try {
      final res = await ServerTokenManager.authorizedDio.post(
        url,
        data: requestBody,
      );

      debugPrintCompat("✅ [worker-select] 응답 상태코드: ${res.statusCode}");
      debugPrintCompat("✅ [worker-select] 응답 body: ${res.data}");

      final parsed = WorkerImpossibleResponse.fromJson(res.data);

      debugPrintCompat(
          "✅ [worker-select] 파싱 완료 — workPlaceId=${parsed.workPlaceId}, memberId=${parsed.memberId}, timeDetails=${parsed.timeDetails.length}개");

      return parsed;
    } on DioException catch (e) {
      debugPrintCompat("🔴 [worker-select] 실패 — statusCode: ${e.response?.statusCode}");
      debugPrintCompat("🔴 [worker-select] 실패 — 응답 body: ${e.response?.data}");

      final code = e.response?.data is Map ? e.response?.data["code"] : null;
      final message =
      e.response?.data is Map ? e.response?.data["message"] : null;

      throw Exception(
        message ?? "스케줄 제출 실패 (${e.response?.statusCode ?? code})",
      );
    }
  }
}

void debugPrintCompat(String message) {
  // ignore: avoid_print
  print(message);
}