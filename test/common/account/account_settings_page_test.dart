import 'package:chack_chack/common/account/AccountSettingsPage.dart';
import 'package:chack_chack/common/account/account_settings_api.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('shows push setting and account actions', (tester) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(393, 852);
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await _pumpPage(tester, _FakeAccountSettingsActions());

    final title = tester.widget<Text>(find.text('계정 설정'));
    final titleCenter = tester.getCenter(find.text('계정 설정'));
    final backButtonLeft = tester.getTopLeft(
      find.byKey(const Key('account-settings-back-button')),
    );
    final backIconLeft = tester.getTopLeft(find.byIcon(Icons.chevron_left));

    expect(find.text('계정 설정'), findsOneWidget);
    expect(titleCenter.dx, 196.5);
    expect(backButtonLeft.dx, 26);
    expect(backIconLeft.dx, 36);
    expect(title.style?.fontSize, 17);
    expect(title.style?.fontWeight, FontWeight.w600);
    expect(title.style?.height, 1.4);
    expect(title.style?.color, const Color(0xFF111111));
    expect(find.text('연동된 소셜 계정'), findsOneWidget);
    expect(find.text('푸시 알림'), findsOneWidget);
    expect(find.text('약관 및 개인정보 처리 동의 내역'), findsOneWidget);
    expect(find.text('로그아웃'), findsOneWidget);
    expect(find.text('회원 탈퇴'), findsOneWidget);
  });

  testWidgets('shows only Kakao icon for Kakao-linked account', (tester) async {
    await _pumpPage(
      tester,
      _FakeAccountSettingsActions(socialProvider: SocialAccountProvider.kakao),
    );

    expect(find.byType(SvgPicture), findsOneWidget);
    expect(
      find.image(const AssetImage('assets/images/logo/google.png')),
      findsNothing,
    );
    expect(
      find.image(const AssetImage('assets/images/logo/apple.png')),
      findsNothing,
    );
  });

  testWidgets('shows only Google icon for Google-linked account', (
    tester,
  ) async {
    await _pumpPage(
      tester,
      _FakeAccountSettingsActions(socialProvider: SocialAccountProvider.google),
    );

    expect(find.byType(SvgPicture), findsNothing);
    expect(
      find.image(const AssetImage('assets/images/logo/google.png')),
      findsOneWidget,
    );
    expect(
      find.image(const AssetImage('assets/images/logo/apple.png')),
      findsNothing,
    );
  });

  testWidgets('logout requires confirmation before calling API', (
    tester,
  ) async {
    final actions = _FakeAccountSettingsActions();
    await _pumpPage(tester, actions);

    await tester.tap(find.text('로그아웃'));
    await tester.pumpAndSettle();

    expect(actions.logoutCount, 0);
    expect(find.text('로그아웃하시겠습니까?'), findsOneWidget);
    expect(find.text('속한 모든 매장에서 로그아웃돼요'), findsOneWidget);

    await tester.tap(find.widgetWithText(ElevatedButton, '로그아웃'));
    await tester.pumpAndSettle();

    expect(actions.logoutCount, 1);
    expect(actions.clearCount, 1);
    expect(find.text('signed out'), findsOneWidget);
  });

  testWidgets('logout confirmation sheet follows Figma dimensions', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(393, 852);
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final actions = _FakeAccountSettingsActions();
    await _pumpPage(tester, actions);

    await tester.tap(find.text('로그아웃'));
    await tester.pumpAndSettle();

    final sheet = tester.getSize(find.byKey(const Key('logout-confirm-sheet')));
    final sheetTopLeft = tester.getTopLeft(
      find.byKey(const Key('logout-confirm-sheet')),
    );
    final handle = tester.getSize(
      find.byKey(const Key('logout-confirm-handle')),
    );
    final button = tester.getSize(
      find.byKey(const Key('logout-confirm-button')),
    );
    final buttonCenter = tester.getCenter(
      find.byKey(const Key('logout-confirm-button')),
    );
    final buttonBottomRight = tester.getBottomRight(
      find.byKey(const Key('logout-confirm-button')),
    );
    final cancelCenter = tester.getCenter(
      find.byKey(const Key('logout-cancel-button')),
    );
    final title = tester.widget<Text>(find.text('로그아웃하시겠습니까?'));
    final description = tester.widget<Text>(find.text('속한 모든 매장에서 로그아웃돼요'));
    final cancel = tester.widget<Text>(find.text('취소'));

    expect(sheet.width, 353);
    expect(sheet.height, 231);
    expect(sheetTopLeft.dx, 20);
    expect(handle, const Size(43, 6));
    expect(button, const Size(313, 50));
    expect(cancelCenter.dx, buttonCenter.dx);
    expect(
      cancelCenter.dy,
      lessThan((buttonBottomRight.dy + sheetTopLeft.dy + sheet.height) / 2),
    );
    expect(title.style?.fontSize, 18);
    expect(title.style?.fontWeight, FontWeight.w600);
    expect(description.style?.fontSize, 14);
    expect(description.style?.fontWeight, FontWeight.w500);
    expect(cancel.style?.fontSize, 16);
    expect(cancel.style?.fontWeight, FontWeight.w500);
  });

  testWidgets('withdrawal requires confirmation before calling API', (
    tester,
  ) async {
    final actions = _FakeAccountSettingsActions();
    await _pumpPage(tester, actions);

    await tester.tap(find.text('회원 탈퇴'));
    await tester.pumpAndSettle();

    expect(actions.withdrawCount, 0);
    expect(find.text('정말 탈퇴하시겠어요?'), findsOneWidget);

    await tester.tap(find.text('탈퇴'));
    await tester.pumpAndSettle();

    expect(actions.withdrawCount, 1);
    expect(actions.clearCount, 1);
    expect(find.text('signed out'), findsOneWidget);
  });
}

Future<void> _pumpPage(
  WidgetTester tester,
  _FakeAccountSettingsActions actions,
) async {
  await tester.pumpWidget(
    MaterialApp(
      home: AccountSettingsPage(
        loadPushEnabled: () async => actions.pushEnabled,
        loadSocialProvider: () async => actions.socialProvider,
        updatePushEnabled: (value) async {
          actions.pushEnabled = value;
          actions.pushUpdateCount += 1;
        },
        logout: () async => actions.logoutCount += 1,
        withdraw: () async => actions.withdrawCount += 1,
        clearSession: () async => actions.clearCount += 1,
        signedOutBuilder: (_) => const Scaffold(body: Text('signed out')),
      ),
    ),
  );
  await tester.pump();
}

class _FakeAccountSettingsActions {
  final SocialAccountProvider socialProvider;
  bool pushEnabled = true;
  int pushUpdateCount = 0;
  int logoutCount = 0;
  int withdrawCount = 0;
  int clearCount = 0;

  _FakeAccountSettingsActions({
    this.socialProvider = SocialAccountProvider.kakao,
  });
}
