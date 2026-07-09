import 'package:chack_chack/employer/crews/api/crew_invitation_api.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('parses crew invitation history page response', () {
    final response = CrewInvitationHistoryResponse.fromJson({
      'content': [
        {
          'invitationId': 1,
          'workPlaceId': 10,
          'inviteCode': '839204',
          'inviteUrl': 'chack-chack://crew-invitations/839204',
          'status': 'USED',
          'expiresAt': '2026-06-13T15:00:00',
          'usedAt': '2026-06-13T14:10:00',
          'usedByMemberId': 20,
          'usedByMemberName': '김철수',
          'failedAttemptCount': 0,
          'createdAt': '2026-06-13T14:00:00',
        },
        {
          'invitationId': 2,
          'workPlaceId': 10,
          'inviteCode': '123456',
          'inviteUrl': 'chack-chack://crew-invitations/123456',
          'status': 'ACTIVE',
          'expiresAt': '2026-06-13T16:00:00',
          'usedAt': null,
          'usedByMemberId': null,
          'usedByMemberName': null,
          'failedAttemptCount': 1,
          'createdAt': '2026-06-13T15:00:00',
        },
      ],
      'page': 0,
      'size': 20,
      'totalElements': 2,
      'totalPages': 1,
    });

    expect(response.content, hasLength(2));
    expect(response.content.first.statusLabel, '사용 완료');
    expect(response.content.last.usedByMemberName, isNull);
    expect(response.hasNextPage, isFalse);
  });

  test('shows a localized label for canceled invitations', () {
    final item = CrewInvitationHistoryItem.fromJson({
      'invitationId': 3,
      'workPlaceId': 10,
      'inviteCode': '654321',
      'inviteUrl': 'chack-chack://crew-invitations/654321',
      'status': 'CANCELED',
      'expiresAt': '2026-06-13T16:00:00',
      'usedAt': null,
      'usedByMemberId': null,
      'usedByMemberName': null,
      'failedAttemptCount': 0,
      'createdAt': '2026-06-13T15:00:00',
    });

    expect(item.statusLabel, '취소됨');
  });
}
