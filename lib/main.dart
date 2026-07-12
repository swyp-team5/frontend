import 'dart:async';

import 'package:app_links/app_links.dart';
import 'package:chack_chack/common/auth/auth_gate.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:kakao_flutter_sdk_user/kakao_flutter_sdk_user.dart';

import 'common/onboarding/OnboardingPage.dart';
import 'employee/crews/ECrewFirstPage.dart';
import 'firebase_options.dart';

/// 앱 어디서든 딥링크로 push할 수 있도록 전역 navigatorKey 사용
final navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  // Flutter 바인딩 초기화
  WidgetsFlutterBinding.ensureInitialized();

  // Firebase 초기화 (다른 초기화보다 먼저, 가장 위에)
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

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

  @override
  void initState() {
    super.initState();
    _initDeepLinks();
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
  }

  void _handleDeepLink(Uri uri) {
    debugPrint("딥링크 수신: $uri");

    // chack-chack://crew-invitations/470314
    if (uri.host == "crew-invitations" && uri.pathSegments.isNotEmpty) {
      final inviteCode = uri.pathSegments.first;

      navigatorKey.currentState?.push(
        MaterialPageRoute(
          builder: (_) => ECrewFirstPage(inviteCode: inviteCode),
        ),
      );
    }
  }

  @override
  void dispose() {
    _linkSub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey,
      debugShowCheckedModeBanner: false,

      // home: widget.home ?? const AuthGate(),
      home: OnboardingPage(),
    );
  }
}