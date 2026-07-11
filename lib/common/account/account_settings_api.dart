import 'package:dio/dio.dart';

import '../auth/server_token_manager.dart';
import '../auth/session/auth_session_store.dart';

enum SocialAccountProvider {
  kakao,
  google,
  apple;

  static SocialAccountProvider? fromJson(Object? value) {
    return switch (value) {
      'KAKAO' => SocialAccountProvider.kakao,
      'GOOGLE' => SocialAccountProvider.google,
      'APPLE' => SocialAccountProvider.apple,
      _ => null,
    };
  }
}

class AccountSettingsApi {
  final Dio dio;
  final Future<AuthSession?> Function() sessionLoader;
  final Future<String?> Function() accessTokenLoader;

  AccountSettingsApi({
    Dio? dio,
    Future<AuthSession?> Function()? sessionLoader,
    Future<String?> Function()? accessTokenLoader,
  }) : dio =
           dio ??
           Dio(
             BaseOptions(
               baseUrl: 'https://chackchack.shop',
               connectTimeout: const Duration(seconds: 10),
               receiveTimeout: const Duration(seconds: 10),
               headers: const {
                 'Accept': 'application/json',
                 'Content-Type': 'application/json',
               },
             ),
           ),
       sessionLoader =
           sessionLoader ?? (() => ServerTokenManager().store.read()),
       accessTokenLoader =
           accessTokenLoader ?? ServerTokenManager.getValidAccessToken;

  Future<void> logout() async {
    final session = await sessionLoader();
    if (session == null) {
      throw Exception('로그인 정보가 없습니다.');
    }

    await dio.post(
      '/api/auth/logout',
      data: {
        'refreshToken': session.refreshToken,
        'deviceId': session.deviceId,
      },
    );
  }

  Future<void> withdraw() async {
    final accessToken = await accessTokenLoader();
    if (accessToken == null || accessToken.isEmpty) {
      throw Exception('인증이 필요합니다. 다시 로그인해주세요.');
    }

    await dio.delete(
      '/api/members/me',
      options: Options(headers: {'Authorization': 'Bearer $accessToken'}),
    );
  }

  Future<SocialAccountProvider?> loadSocialProvider() async {
    final accessToken = await accessTokenLoader();
    if (accessToken == null || accessToken.isEmpty) {
      throw Exception('인증이 필요합니다. 다시 로그인해주세요.');
    }

    final response = await dio.get(
      '/api/members/me/profile',
      options: Options(headers: {'Authorization': 'Bearer $accessToken'}),
    );
    final data = response.data;
    if (data is! Map) {
      throw const FormatException('Invalid profile response');
    }
    return SocialAccountProvider.fromJson(data['socialProvider']);
  }
}
