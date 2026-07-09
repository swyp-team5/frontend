enum SocialAuthProvider { google, kakao }

enum AuthStatus { loginSuccess, signupRequired }

enum AuthMemberRole { owner, worker }

class DevicePayload {
  final String deviceId;
  final String platform;
  final String appVersion;

  const DevicePayload({
    required this.deviceId,
    required this.platform,
    required this.appVersion,
  });

  Map<String, dynamic> toJson() {
    return {
      'deviceId': deviceId,
      'platform': platform,
      'appVersion': appVersion,
    };
  }
}

class SocialCredential {
  final SocialAuthProvider provider;
  final String? idToken;
  final String? accessToken;
  final DevicePayload device;

  const SocialCredential.google({required String idToken, required this.device})
    : provider = SocialAuthProvider.google,
      idToken = idToken,
      accessToken = null;

  const SocialCredential.kakao({
    required String accessToken,
    required this.device,
  }) : provider = SocialAuthProvider.kakao,
       idToken = null,
       accessToken = accessToken;

  Map<String, dynamic> toJson() {
    return {
      'provider': provider.name.toUpperCase(),
      if (idToken != null) 'idToken': idToken,
      if (accessToken != null) 'accessToken': accessToken,
      'device': device.toJson(),
    };
  }
}

class AuthMember {
  final int memberId;
  final String name;
  final AuthMemberRole role;
  final String status;

  const AuthMember({
    required this.memberId,
    required this.name,
    required this.role,
    required this.status,
  });

  factory AuthMember.fromJson(Map<String, dynamic> json) {
    return AuthMember(
      memberId: json['memberId'] as int,
      name: json['name'] as String,
      role: _parseMemberRole(json['role']),
      status: json['status'] as String,
    );
  }

  static AuthMemberRole _parseMemberRole(Object? value) {
    switch (value) {
      case 'OWNER':
        return AuthMemberRole.owner;
      case 'WORKER':
        return AuthMemberRole.worker;
      default:
        throw const FormatException('Unsupported member role');
    }
  }
}

class AuthResponse {
  final AuthStatus status;
  final String? accessToken;
  final String? refreshToken;
  final AuthMember? member;

  const AuthResponse.loginSuccess({
    required String accessToken,
    required String refreshToken,
    required AuthMember member,
  }) : status = AuthStatus.loginSuccess,
       accessToken = accessToken,
       refreshToken = refreshToken,
       member = member;

  const AuthResponse.signupRequired()
    : status = AuthStatus.signupRequired,
      accessToken = null,
      refreshToken = null,
      member = null;

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    switch (json['status']) {
      case 'SIGNUP_REQUIRED':
        return const AuthResponse.signupRequired();
      case 'LOGIN_SUCCESS':
        final accessToken = json['accessToken'];
        final refreshToken = json['refreshToken'];
        final member = json['member'];
        if (accessToken is! String ||
            accessToken.isEmpty ||
            refreshToken is! String ||
            refreshToken.isEmpty ||
            member is! Map<String, dynamic>) {
          throw const FormatException('Incomplete login response');
        }
        return AuthResponse.loginSuccess(
          accessToken: accessToken,
          refreshToken: refreshToken,
          member: AuthMember.fromJson(member),
        );
      default:
        throw const FormatException('Unsupported auth status');
    }
  }
}
