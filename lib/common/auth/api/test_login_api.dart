import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../model/social_auth_models.dart';

class TestLoginException implements Exception {
  final String message;
  final int? statusCode;

  const TestLoginException(this.message, {this.statusCode});

  @override
  String toString() => message;
}

abstract class TestLoginClient {
  Future<AuthResponse> login({
    required String loginId,
    required String password,
    required DevicePayload device,
  });
}

class TestLoginApi implements TestLoginClient {
  static const _fallbackMessage = '로그인에 실패했어요.';

  final http.Client client;
  final String baseUrl;

  TestLoginApi({http.Client? client, this.baseUrl = 'https://chackchack.shop'})
      : client = client ?? http.Client();

  @override
  Future<AuthResponse> login({
    required String loginId,
    required String password,
    required DevicePayload device,
  }) async {
    try {
      final response = await client
          .post(
        Uri.parse('$baseUrl/api/auth/test-login'),
        headers: const {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'loginId': loginId,
          'password': password,
          'device': device.toJson(),
        }),
      )
          .timeout(const Duration(seconds: 10));

      final body = _decodeObject(response);

      debugPrint(
        '[TestLogin][Backend] status=${response.statusCode} '
            'result=${body?['status'] ?? body?['code'] ?? 'unknown'}',
      );

      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw TestLoginException(
          body?['message']?.toString() ?? _fallbackMessage,
          statusCode: response.statusCode,
        );
      }
      if (body == null) {
        throw const TestLoginException(_fallbackMessage);
      }

      try {
        // test-login 응답(status/accessToken/refreshToken/member)이
        // 소셜 로그인 성공 응답과 동일한 형태라서 AuthResponse.fromJson을 그대로 재사용
        return AuthResponse.fromJson(body);
      } on FormatException {
        throw const TestLoginException(_fallbackMessage);
      }
    } on TestLoginException {
      rethrow;
    } catch (error) {
      debugPrint('[TestLogin][Backend] failure type=${error.runtimeType}');
      throw const TestLoginException(_fallbackMessage);
    }
  }

  Map<String, dynamic>? _decodeObject(http.Response response) {
    try {
      final decoded = jsonDecode(utf8.decode(response.bodyBytes));
      if (decoded is Map<String, dynamic>) {
        return decoded;
      }
    } catch (_) {
      return null;
    }
    return null;
  }
}