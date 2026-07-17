class CrewInviteDeepLink {
  static final RegExp _inviteCodePattern = RegExp(r'^\d{6}$');

  static String? extractInviteCode(Uri uri) {
    final String? candidate;

    if (_isHttpsInviteLink(uri)) {
      candidate = uri.pathSegments[1];
    } else if (_isDirectCustomScheme(uri)) {
      candidate = uri.pathSegments.first;
    } else if (_isKakaoTalkShareScheme(uri)) {
      candidate = uri.queryParameters['inviteCode'];
    } else {
      return null;
    }

    return candidate != null && _inviteCodePattern.hasMatch(candidate)
        ? candidate
        : null;
  }

  static bool _isHttpsInviteLink(Uri uri) {
    return uri.scheme == 'https' &&
        uri.host == 'chackchack.shop' &&
        uri.pathSegments.length == 2 &&
        uri.pathSegments.first == 'crew-invitations';
  }

  static bool _isDirectCustomScheme(Uri uri) {
    return uri.scheme == 'chack-chack' &&
        uri.host == 'crew-invitations' &&
        uri.pathSegments.length == 1;
  }

  static bool _isKakaoTalkShareScheme(Uri uri) {
    return uri.scheme.startsWith('kakao') && uri.host == 'kakaolink';
  }
}
