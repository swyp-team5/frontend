import 'package:dio/dio.dart';
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

    final dio = Dio();

    final response = await dio.get(
      "$_baseUrl/api/work-places/$workPlaceId/confirmed-schedules/work-change-targets",
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
  }
}