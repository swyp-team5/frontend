import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

// 포그라운드에서 FCM 메시지를 받았을 때 실제 알림 배너를 띄워주는 서비스.
// 안드로이드는 앱이 포그라운드일 때 FCM notification payload를 자동으로 배너로 띄워주지 않기 때문에,
// flutter_local_notifications로 직접 시스템 알림을 만들어줘야 한다.
// iOS도 DarwinInitializationSettings를 넘겨주지 않으면
// "iOS settings must be set when targeting iOS platform" 에러가 발생한다.
class FcmNotificationService {
  static final FlutterLocalNotificationsPlugin _plugin =
  FlutterLocalNotificationsPlugin();

  // AndroidManifest의 default_notification_channel_id와 반드시 일치시켜야 한다.
  static const _channel = AndroidNotificationChannel(
    'default_channel',
    '기본 알림',
    description: '착착 앱의 기본 알림 채널입니다.',
    importance: Importance.high,
  );

  static Future<void> initialize() async {
    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');

    const iosInit = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const initSettings = InitializationSettings(
      android: androidInit,
      iOS: iosInit,
    );

    await _plugin.initialize(initSettings);

    final androidPlugin = _plugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();

    await androidPlugin?.createNotificationChannel(_channel);
  }

  static Future<void> showFromRemoteMessage(RemoteMessage message) async {
    final notification = message.notification;
    if (notification == null) return;

    await _plugin.show(
      notification.hashCode,
      notification.title,
      notification.body,
      NotificationDetails(
        android: AndroidNotificationDetails(
          _channel.id,
          _channel.name,
          channelDescription: _channel.description,
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: const DarwinNotificationDetails(),
      ),
    );
  }
}