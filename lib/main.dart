import 'dart:async';

import 'package:app_links/app_links.dart';
import 'package:chack_chack/common/auth/auth_gate.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:kakao_flutter_sdk_user/kakao_flutter_sdk_user.dart';

import 'common/deeplink/crew_invite_deep_link.dart';
import 'common/fcm/AlarmListPage.dart';
import 'common/fcm/fcm_notification_service.dart';
import 'common/onboarding/OnboardingPage.dart';
import 'employee/crews/ECrewFirstPage.dart';
import 'firebase_options.dart';

/// 앱 어디서든 딥링크로 push할 수 있도록 전역 navigatorKey 사용
final navigatorKey = GlobalKey<NavigatorState>();

// 백그라운드/종료 상태에서 FCM 메시지를 받았을 때 호출되는 top-level 핸들러.
// 별도 isolate에서 실행되므로 반드시 top-level(또는 static) 함수여야 하고, @pragma가 필요하다.
//
// notification payload가 있으면 OS가 알아서 배너를 띄워주지만,
// data-only 메시지인 경우 OS가 자동으로 띄워주지 않으므로 직접 로컬 알림으로 띄워준다.
// 별도 isolate이라 Firebase/플러그인이 초기화되어 있지 않으므로 여기서 다시 초기화해야 한다.
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  debugPrint('[FCM] 백그라운드 메시지 수신: ${message.messageId}');

  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await FcmNotificationService.initialize();
  await FcmNotificationService.showFromRemoteMessage(message);
}

void main() async {
  // Flutter 바인딩 초기화
  WidgetsFlutterBinding.ensureInitialized();

  // Firebase 초기화 (다른 초기화보다 먼저, 가장 위에)
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // 백그라운드 핸들러는 Firebase 초기화 이후, runApp 이전에 등록해야 한다.
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  // 포그라운드에서 받은 메시지를 로컬 알림으로 띄우기 위한 플러그인 초기화
  // (내부적으로 iOS 알림 권한 요청(requestAlertPermission 등)도 함께 이루어진다)
  await FcmNotificationService.initialize();

  // ===== 디버깅용: 알림 권한 상태 및 FCM 토큰 확인 =====
  NotificationSettings settings =
  await FirebaseMessaging.instance.requestPermission(
    alert: true,
    badge: true,
    sound: true,
  );
  debugPrint('🟡 알림 권한 상태: ${settings.authorizationStatus}');

  String? fcmToken = await FirebaseMessaging.instance.getToken();
  debugPrint('🟢 FCM 토큰: $fcmToken');

  // TODO: 여기서 받은 fcmToken을 서버에 등록하는 API 호출이 필요합니다.
  // 예: await ApiService.updateFcmToken(fcmToken);
  // 로그인 이후 시점에 처리하고 있다면 로그인 처리 코드 쪽도 함께 확인해주세요.

  FirebaseMessaging.instance.onTokenRefresh.listen((newToken) {
    debugPrint('🔄 FCM 토큰 갱신됨: $newToken');
    // TODO: 갱신된 토큰도 서버에 재전송하는 로직이 필요합니다.
    // 예: await ApiService.updateFcmToken(newToken);
  });
  // ===================================================

  // 한국어 로케일 데이터 초기화
  await initializeDateFormatting('ko_KR', null);

  // 카카오 SDK 초기화
  KakaoSdk.init(nativeAppKey: '05952ada0dceff8e149cd664e5459465');
  // 환경 변수로 초기화
  /*AuthEnvironment.validateForRuntime();
  KakaoSdk.init(nativeAppKey: AuthEnvironment.kakaoNativeAppKey);*/

  runApp(
    // Riverpod을 사용하기 위해 ProviderScope로 감싸줍니다.
    const ProviderScope(child: MyApp()),
  );
}

class MyApp extends StatefulWidget {
  final Widget? home;

  const MyApp({super.key, this.home});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final _appLinks = AppLinks();
  StreamSubscription<Uri>? _linkSub;
  StreamSubscription<String?>? _kakaoLinkSub;
  Timer? _deepLinkDedupeTimer;
  String? _pendingInviteCode;
  String? _lastHandledLink;
  bool _navigationScheduled = false;

  @override
  void initState() {
    super.initState();
    _initDeepLinks();
    _initFcmListeners();
  }

  void _initFcmListeners() {
    // 앱이 포그라운드일 때 메시지가 오면 OS가 자동으로 배너를 안 띄워주므로 직접 띄운다.
    FirebaseMessaging.onMessage.listen((message) {
      debugPrint(
          '[FCM] 포그라운드 메시지 수신: ${message.messageId}, data: ${message.data}, notification: ${message.notification?.title}');
      FcmNotificationService.showFromRemoteMessage(message);
    });

    // 알림을 탭해서 앱을 열었을 때 알림함으로 이동시킨다.
    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      navigatorKey.currentState?.push(
        MaterialPageRoute(builder: (_) => const AlarmListPage()),
      );
    });
  }

  Future<void> _initDeepLinks() async {
    // 앱이 완전히 종료된 상태에서 딥링크로 실행된 경우
    try {
      final initialUri = await _appLinks.getInitialLink();
      if (initialUri != null) _handleDeepLink(initialUri);
    } catch (e) {
      debugPrint("초기 딥링크 조회 실패: $e");
    }

    // 앱이 이미 켜져 있는 상태(백그라운드 포함)에서 딥링크가 들어온 경우
    _linkSub = _appLinks.uriLinkStream.listen(
      _handleDeepLink,
      onError: (err) => debugPrint("딥링크 에러: $err"),
    );

    try {
      final initialKakaoScheme = await receiveKakaoScheme();
      if (initialKakaoScheme != null) {
        _handleDeepLink(Uri.parse(initialKakaoScheme));
      }
    } catch (error) {
      debugPrint('초기 카카오 공유 링크 조회 실패: $error');
    }

    _kakaoLinkSub = kakaoSchemeStream.listen((link) {
      if (link != null) {
        _handleDeepLink(Uri.parse(link));
      }
    }, onError: (error) => debugPrint('카카오 공유 링크 에러: $error'));
  }

  void _handleDeepLink(Uri uri) {
    debugPrint("딥링크 수신: $uri");

    final link = uri.toString();
    if (_lastHandledLink == link) {
      return;
    }

    // HTTPS App Links, 직접 커스텀 스킴, Kakao Talk Share 콜백을 지원한다.
    final inviteCode = CrewInviteDeepLink.extractInviteCode(uri);

    if (inviteCode != null) {
      _lastHandledLink = link;
      _deepLinkDedupeTimer?.cancel();
      _deepLinkDedupeTimer = Timer(const Duration(seconds: 1), () {
        if (_lastHandledLink == link) {
          _lastHandledLink = null;
        }
      });
      _pendingInviteCode = inviteCode;
      _schedulePendingDeepLinkNavigation();
    }
  }

  void _schedulePendingDeepLinkNavigation() {
    if (_navigationScheduled) {
      return;
    }
    _navigationScheduled = true;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _navigationScheduled = false;
      if (!mounted || _pendingInviteCode == null) {
        return;
      }

      final navigator = navigatorKey.currentState;
      if (navigator == null) {
        _schedulePendingDeepLinkNavigation();
        return;
      }

      final inviteCode = _pendingInviteCode!;
      _pendingInviteCode = null;
      navigator.push(
        MaterialPageRoute(
          builder: (_) => ECrewFirstPage(inviteCode: inviteCode),
        ),
      );
    });
  }

  @override
  void dispose() {
    _linkSub?.cancel();
    _kakaoLinkSub?.cancel();
    _deepLinkDedupeTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey,
      debugShowCheckedModeBanner: false,

      home: widget.home ?? const AuthGate(),
      // home: OnboardingPage(),
    );
  }
}