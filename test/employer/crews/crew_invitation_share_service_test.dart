import 'package:chack_chack/employer/crews/share/crew_invitation_share_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('CrewInvitationShareService', () {
    test('returns unavailable without opening Kakao Talk', () async {
      final gateway = _FakeKakaoTalkShareGateway(isAvailable: false);
      final service = CrewInvitationShareService(gateway: gateway);

      final result = await service.share(inviteCode: '123456');

      expect(result, KakaoInvitationShareResult.unavailable);
      expect(gateway.openedContent, isNull);
    });

    test(
      'opens Kakao Talk with matching Android and iOS invite code',
      () async {
        final gateway = _FakeKakaoTalkShareGateway(isAvailable: true);
        final service = CrewInvitationShareService(gateway: gateway);

        final result = await service.share(inviteCode: '234567');

        expect(result, KakaoInvitationShareResult.opened);
        expect(gateway.openedContent?.buttonTitle, '착착에서 초대 확인');
        expect(
          gateway.openedContent?.webUrl,
          Uri.parse('https://chackchack.shop/crew-invitations/234567'),
        );
        expect(gateway.openedContent?.executionParams, {
          'inviteCode': '234567',
        });
      },
    );

    test('rejects an invalid invite code before calling the gateway', () async {
      final gateway = _FakeKakaoTalkShareGateway(isAvailable: true);
      final service = CrewInvitationShareService(gateway: gateway);

      await expectLater(
        service.share(inviteCode: 'invalid'),
        throwsArgumentError,
      );
      expect(gateway.availabilityCheckCount, 0);
    });
  });
}

class _FakeKakaoTalkShareGateway implements KakaoTalkShareGateway {
  _FakeKakaoTalkShareGateway({required this.isAvailable});

  final bool isAvailable;
  int availabilityCheckCount = 0;
  CrewInvitationShareContent? openedContent;

  @override
  Future<bool> canShare() async {
    availabilityCheckCount += 1;
    return isAvailable;
  }

  @override
  Future<void> open(CrewInvitationShareContent content) async {
    openedContent = content;
  }
}
