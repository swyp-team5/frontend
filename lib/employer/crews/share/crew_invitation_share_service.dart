import 'package:kakao_flutter_sdk_share/kakao_flutter_sdk_share.dart';

enum KakaoInvitationShareResult { opened, unavailable }

class CrewInvitationShareContent {
  CrewInvitationShareContent({required String inviteCode})
    : text = '착착 크루 초대\n초대 코드를 확인하고 매장에 합류해 주세요.\n초대 코드: $inviteCode',
      buttonTitle = '착착에서 초대 확인',
      webUrl = Uri.parse(
        'https://chackchack.shop/crew-invitations/$inviteCode',
      ),
      executionParams = {'inviteCode': inviteCode};

  final String text;
  final String buttonTitle;
  final Uri webUrl;
  final Map<String, String> executionParams;
}

abstract class KakaoTalkShareGateway {
  Future<bool> canShare();

  Future<void> open(CrewInvitationShareContent content);
}

class KakaoSdkTalkShareGateway implements KakaoTalkShareGateway {
  const KakaoSdkTalkShareGateway();

  @override
  Future<bool> canShare() {
    return ShareClient.instance.isKakaoTalkSharingAvailable();
  }

  @override
  Future<void> open(CrewInvitationShareContent content) async {
    final template = TextTemplate(
      text: content.text,
      link: Link(
        webUrl: content.webUrl,
        mobileWebUrl: content.webUrl,
        androidExecutionParams: content.executionParams,
        iosExecutionParams: content.executionParams,
      ),
      buttonTitle: content.buttonTitle,
    );
    final shareUri = await ShareClient.instance.shareDefault(
      template: template,
    );
    await ShareClient.instance.launchKakaoTalk(shareUri);
  }
}

class CrewInvitationShareService {
  CrewInvitationShareService({KakaoTalkShareGateway? gateway})
    : _gateway = gateway ?? const KakaoSdkTalkShareGateway();

  static final RegExp _inviteCodePattern = RegExp(r'^\d{6}$');

  final KakaoTalkShareGateway _gateway;

  Future<KakaoInvitationShareResult> share({required String inviteCode}) async {
    if (!_inviteCodePattern.hasMatch(inviteCode)) {
      throw ArgumentError.value(inviteCode, 'inviteCode');
    }

    if (!await _gateway.canShare()) {
      return KakaoInvitationShareResult.unavailable;
    }

    await _gateway.open(CrewInvitationShareContent(inviteCode: inviteCode));
    return KakaoInvitationShareResult.opened;
  }
}
