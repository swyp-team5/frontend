import Flutter
import UIKit
import Firebase
import UserNotifications

@main
@objc class AppDelegate: FlutterAppDelegate, FlutterImplicitEngineDelegate {

  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    print("1️⃣ didFinishLaunchingWithOptions 시작")

    FirebaseApp.configure()
    print("2️⃣ FirebaseApp.configure 완료")

    if #available(iOS 10.0, *) {
      UNUserNotificationCenter.current().delegate = self
    }
    print("3️⃣ UNUserNotificationCenter delegate 등록 완료")

    application.registerForRemoteNotifications()
    print("4️⃣ registerForRemoteNotifications 호출 완료")

    let result = super.application(application, didFinishLaunchingWithOptions: launchOptions)
    print("5️⃣ super.application 완료, didFinishLaunchingWithOptions 종료")
    return result
  }

  func didInitializeImplicitFlutterEngine(_ engineBridge: FlutterImplicitEngineBridge) {
    print("🔵 didInitializeImplicitFlutterEngine 호출됨 (플러그인 등록 시점)")
    GeneratedPluginRegistrant.register(with: engineBridge.pluginRegistry)
    print("🔵 GeneratedPluginRegistrant.register 완료")
  }

  override func application(
    _ application: UIApplication,
    didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data
  ) {
    print("✅ APNs 디바이스 토큰 수신 (시뮬레이터에선 보통 호출 안 됨): \(deviceToken)")
    super.application(application, didRegisterForRemoteNotificationsWithDeviceToken: deviceToken)
  }

  override func application(
    _ application: UIApplication,
    didFailToRegisterForRemoteNotificationsWithError error: Error
  ) {
    print("🔴 APNs 등록 실패 (시뮬레이터에선 정상적인 에러): \(error)")
  }
}