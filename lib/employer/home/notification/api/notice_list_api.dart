import 'package:dio/dio.dart';

class NoticeListApi {
  final Dio dio;

  NoticeListApi(this.dio);

  /// 공지 목록 조회
  /// GET /api/work-places/{workPlaceId}/notices?page={page}&size={size}
  Future<Map<String, dynamic>> getNotices({
    required int workPlaceId,
    int page = 0,
    int size = 20,
  }) async {
    try {
      final response = await dio.get(
        "/api/work-places/$workPlaceId/notices",
        queryParameters: {
          "page": page,
          "size": size,
        },
      );

      return Map<String, dynamic>.from(response.data);
    } on DioException catch (e) {
      final message =
      e.response?.data is Map ? e.response?.data["message"] : null;
      throw Exception(message ?? "공지 목록 조회 실패 (${e.response?.statusCode})");
    }
  }
}