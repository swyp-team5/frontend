import 'package:chack_chack/common/onboarding/OnboardingPage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('both onboarding actions open the social login sheet', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(393, 852);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      const ProviderScope(child: MaterialApp(home: OnboardingPage())),
    );

    await tester.tap(find.text('회원가입 바로가기'));
    await tester.pumpAndSettle();
    expect(find.text('스케줄 관리를 더 쉽고 간편하게'), findsOneWidget);

    tester.state<NavigatorState>(find.byType(Navigator)).pop();
    await tester.pumpAndSettle();

    await tester.tap(find.text('바로 시작하기'));
    await tester.pumpAndSettle();
    expect(find.text('스케줄 관리를 더 쉽고 간편하게'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
