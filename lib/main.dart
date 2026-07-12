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

    // 크루 초대 링크. 아래 두 형태를 모두 지원한다.
    //   ① https App Links (카카오톡/문자 등에서 자동 링크화됨, 권장)
    //      https://chackchack.shop/crew-invitations/470314
    //   ② 기존 커스텀 스킴 (하위 호환용 — 신규 채널에서는 링크화가
    //      안 될 수 있으니 서서히 걷어낼 예정)
    //      chack-chack://crew-invitations/470314
    final inviteCode = _extractCrewInviteCode(uri);

    if (inviteCode != null) {
      navigatorKey.currentState?.push(
        MaterialPageRoute(
          builder: (_) => ECrewFirstPage(inviteCode: inviteCode),
        ),
      );
    }
  }

  /// 크루 초대 딥링크에서 초대 코드를 추출한다.
  /// 매칭되는 형태가 없으면 null을 반환한다.
  String? _extractCrewInviteCode(Uri uri) {
    // ① https://chackchack.shop/crew-invitations/{code}
    if (uri.scheme == "https" &&
        uri.host == "chackchack.shop" &&
        uri.pathSegments.length >= 2 &&
        uri.pathSegments[0] == "crew-invitations") {
      return uri.pathSegments[1];
    }

    // ② chack-chack://crew-invitations/{code} (레거시)
    if (uri.scheme == "chack-chack" &&
        uri.host == "crew-invitations" &&
        uri.pathSegments.isNotEmpty) {
      return uri.pathSegments.first;
    }

    return null;
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

      home: widget.home ?? const AuthGate(),
      // home: OnboardingPage(),
    );
  }
}