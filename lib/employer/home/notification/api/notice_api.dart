import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import '../RNotificationModel.dart'; // NoticeModel 경로에 맞게 수정

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

  /// 공지 단건 조회
  /// GET /api/notices/{noticeId}
  Future<NoticeModel> getNoticeDetail({
    required int noticeId,
    required String accessToken,
  }) async {
    debugPrint("getNoticeDetail 요청: noticeId=$noticeId");

    try {
      final response = await dio.get(
        "/api/notices/$noticeId",
        options: Options(
          headers: {
            "Authorization": "Bearer $accessToken",
          },
        ),
      );

      debugPrint("getNoticeDetail 응답: ${response.data}");

      return NoticeModel.fromJson(response.data);
    } on DioException catch (e) {
      debugPrint("🔴 getNoticeDetail 실패: ${e.response?.statusCode} / ${e.response?.data}");
      final message =
      e.response?.data is Map ? e.response?.data["message"] : null;
      throw Exception(message ?? "공지 조회 실패 (${e.response?.statusCode})");
    }
  }

  /// 공지 수정
  /// PATCH /api/notices/{noticeId}
  /// ⚠️ 요청 body 필드는 POST 등록 스펙과 동일하다고 가정했습니다.
  /// 실제 PATCH 스펙이 다르면 이 부분만 맞춰서 수정하면 됩니다.
  Future<NoticeModel> updateNotice({
    required int noticeId,
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

    debugPrint("updateNotice 요청 body: $requestBody");

    try {
      final response = await dio.patch(
        "/api/notices/$noticeId",
        options: Options(
          headers: {
            "Authorization": "Bearer $accessToken",
            "Content-Type": "application/json",
          },
        ),
        data: requestBody,
      );

      debugPrint("updateNotice 응답: ${response.data}");

      return NoticeModel.fromJson(response.data);
    } on DioException catch (e) {
      debugPrint("🔴 updateNotice 실패: ${e.response?.statusCode} / ${e.response?.data}");
      final message =
      e.response?.data is Map ? e.response?.data["message"] : null;
      throw Exception(message ?? "공지 수정 실패 (${e.response?.statusCode})");
    }
  }
}