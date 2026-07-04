import 'package:dio/dio.dart';

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
    try {
      final response = await dio.post(
        "/api/work-places/$workPlaceId/notices",
        options: Options(
          headers: {
            "Authorization": "Bearer $accessToken",
            "Content-Type": "application/json",
          },
        ),
        data: {
          "title": title,
          "content": content,
          "representative": representative,
          "imageObjectKeys": imageObjectKeys,
        },
      );

      return response;
    } on DioException catch (e) {
      final message =
      e.response?.data is Map ? e.response?.data["message"] : null;
      throw Exception(message ?? "공지 등록 실패 (${e.response?.statusCode})");
    }
  }
}