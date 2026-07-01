import 'dart:io';
import 'package:dio/dio.dart';

class NoticeUploadService {
  final Dio dio;

  NoticeUploadService(this.dio);

  Future<Map<String, dynamic>> getUploadUrl({
    required int workPlaceId,
    required String token,
    required File file,
  }) async {
    final fileName = file.path.split('/').last;
    final fileSize = await file.length();

    final response = await dio.post(
      "/api/work-places/$workPlaceId/notice-images/upload-url",
      data: {
        "originalFileName": fileName,
        "contentType": "image/png",
        "fileSize": fileSize,
      },
      options: Options(
        headers: {
          "Authorization": "Bearer $token",
        },
      ),
    );

    return response.data;
  }

  Future<void> uploadImageToS3({
    required Map<String, dynamic> uploadInfo,
    required File file,
  }) async {
    final uploadUrl = uploadInfo["uploadUrl"];

    final headers = Map<String, dynamic>.from(
      uploadInfo["headers"] ?? {},
    );

    final bytes = await file.readAsBytes();

    await Dio().put(
      uploadUrl,
      data: bytes,
      options: Options(
        headers: headers,
        contentType: headers["Content-Type"],
      ),
    );
  }
}