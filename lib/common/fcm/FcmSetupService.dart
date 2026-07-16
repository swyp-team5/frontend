import 'dart:io';
import 'package:firebase_core/firebase_core.dart';
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

    // [수정] 권한 요청 결과를 반드시 확인한다.
    // authorizationStatus가 denied/notDetermined면 배너/사운드가 안 뜨는 건 물론,
    // 특정 상황에서는 APNs 토큰 자체가 발급되지 않을 수 있다.
    final settings = await messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
    );
    debugPrint(
      "🔔 [FcmSetupService] 알림 권한 상태: ${settings.authorizationStatus}",
    );

    if (settings.authorizationStatus == AuthorizationStatus.denied) {
      debugPrint(
        "🔴 [FcmSetupService] 알림 권한이 거부됨 — 설정 앱에서 권한을 켜야 푸시가 옵니다.",
      );
    }

    // 최초 1회 등록 시도 — 여기서 실패(APNs 타임아웃 등)해도
    // 아래 onTokenRefresh 리스너 등록에는 영향을 주지 않는다.
    await _registerOnce(
      messaging: messaging,
      deviceId: deviceId,
      platform: platform,
      appVersion: appVersion,
    );

    // 토큰이 갱신될 때마다(재설치, OS 정책, 또는 위 최초 시도가 실패했다가
    // 나중에 실제로 토큰이 발급되는 경우 등) 서버에도 다시 등록한다.
    // 이 줄은 위 _registerOnce의 성공/실패와 무관하게 항상 실행된다.
    messaging.onTokenRefresh.listen((newToken) async {
      debugPrint("🔄 [FcmSetupService] 토큰 갱신 감지: $newToken");
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

  static Future<void> _registerOnce({
    required FirebaseMessaging messaging,
    required String deviceId,
    required String platform,
    required String appVersion,
  }) async {
    try {
      if (Platform.isIOS) {
        // iOS는 앱이 포그라운드일 때 기본적으로 알림 배너/사운드를 띄우지 않는다.
        // 명시적으로 켜줘야 Android와 동일하게 포그라운드에서도 알림이 보인다.
        await messaging.setForegroundNotificationPresentationOptions(
          alert: true,
          badge: true,
          sound: true,
        );

        // iOS는 APNs 토큰이 먼저 발급돼야 FCM 토큰을 받을 수 있다.
        // 앱 시작 직후엔 아직 APNs 토큰이 없을 수 있어서 잠깐 재시도하며 기다린다.
        // [수정] 재시도 횟수/간격 확대: 5초 → 최대 15초.
        // 실기기 초기 부팅 직후나 네트워크가 느릴 때 5초는 부족한 경우가 많다.
        String? apnsToken = await messaging.getAPNSToken();
        int retryCount = 0;
        const maxRetries = 15;

        while (apnsToken == null && retryCount < maxRetries) {
          await Future.delayed(const Duration(seconds: 1));
          apnsToken = await messaging.getAPNSToken();
          retryCount++;
        }

        // [수정] APNs 토큰 값을 직접 로그로 확인.
        // 이 값이 null이면 Xcode의 Push Notifications capability,
        // aps-environment entitlement, 또는 인증서/프로파일 설정 문제일 가능성이 높다.
        debugPrint("📡 [FcmSetupService] APNs 토큰: $apnsToken (재시도 ${retryCount}회)");

        if (apnsToken == null) {
          // 여기서 return해도 _registerOnce만 끝날 뿐, 위의 onTokenRefresh
          // 리스너는 이미(또는 곧) 등록되므로 나중에 APNs 토큰이 뒤늦게
          // 발급되면 그때 리스너가 잡아서 등록해준다.
          debugPrint(
            "🔴 [FcmSetupService] APNs 토큰 발급 실패 — 최초 등록은 건너뜀 (onTokenRefresh 대기). "
                "권한이 허용됐는데도 계속 null이면 Xcode Push capability / entitlement / 인증서를 확인하세요.",
          );
          return;
        }
      }

      final token = await messaging.getToken();

      // [수정] FCM 토큰 값도 로그로 확인 (앞자리만이 아니라 존재 여부/길이 체크용).
      debugPrint(
        "📮 [FcmSetupService] FCM 토큰 발급됨 (길이: ${token?.length ?? 0})",
      );

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
    } on FirebaseException catch (e) {
      // [수정] 제네릭 catch(e) 대신 FirebaseException을 먼저 잡아서
      // code(예: apns-token-not-set, messaging/unknown 등)와 message를 명확히 남긴다.
      debugPrint(
        "🔴 [FcmSetupService] FCM 토큰 등록 실패 (FirebaseException) "
            "code=${e.code}, message=${e.message}",
      );
    } catch (e) {
      debugPrint("🔴 [FcmSetupService] FCM 토큰 등록 실패: $e");
    }
  }
}