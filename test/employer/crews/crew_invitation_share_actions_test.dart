import 'package:chack_chack/employer/crews/widgets/crew_invitation_share_actions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('offers HTTPS link copy and Kakao Talk sharing', (tester) async {
    var copyCount = 0;
    var kakaoShareCount = 0;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: CrewInvitationShareActions(
            onCopyLink: () async => copyCount += 1,
            onShareToKakao: () async => kakaoShareCount += 1,
          ),
        ),
      ),
    );

    expect(find.text('초대 링크 복사'), findsOneWidget);
    expect(find.text('카카오톡으로 초대'), findsOneWidget);

    await tester.tap(find.text('초대 링크 복사'));
    await tester.pump();
    await tester.tap(find.text('카카오톡으로 초대'));
    await tester.pump();

    expect(copyCount, 1);
    expect(kakaoShareCount, 1);
  });
}
