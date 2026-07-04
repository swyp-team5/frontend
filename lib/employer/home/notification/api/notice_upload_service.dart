import 'dart:io';
import 'dart:typed_data';
import 'package:dio/dio.dart';

class NoticeUploadService {
  final Dio dio;

  NoticeUploadService(this.dio);

  /// 파일의 실제 바이트(매직 넘버)를 읽어 진짜 이미지 포맷을 판별한다.
  /// 파일 확장자는 신뢰하지 않는다 (갤러리 캐시 경로 확장자가 실제 포맷과 다를 수 있음).
  String _detectContentType(Uint8List bytes) {
    // PNG: 89 50 4E 47
    if (bytes.length >= 4 &&
        bytes[0] == 0x89 &&
        bytes[1] == 0x50 &&
        bytes[2] == 0x4E &&
        bytes[3] == 0x47) {
      return 'image/png';
    }

    // JPEG: FF D8 FF
    if (bytes.length >= 3 &&
        bytes[0] == 0xFF &&
        bytes[1] == 0xD8 &&
        bytes[2] == 0xFF) {
      return 'image/jpeg';
    }

    // WEBP: 'RIFF' .... 'WEBP'
    if (bytes.length >= 12 &&
        bytes[0] == 0x52 && // R
        bytes[1] == 0x49 && // I
        bytes[2] == 0x46 && // F
        bytes[3] == 0x46 && // F
        bytes[8] == 0x57 && // W
        bytes[9] == 0x45 && // E
        bytes[10] == 0x42 && // B
        bytes[11] == 0x50) { // P
      return 'image/webp';
    }

    throw Exception("지원하지 않는 이미지 형식입니다. (JPG, PNG, WEBP만 가능)");
  }

  String _extensionFor(String contentType) {
    switch (contentType) {
      case 'image/png':
        return 'png';
      case 'image/webp':
        return 'webp';
      case 'image/jpeg':
      default:
        return 'jpg';
    }
  }

  /// 1. 공지 이미지 업로드 URL 발급
  /// POST /api/work-places/{workPlaceId}/notice-images/upload-url
  Future<Map<String, dynamic>> getUploadUrl({
    required int workPlaceId,
    required String token,
    required File file,
  }) async {
    final bytes = await file.readAsBytes();
    final fileSize = bytes.length;

    if (fileSize <= 0 || fileSize > 10 * 1024 * 1024) {
      throw Exception("이미지 크기는 10MB 이하여야 합니다.");
    }

    // 실제 바이트로 포맷 판별 → contentType, 확장자를 항상 일치시켜서 생성
    final contentType = _detectContentType(bytes);
    final extension = _extensionFor(contentType);
    final normalizedFileName = "notice_image.$extension";

    try {
      final response = await dio.post(
        "/api/work-places/$workPlaceId/notice-images/upload-url",
        options: Options(
          headers: {
            "Authorization": "Bearer $token",
            "Content-Type": "application/json",
          },
        ),
        data: {
          "originalFileName": normalizedFileName,
          "contentType": contentType,
          "fileSize": fileSize,
        },
      );

      return Map<String, dynamic>.from(response.data);
    } on DioException catch (e) {
      final message =
      e.response?.data is Map ? e.response?.data["message"] : null;
      throw Exception(
          message ?? "이미지 업로드 URL 발급 실패 (${e.response?.statusCode})");
    }
  }

  /// 2. 발급받은 presigned URL로 S3에 직접 PUT 업로드
  /// 주의: 여기엔 백엔드 JWT를 넣지 않는다. 응답의 headers만 그대로 전달한다.
  Future<void> uploadImageToS3({
    required Map<String, dynamic> uploadInfo,
    required File file,
  }) async {
    final String uploadUrl = uploadInfo["uploadUrl"];
    final Map<String, dynamic> headers =
    Map<String, dynamic>.from(uploadInfo["headers"] ?? {});

    final bytes = await file.readAsBytes();
    final s3Dio = Dio();

    try {
      await s3Dio.put(
        uploadUrl,
        data: Stream.fromIterable([bytes]),
        options: Options(
          headers: {
            ...headers,
            Headers.contentLengthHeader: bytes.length,
          },
        ),
      );
    } on DioException catch (e) {
      throw Exception("이미지 업로드(S3) 실패: ${e.message}");
    }
  }
}