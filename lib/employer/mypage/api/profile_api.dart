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

    String contentType = "image/jpeg";

    if (ext == "png") {
      contentType = "image/png";
    } else if (ext == "webp") {
      contentType = "image/webp";
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