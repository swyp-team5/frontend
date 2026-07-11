import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/terms_models.dart';

class TermsApi {
  final http.Client client;
  final String baseUrl;

  TermsApi({
    http.Client? client,
    this.baseUrl = 'https://chackchack.shop',
  }) : client = client ?? http.Client();

  // 회원가입 역할 기준으로 서버가 COMMON + 역할별 약관을 조합해서 내려준다.
  // termsType, termsId 오름차순으로 이미 정렬되어 온다.
  /// GET /api/terms/signup?role=OWNER|WORKER
  Future<List<TermsItem>> getSignupTerms({required String role}) async {
    final uri = Uri.parse('$baseUrl/api/terms/signup')
        .replace(queryParameters: {'role': role});

    try {
      final response = await client.get(uri).timeout(const Duration(seconds: 10));

      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw Exception('약관 조회 실패 (${response.statusCode})');
      }

      final body = jsonDecode(utf8.decode(response.bodyBytes));
      if (body is! Map<String, dynamic>) {
        throw Exception('약관 조회 실패 (잘못된 응답 형식)');
      }

      final list = body['terms'] as List? ?? [];
      return list
          .map((e) => TermsItem.fromJson(e as Map<String, dynamic>))
          .toList();
    } on Exception {
      rethrow;
    } catch (_) {
      throw Exception('약관 조회 중 오류가 발생했습니다.');
    }
  }
}
