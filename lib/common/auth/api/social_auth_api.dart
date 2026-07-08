import 'dart:convert';

import 'package:http/http.dart' as http;

import '../model/social_auth_models.dart';

abstract class SocialAuthClient {
  Future<AuthResponse> login(SocialCredential credential);
}

class SocialAuthException implements Exception {
  final String message;
  final int? statusCode;

  const SocialAuthException(this.message, {this.statusCode});

  @override
  String toString() => message;
}

class SocialAuthApi implements SocialAuthClient {
  static const _fallbackMessage = '소셜 로그인에 실패했어요.';

  final http.Client client;
  final String baseUrl;

  SocialAuthApi({http.Client? client, this.baseUrl = 'https://chackchack.shop'})
    : client = client ?? http.Client();

  @override
  Future<AuthResponse> login(SocialCredential credential) async {
    try {
      final response = await client.post(
        Uri.parse('$baseUrl/api/auth/social-login'),
        headers: const {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(credential.toJson()),
      );

      final body = _decodeObject(response);
      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw SocialAuthException(
          body?['message']?.toString() ?? _fallbackMessage,
          statusCode: response.statusCode,
        );
      }
      if (body == null) {
        throw const SocialAuthException(_fallbackMessage);
      }

      try {
        return AuthResponse.fromJson(body);
      } on FormatException {
        throw const SocialAuthException(_fallbackMessage);
      }
    } on SocialAuthException {
      rethrow;
    } catch (_) {
      throw const SocialAuthException(_fallbackMessage);
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
