import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';

class ProfileApi {
  final Dio dio;

  ProfileApi(this.dio);

  Future<Map<String, dynamic>> getUploadUrl({
    required String token,
    required File file,
  }) async {
    final fileName = file.path.split('/').last;
    final fileSize = await file.length();

    final ext = file.path.split('.').last.toLowerCase();

    // 명세서 15.3: 확장자와 contentType이 반드시 일치해야 하므로,
    // 알 수 없는 확장자를 무조건 jpeg로 우기지 않고 명확히 실패시킨다.
    final String contentType;
    switch (ext) {
      case "jpg":
      case "jpeg":
        contentType = "image/jpeg";
        break;
      case "png":
        contentType = "image/png";
        break;
      case "webp":
        contentType = "image/webp";
        break;
      default:
        throw Exception("지원하지 않는 이미지 형식이에요. (jpg, png, webp만 가능)");
    }

    final response = await dio.post(
      "/api/members/me/profile-image/upload-url",
      data: {
        "originalFileName": fileName,
        "contentType": contentType,
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

  Future<void> uploadToS3({
    required String uploadUrl,
    required Map<String, String> headers,
    required List<int> bytes,
  }) async {
    await Dio().put(
      uploadUrl,
      data: bytes,
      options: Options(
        headers: headers,
        responseType: ResponseType.plain,
      ),
    );
  }

  Future<Map<String, dynamic>> getMyProfile({
    required String token,
  }) async {
    final response = await dio.get(
      "/api/members/me/profile",
      options: Options(
        headers: {
          "Authorization": "Bearer $token",
        },
      ),
    );

    return response.data;
  }


  Future<Map<String, dynamic>> updateProfileImage({
    required String token,
    required String objectKey,
  }) async {
    final response = await dio.put(
      "/api/members/me/profile-image",
      data: {
        "objectKey": objectKey,
      },
      options: Options(
        headers: {
          "Authorization": "Bearer $token",
        },
      ),
    );

    return response.data;
  }

  Future<void> updateProfile({
    required String token,
    required String name,
    required String phoneNumber,
  }) async {

    debugPrint("PATCH TOKEN = $token");

    final response = await dio.patch(
      "/api/members/me/profile",
      data: {
        "name": name,
        "phoneNumber": phoneNumber,
      },
      options: Options(
        headers: {
          "Authorization": "Bearer $token",
        },
      ),
    );

    debugPrint(response.data.toString());
  }

  Future<void> deleteProfileImage({
    required String token,
  }) async {
    await dio.delete(
      "/api/members/me/profile-image",
      options: Options(
        headers: {
          "Authorization": "Bearer $token",
        },
      ),
    );
  }
}