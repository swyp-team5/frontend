import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../auth/server_token_manager.dart';
import '../auth/session/auth_session_store.dart';
import '../fcm/api/FcmTokenApi.dart';

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
  final Dio logoutDio;
  final Future<AuthSession?> Function() sessionLoader;
  final Future<String?> Function() accessTokenLoader;

  AccountSettingsApi({
    Dio? dio,
    Dio? logoutDio,
    Future<AuthSession?> Function()? sessionLoader,
    Future<String?> Function()? accessTokenLoader,
  }) : dio = dio ?? ServerTokenManager.authorizedDio,
       logoutDio =
           logoutDio ??
           dio ??
           Dio(
             BaseOptions(
               baseUrl: 'https://chackchack.shop',
               connectTimeout: const Duration(seconds: 10),
               receiveTimeout: const Duration(seconds: 10),
             ),
           ),
       sessionLoader =
           sessionLoader ?? (() => ServerTokenManager().store.read()),
       accessTokenLoader =
           accessTokenLoader ?? ServerTokenManager.getValidAccessToken;

  Future<void> logout() async {
    await ServerTokenManager.runExplicitLogout(() async {
      var session = await sessionLoader();
      if (session == null) {
        throw Exception('로그인 정보가 없습니다.');
      }

      try {
        await accessTokenLoader();
      } catch (error) {
        debugPrint('로그아웃 전 액세스 토큰 갱신 실패: $error');
      }
      session = await sessionLoader() ?? session;

      // 로그아웃 이후에는 이 기기로 푸시가 가면 안 되므로, 세션이 아직 유효할 때 먼저 비활성화한다.
      await _deactivateFcmToken(session.deviceId);
      session = await sessionLoader() ?? session;

      await logoutDio.post(
        '/api/auth/logout',
        data: {
          'refreshToken': session.refreshToken,
          'deviceId': session.deviceId,
        },
      );
    });
  }

  Future<void> withdraw() async {
    final accessToken = await accessTokenLoader();
    if (accessToken == null || accessToken.isEmpty) {
      throw Exception('인증이 필요합니다. 다시 로그인해주세요.');
    }

    final session = await sessionLoader();
    if (session != null) {
      await _deactivateFcmToken(session.deviceId);
    }

    await dio.delete(
      '/api/members/me',
      options: Options(headers: {'Authorization': 'Bearer $accessToken'}),
    );
  }

  // FCM 토큰 비활성화는 로그아웃/탈퇴 자체를 막아서는 안 되는 부가 정리 작업이라 실패를 삼킨다.
  Future<void> _deactivateFcmToken(String deviceId) async {
    try {
      await FcmTokenApi.deactivate(deviceId: deviceId);
    } catch (error) {
      debugPrint('FCM 토큰 비활성화 실패: $error');
    }
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
