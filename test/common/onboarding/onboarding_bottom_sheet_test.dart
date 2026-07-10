import 'dart:async';

import 'package:chack_chack/common/auth/model/social_auth_models.dart';
import 'package:chack_chack/common/auth/social/social_auth_coordinator.dart';
import 'package:chack_chack/common/onboarding/OnboardingBottomSheet.dart';
import 'package:chack_chack/common/onboarding/models/signup_request.dart';
import 'package:chack_chack/common/onboarding/providers/signup_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('shows Kakao, Google, and Apple actions on iOS', (tester) async {
    await _pumpSheet(
      tester,
      _FakeSocialAuthFlow(),
      platform: TargetPlatform.iOS,
    );

    expect(find.text('카카오로 시작하기'), findsOneWidget);
    expect(find.text('Google로 시작하기'), findsOneWidget);
    expect(find.text('Apple로 시작하기'), findsOneWidget);
  });

  testWidgets('hides Apple action on Android', (tester) async {
    await _pumpSheet(
      tester,
      _FakeSocialAuthFlow(),
      platform: TargetPlatform.android,
    );

    expect(find.text('카카오로 시작하기'), findsOneWidget);
    expect(find.text('Google로 시작하기'), findsOneWidget);
    expect(find.text('Apple로 시작하기'), findsNothing);
  });

  testWidgets(
    'uses Figma icon styles and the same label size for social buttons',
        (tester) async {
      await _pumpSheet(tester, _FakeSocialAuthFlow());

      final kakaoIcon = tester.widget<Image>(
        find.image(const AssetImage('assets/images/logo/kakaotalk.png')),
      );
      final googleIcon = tester.widget<Image>(
        find.image(const AssetImage('assets/images/logo/google.png')),
      );
      final kakaoText = tester.widget<Text>(find.text('카카오로 시작하기'));
      final googleText = tester.widget<Text>(find.text('Google로 시작하기'));

      expect(kakaoIcon.width, 18);
      expect(kakaoIcon.height, 17);
      expect(kakaoIcon.color, const Color(0xE6111111));
      expect(kakaoIcon.colorBlendMode, BlendMode.srcIn);
      expect(googleIcon.width, 18);
      expect(googleIcon.height, 18);
      expect(googleIcon.color, isNull);
      expect(kakaoText.style?.fontSize, googleText.style?.fontSize);
      expect(kakaoText.style?.fontWeight, googleText.style?.fontWeight);
      expect(kakaoText.style?.height, googleText.style?.height);
    },
  );

  testWidgets('owner login replaces onboarding with owner home', (
    tester,
  ) async {
    final flow = _FakeSocialAuthFlow(
      outcome: const SocialAuthOutcome.loginSuccess(
        AuthMember(
          memberId: 1,
          name: '사장님',
          role: AuthMemberRole.owner,
          status: 'ACTIVE',
        ),
      ),
    );
    await _pumpSheet(tester, flow);

    await tester.tap(find.text('카카오로 시작하기'));
    await tester.pumpAndSettle();

    expect(flow.providers, [SocialAuthProvider.kakao]);
    expect(find.text('owner home'), findsOneWidget);
    expect(find.text('스케줄 관리를 더 쉽고 간편하게'), findsNothing);
  });

  testWidgets('worker login replaces onboarding with worker home', (
    tester,
  ) async {
    final flow = _FakeSocialAuthFlow(
      outcome: const SocialAuthOutcome.loginSuccess(
        AuthMember(
          memberId: 2,
          name: '근무자',
          role: AuthMemberRole.worker,
          status: 'ACTIVE',
        ),
      ),
    );
    await _pumpSheet(tester, flow);

    await tester.tap(find.text('Google로 시작하기'));
    await tester.pumpAndSettle();

    expect(flow.providers, [SocialAuthProvider.google]);
    expect(find.text('worker home'), findsOneWidget);
  });

  testWidgets('Apple action starts Apple authentication', (tester) async {
    final flow = _FakeSocialAuthFlow();
    await _pumpSheet(tester, flow, platform: TargetPlatform.iOS);

    await tester.tap(find.text('Apple로 시작하기'));
    await tester.pumpAndSettle();

    expect(flow.providers, [SocialAuthProvider.apple]);
    expect(find.text('스케줄 관리를 더 쉽고 간편하게'), findsOneWidget);
  });

  testWidgets('signup result stores credential and opens signup', (
    tester,
  ) async {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    const credential = SocialCredential.google(
      idToken: 'google-id-token',
      device: DevicePayload(
        deviceId: 'device-1',
        platform: 'ANDROID',
        appVersion: '1.0.0',
      ),
    );
    final flow = _FakeSocialAuthFlow(
      outcome: const SocialAuthOutcome.signupRequired(credential),
    );
    await _pumpSheet(tester, flow, container: container);

    await tester.tap(find.text('Google로 시작하기'));
    await tester.pumpAndSettle();

    final signup = container.read(signupProvider);
    expect(signup.provider, SocialProvider.GOOGLE);
    expect(signup.idToken, 'google-id-token');
    expect(signup.device.deviceId, 'device-1');
    expect(find.text('signup'), findsOneWidget);
  });

  testWidgets('ignores duplicate taps while authentication is pending', (
    tester,
  ) async {
    final completer = Completer<SocialAuthOutcome>();
    final flow = _FakeSocialAuthFlow(pending: completer);
    await _pumpSheet(tester, flow);

    await tester.tap(find.text('카카오로 시작하기'));
    await tester.pump();
    await tester.tap(find.text('Google로 시작하기'));
    await tester.pump();

    expect(flow.providers, [SocialAuthProvider.kakao]);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    completer.complete(const SocialAuthOutcome.cancelled());
    await tester.pumpAndSettle();
  });

  testWidgets('cancellation stays on the sheet without an error', (
    tester,
  ) async {
    await _pumpSheet(tester, _FakeSocialAuthFlow());

    await tester.tap(find.text('카카오로 시작하기'));
    await tester.pumpAndSettle();

    expect(find.text('스케줄 관리를 더 쉽고 간편하게'), findsOneWidget);
    expect(find.byType(SnackBar), findsNothing);
  });

  testWidgets('unexpected errors show a safe message', (tester) async {
    await _pumpSheet(
      tester,
      _FakeSocialAuthFlow(error: Exception('sensitive provider error')),
    );

    await tester.tap(find.text('Google로 시작하기'));
    await tester.pumpAndSettle();

    expect(find.text('소셜 로그인에 실패했어요. 잠시 후 다시 시도해주세요.'), findsOneWidget);
    expect(find.textContaining('sensitive provider error'), findsNothing);
  });
}

Future<void> _pumpSheet(
  WidgetTester tester,
  SocialAuthFlow flow, {
  ProviderContainer? container,
  TargetPlatform platform = TargetPlatform.android,
}) async {
  final resolvedContainer = container ?? ProviderContainer();
  if (container == null) {
    addTearDown(resolvedContainer.dispose);
  }
  await tester.pumpWidget(
    UncontrolledProviderScope(
      container: resolvedContainer,
      child: MaterialApp(
        theme: ThemeData(platform: platform),
        home: Scaffold(
          body: OnboardingBottomSheet(
            authFlow: flow,
            ownerHomeBuilder: (_) => const Scaffold(body: Text('owner home')),
            workerHomeBuilder: (_) => const Scaffold(body: Text('worker home')),
            signupBuilder: (_) => const Scaffold(body: Text('signup')),
          ),
        ),
      ),
    ),
  );
}

class _FakeSocialAuthFlow implements SocialAuthFlow {
  final SocialAuthOutcome outcome;
  final Completer<SocialAuthOutcome>? pending;
  final Object? error;
  final List<SocialAuthProvider> providers = [];

  _FakeSocialAuthFlow({
    this.outcome = const SocialAuthOutcome.cancelled(),
    this.pending,
    this.error,
  });

  @override
  Future<SocialAuthOutcome> authenticate(SocialAuthProvider provider) {
    providers.add(provider);
    if (error != null) {
      return Future.error(error!);
    }
    return pending?.future ?? Future.value(outcome);
  }
}
