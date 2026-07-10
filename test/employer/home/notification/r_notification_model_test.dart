import 'package:chack_chack/employer/home/notification/RNotificationModel.dart';
import 'package:flutter_test/flutter_test.dart';

// 테스트마다 13개 필드를 전부 나열하지 않도록 만든 헬퍼.
// 공감 관련 테스트라 myReactionType/reactions만 케이스별로 바꿔가며 쓴다.
NoticeModel _buildNotice({
  String? myReactionType,
  List<NoticeReaction> reactions = const [],
}) {
  return NoticeModel(
    noticeId: 1,
    workPlaceId: 10,
    writerMemberId: 100,
    writerMemberName: '김다빈',
    title: '제목',
    content: '내용',
    representative: false,
    status: 'ACTIVE',
    images: const [],
    myReactionType: myReactionType,
    reactions: reactions,
    createdAt: '2026-06-14T19:00:00',
    updatedAt: '2026-06-14T19:00:00',
  );
}

void main() {
  group('NoticeReactionResult.fromJson', () {
    // 명세서 8.6 PUT 성공 응답 예시
    test('공감 선택/변경 응답을 파싱한다', () {
      final json = {
        'noticeId': 1,
        'myReactionType': 'HEART',
        'reactions': [
          {'reactionType': 'HEART', 'count': 4},
          {'reactionType': 'CHECK', 'count': 6},
          {'reactionType': 'NEUTRAL', 'count': 2},
          {'reactionType': 'SMILE', 'count': 0},
          {'reactionType': 'KISS', 'count': 0},
          {'reactionType': 'PROUD', 'count': 1},
        ],
      };

      final result = NoticeReactionResult.fromJson(json);

      expect(result.noticeId, 1);
      expect(result.myReactionType, 'HEART');
      expect(result.reactions, hasLength(6));
      expect(result.reactions.first.reactionType, 'HEART');
      expect(result.reactions.first.count, 4);
    });

    // 명세서 8.6/8.7: 취소되면 myReactionType이 null로 온다
    test('공감 취소 응답은 myReactionType이 null이다', () {
      final json = {
        'noticeId': 1,
        'myReactionType': null,
        'reactions': [
          {'reactionType': 'HEART', 'count': 3},
        ],
      };

      final result = NoticeReactionResult.fromJson(json);

      expect(result.myReactionType, isNull);
      expect(result.reactions.single.count, 3);
    });

    test('필드가 비어있으면 기본값으로 채운다', () {
      final result = NoticeReactionResult.fromJson(const {});

      expect(result.noticeId, 0);
      expect(result.myReactionType, isNull);
      expect(result.reactions, isEmpty);
    });
  });

  group('NoticeModel.copyWith', () {
    test('myReactionType과 reactions만 갱신하고 나머지 필드는 그대로 유지한다', () {
      final original = _buildNotice(
        myReactionType: null,
        reactions: [NoticeReaction(reactionType: 'HEART', count: 3)],
      );

      final updated = original.copyWith(
        myReactionType: 'CHECK',
        reactions: [
          NoticeReaction(reactionType: 'HEART', count: 3),
          NoticeReaction(reactionType: 'CHECK', count: 1),
        ],
      );

      expect(updated.myReactionType, 'CHECK');
      expect(updated.reactions, hasLength(2));
      // 공감과 무관한 필드는 원본 그대로 유지돼야 한다
      expect(updated.noticeId, original.noticeId);
      expect(updated.title, original.title);
      expect(updated.content, original.content);
      expect(updated.writerMemberName, original.writerMemberName);
    });

    // copyWith의 myReactionType은 다른 필드와 달리 ?? 로 기존 값을 지키지 않고
    // 넘어온 값을 그대로 반영한다 — 취소돼서 null이 되는 걸 표현하기 위한 의도적인 동작이다.
    test('myReactionType에 null을 넘기면 실제로 null로 바뀐다 (공감 취소 표현)', () {
      final withReaction = _buildNotice(myReactionType: 'HEART');

      final afterCancel = withReaction.copyWith(
        myReactionType: null,
        reactions: const [],
      );

      expect(afterCancel.myReactionType, isNull);
    });
  });

  group('NoticeModel.activeReactions', () {
    test('count가 0보다 큰 리액션만 남긴다', () {
      final notice = _buildNotice(
        reactions: [
          NoticeReaction(reactionType: 'HEART', count: 4),
          NoticeReaction(reactionType: 'CHECK', count: 0),
          NoticeReaction(reactionType: 'SMILE', count: 2),
          NoticeReaction(reactionType: 'KISS', count: 0),
        ],
      );

      final active = notice.activeReactions;

      expect(active, hasLength(2));
      expect(active.map((r) => r.reactionType), ['HEART', 'SMILE']);
    });

    test('전부 count 0이면 빈 리스트를 반환한다', () {
      final notice = _buildNotice(
        reactions: [
          NoticeReaction(reactionType: 'HEART', count: 0),
        ],
      );

      expect(notice.activeReactions, isEmpty);
    });
  });
}
