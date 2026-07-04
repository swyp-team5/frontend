import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';

class NoticeApi {
  final Dio dio;

  NoticeApi(this.dio);

  /// 공지 등록
  /// POST /api/work-places/{workPlaceId}/notices
  Future<Response> createNotice({
    required int workPlaceId,
    required String accessToken,
    required String title,
    required String content,
    required bool representative,
    required List<String> imageObjectKeys,
  }) async {
    final requestBody = {
      "title": title,
      "content": content,
      "representative": representative,
      "imageObjectKeys": imageObjectKeys,
    };

    debugPrint("createNotice 요청 body: $requestBody");

    try {
      final response = await dio.post(
        "/api/work-places/$workPlaceId/notices",
        options: Options(
          headers: {
            "Authorization": "Bearer $accessToken",
            "Content-Type": "application/json",
          },
        ),
        data: requestBody,
      );

      debugPrint("createNotice 응답: ${response.data}");

      return response;
    } on DioException catch (e) {
      debugPrint("🔴 createNotice 실패: ${e.response?.statusCode} / ${e.response?.data}");
      final message =
      e.response?.data is Map ? e.response?.data["message"] : null;
      throw Exception(message ?? "공지 등록 실패 (${e.response?.statusCode})");
    }
  }
}