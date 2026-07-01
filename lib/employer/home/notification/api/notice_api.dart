import 'package:dio/dio.dart';

class NoticeApi {
  final Dio dio;

  NoticeApi(this.dio);

  Future<int> getMyWorkPlaceId(String accessToken) async {
    final response = await dio.get(
      "/api/work-places/me",
      options: Options(
        headers: {
          "Authorization": "Bearer $accessToken",
        },
      ),
    );

    final list = response.data["workPlaces"] as List;

    if (list.isEmpty) {
      throw Exception("가입된 사업장이 없습니다.");
    }

    return list.first["workPlaceId"];
  }

  Future<Response> createNotice({
    required int workPlaceId,
    required String accessToken,
    required String title,
    required String content,
    required bool representative,
    required List<String> imageObjectKeys,
  }) {
    return dio.post(
      "/api/work-places/$workPlaceId/notices",
      options: Options(
        headers: {
          "Authorization": "Bearer $accessToken",
        },
      ),
      data: {
        "title": title,
        "content": content,
        "representative": representative,
        "imageObjectKeys": imageObjectKeys,
      },
    );
  }
}