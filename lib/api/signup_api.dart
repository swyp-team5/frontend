import 'dart:convert';
import 'package:http/http.dart' as http;

import '../common/onboarding/models/signup_request.dart';

class SignupApi {
  static const String baseUrl = "https://chackchack.shop";

  /// 근무자 회원가입
  static Future<http.Response> workerSignup(
      SignupRequest request,
      ) {
    return http.post(
      Uri.parse("$baseUrl/api/auth/signup/worker"),
      headers: {
        "Content-Type": "application/json",
      },
      body: jsonEncode(request.toJson()),
    );
  }

  /// 사장님 회원가입
  static Future<http.Response> ownerSignup(
      SignupRequest request,
      ) {
    return http.post(
      Uri.parse("$baseUrl/api/auth/signup/owner"),
      headers: {
        "Content-Type": "application/json",
      },
      body: jsonEncode(request.toJson()),
    );
  }
}