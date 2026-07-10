import 'package:chack_chack/employer/home/notification/RNotificationModel.dart';
import 'package:chack_chack/employer/home/notification/widgets/NoticeReactionBar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final reactions = [
    NoticeReaction(reactionType: 'HEART', count: 4),
    NoticeReaction(reactionType: 'CHECK', count: 0), // count 0 -> 안 보여야 함
    NoticeReaction(reactionType: 'SMILE', count: 2),
  ];

  Widget wrap(Widget child) => MaterialApp(home: Scaffold(body: child));

  testWidgets('collapsed 상태에서는 count>0인 리액션만 칩으로 보여준다', (tester) async {
    await tester.pumpWidget(
      wrap(
        NoticeReactionBar(
          reactions: reactions,
          myReactionType: null,
          canReact: true,
        ),
      ),
    );
    await tester.pumpAndSettle();

    // HEART(4), SMILE(2)만 보이고 count 0인 CHECK는 칩 자체가 없어야 한다
    expect(find.text('4'), findsOneWidget);
    expect(find.text('2'), findsOneWidget);
    expect(find.text('0'), findsNothing);
  });

  testWidgets('canReact=false면 "+"를 탭해도 펼쳐지지 않는다', (tester) async {
    await tester.pumpWidget(
      wrap(
        NoticeReactionBar(
          reactions: reactions,
          myReactionType: null,
          canReact: false,
        ),
      ),
    );
    await tester.pumpAndSettle();

    // collapsed 상태에서 GestureDetector는 "+" 트리거 하나뿐이다 (칩은 탭 불가)
    expect(find.byType(GestureDetector), findsOneWidget);

    await tester.tap(find.byType(GestureDetector));
    await tester.pumpAndSettle();

    // 펼쳐지지 않았으므로 여전히 집계 칩만 보여야 한다
    expect(find.text('4'), findsOneWidget);
    expect(find.text('2'), findsOneWidget);
  });

  testWidgets(
    'canReact=true면 "+" 탭 시 이모지 6개가 펼쳐지고, 하나 선택하면 onSelect 호출 후 다시 접힌다',
        (tester) async {
      String? selected;

      await tester.pumpWidget(
        wrap(
          NoticeReactionBar(
            reactions: reactions,
            myReactionType: null,
            canReact: true,
            onSelect: (type) => selected = type,
          ),
        ),
      );
      await tester.pumpAndSettle();

      // "+" 탭 -> 확장
      await tester.tap(find.byType(GestureDetector).first);
      await tester.pumpAndSettle();

      // 확장 상태에서는 reactionAssetMap 전체(6개)가 보여야 한다
      expect(find.byType(SvgPicture), findsNWidgets(6));

      // reactionAssetMap의 첫 번째 항목(HEART)을 탭
      await tester.tap(find.byType(GestureDetector).first);
      await tester.pumpAndSettle();

      expect(selected, 'HEART');
      // 선택 후 다시 collapsed 상태로 돌아와서 집계 칩이 보여야 한다
      expect(find.text('4'), findsOneWidget);
    },
  );
}
