import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'api/FcmTokenApi.dart';

// 로그인/회원가입 성공 시 호출하는 FCM 등록 진입점.
// - 알림 권한 요청, 토큰 발급, 서버 등록(FcmTokenApi.register)을 한 번에 처리한다.
// - 이후 토큰이 갱신될 때마다(onTokenRefresh) 자동으로 재등록한다.
// - 실패해도 로그인/가입 자체를 막으면 안 되므로 예외를 밖으로 던지지 않고 로그만 남긴다.
class FcmSetupService {
  static Future<void> registerCurrentDevice({
    required String deviceId,
    required String platform,
    required String appVersion,
  }) async {
    final messaging = FirebaseMessaging.instance;

    try {
      await messaging.requestPermission();

      final token = await messaging.getToken();

      if (token == null) {
        debugPrint("🔴 [FcmSetupService] FCM 토큰 발급 실패 — token이 null");
        return;
      }

      await FcmTokenApi.register(
        deviceId: deviceId,
        token: token,
        platform: platform,
        appVersion: appVersion,
      );

      debugPrint("✅ [FcmSetupService] FCM 토큰 등록 완료");
    } catch (e) {
      debugPrint("🔴 [FcmSetupService] FCM 토큰 등록 실패: $e");
    }

    // 토큰이 갱신될 때마다(재설치, OS 정책 등) 서버에도 다시 등록
    messaging.onTokenRefresh.listen((newToken) async {
      try {
        await FcmTokenApi.register(
          deviceId: deviceId,
          token: newToken,
          platform: platform,
          appVersion: appVersion,
        );
        debugPrint("✅ [FcmSetupService] FCM 토큰 갱신 등록 완료");
      } catch (e) {
        debugPrint("🔴 [FcmSetupService] FCM 토큰 갱신 등록 실패: $e");
      }
    });
  }
}