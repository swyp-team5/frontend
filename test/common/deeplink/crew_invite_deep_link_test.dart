import 'package:chack_chack/common/deeplink/crew_invite_deep_link.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('CrewInviteDeepLink', () {
    test('extracts code from HTTPS app link', () {
      final code = CrewInviteDeepLink.extractInviteCode(
        Uri.parse('https://chackchack.shop/crew-invitations/123456'),
      );

      expect(code, '123456');
    });

    test('extracts code from direct custom scheme', () {
      final code = CrewInviteDeepLink.extractInviteCode(
        Uri.parse('chack-chack://crew-invitations/234567'),
      );

      expect(code, '234567');
    });

    test('extracts code from Kakao Talk share scheme', () {
      final code = CrewInviteDeepLink.extractInviteCode(
        Uri.parse(
          'kakao05952ada0dceff8e149cd664e5459465://kakaolink'
          '?inviteCode=345678',
        ),
      );

      expect(code, '345678');
    });

    test('rejects malformed or unrelated links', () {
      final links = [
        'https://example.com/crew-invitations/123456',
        'https://chackchack.shop/crew-invitations/12345',
        'chack-chack://crew-invitations/not-a-code',
        'kakao05952ada0dceff8e149cd664e5459465://kakaolink',
      ];

      for (final link in links) {
        expect(
          CrewInviteDeepLink.extractInviteCode(Uri.parse(link)),
          isNull,
          reason: link,
        );
      }
    });
  });
}
