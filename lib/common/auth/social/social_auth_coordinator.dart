import 'package:flutter/foundation.dart';

import '../api/social_auth_api.dart';
import '../model/social_auth_models.dart';
import '../server_token_manager.dart';
import '../session/auth_session_store.dart';
import 'social_identity_provider.dart';

enum SocialAuthOutcomeType { loginSuccess, signupRequired, cancelled }

class SocialAuthOutcome {
  final SocialAuthOutcomeType type;
  final AuthMember? member;
  final SocialCredential? credential;

  const SocialAuthOutcome.loginSuccess(AuthMember member)
    : type = SocialAuthOutcomeType.loginSuccess,
      member = member,
      credential = null;

  const SocialAuthOutcome.signupRequired(SocialCredential credential)
    : type = SocialAuthOutcomeType.signupRequired,
      member = null,
      credential = credential;

  const SocialAuthOutcome.cancelled()
    : type = SocialAuthOutcomeType.cancelled,
      member = null,
      credential = null;
}

abstract class SocialAuthFlow {
  Future<SocialAuthOutcome> authenticate(SocialAuthProvider provider);
}

class SocialAuthCoordinator implements SocialAuthFlow {
  final Map<SocialAuthProvider, SocialIdentityProvider> providers;
  final SocialAuthClient api;
  final AuthSessionSaver sessionSaver;

  SocialAuthCoordinator({
    required this.providers,
    required this.api,
    required this.sessionSaver,
  });

  factory SocialAuthCoordinator.standard() {
    return SocialAuthCoordinator(
      providers: {
        SocialAuthProvider.google: GoogleSocialIdentityProvider(),
        SocialAuthProvider.kakao: KakaoSocialIdentityProvider(),
      },
      api: SocialAuthApi(),
      sessionSaver: ServerTokenManager(),
    );
  }

  @override
  Future<SocialAuthOutcome> authenticate(SocialAuthProvider provider) async {
    final identityProvider = providers[provider];
    if (identityProvider == null) {
      throw const SocialProviderException(
        '지원하지 않는 로그인 방식이에요.',
        isConfigurationError: true,
      );
    }

    final credential = await identityProvider.authenticate();
    if (credential == null) {
      debugPrint('[SocialAuth][${provider.name}] provider cancelled');
      return const SocialAuthOutcome.cancelled();
    }

    debugPrint('[SocialAuth][${provider.name}] credential acquired');
    final response = await api.login(credential);
    debugPrint(
      '[SocialAuth][${provider.name}] backend result=${response.status.name}',
    );
    switch (response.status) {
      case AuthStatus.loginSuccess:
        await sessionSaver.saveSession(
          AuthSession(
            accessToken: response.accessToken!,
            refreshToken: response.refreshToken!,
            deviceId: credential.device.deviceId,
          ),
        );
        return SocialAuthOutcome.loginSuccess(response.member!);
      case AuthStatus.signupRequired:
        return SocialAuthOutcome.signupRequired(credential);
    }
  }
}
