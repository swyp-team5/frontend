import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../../employee/home/EHomePage.dart';
import '../../employer/home/RHomePage.dart';
import '../auth/api/social_auth_api.dart';
import '../auth/model/social_auth_models.dart';
import '../auth/social/social_auth_coordinator.dart';
import '../auth/social/social_identity_provider.dart';
import '../fcm/FcmSetupService.dart'; // FCM
import 'providers/signup_provider.dart';
import 'signup/CommonSignUpPage.dart';

class OnboardingBottomSheet extends ConsumerStatefulWidget {
  final SocialAuthFlow? authFlow;
  final WidgetBuilder? ownerHomeBuilder;
  final WidgetBuilder? workerHomeBuilder;
  final WidgetBuilder? signupBuilder;

  const OnboardingBottomSheet({
    super.key,
    this.authFlow,
    this.ownerHomeBuilder,
    this.workerHomeBuilder,
    this.signupBuilder,
  });

  @override
  ConsumerState<OnboardingBottomSheet> createState() =>
      _OnboardingBottomSheetState();
}

class _OnboardingBottomSheetState extends ConsumerState<OnboardingBottomSheet> {
  late final SocialAuthFlow _authFlow;
  SocialAuthProvider? _loadingProvider;

  bool get _isLoading => _loadingProvider != null;

  @override
  void initState() {
    super.initState();
    _authFlow = widget.authFlow ?? SocialAuthCoordinator.standard();
  }

  Future<void> _authenticate(SocialAuthProvider provider) async {
    if (_isLoading) {
      return;
    }

    setState(() => _loadingProvider = provider);
    try {
      final outcome = await _authFlow.authenticate(provider);
      if (!mounted) {
        return;
      }

      switch (outcome.type) {
        case SocialAuthOutcomeType.loginSuccess:
          // FCM 토큰 등록 (실패해도 로그인 흐름은 계속 진행)
          _registerFcmToken();
          _openHome(outcome.member!);
        case SocialAuthOutcomeType.signupRequired:
          ref
              .read(signupProvider.notifier)
              .prepareSocialSignup(outcome.credential!);
          await Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: widget.signupBuilder ?? (_) => const CommonSignUpPage(),
            ),
          );
        case SocialAuthOutcomeType.cancelled:
          return;
      }
    } on SocialProviderException catch (error) {
      debugPrint(
        '[SocialAuth][UI] provider failure type=${error.runtimeType} '
        'configuration=${error.isConfigurationError}',
      );
      _showError(error.message);
    } on SocialAuthException catch (error) {
      debugPrint('[SocialAuth][UI] backend failure status=${error.statusCode}');
      _showError('소셜 로그인에 실패했어요. 잠시 후 다시 시도해주세요.');
    } catch (error) {
      debugPrint(
        '[SocialAuth][UI] unexpected failure type=${error.runtimeType}',
      );
      _showError('소셜 로그인에 실패했어요. 잠시 후 다시 시도해주세요.');
    } finally {
      if (mounted) {
        setState(() => _loadingProvider = null);
      }
    }
  }

  /// 로그인 성공 후 FCM 토큰을 등록합니다.
  /// 실패하더라도 로그인/홈 이동 흐름에는 영향을 주지 않습니다.
  Future<void> _registerFcmToken() async {
    try {
      final deviceInfoPlugin = DeviceInfoPlugin();
      final packageInfo = await PackageInfo.fromPlatform();

      String deviceId = '';
      String platform = '';

      if (Platform.isAndroid) {
        final androidInfo = await deviceInfoPlugin.androidInfo;
        deviceId = androidInfo.id;
        platform = 'ANDROID';
      } else if (Platform.isIOS) {
        final iosInfo = await deviceInfoPlugin.iosInfo;
        deviceId = iosInfo.identifierForVendor ?? '';
        platform = 'IOS';
      }

      await FcmSetupService.registerCurrentDevice(
        deviceId: deviceId,
        platform: platform,
        appVersion: packageInfo.version,
      );
    } catch (error) {
      debugPrint('[FCM][UI] token registration failed: $error');
    }
  }

  void _openHome(AuthMember member) {
    final builder = switch (member.role) {
      AuthMemberRole.owner =>
        widget.ownerHomeBuilder ?? (_) => const RHomePage(),
      AuthMemberRole.worker =>
        widget.workerHomeBuilder ?? (_) => const EHomePage(),
    };

    Navigator.of(
      context,
    ).pushAndRemoveUntil(MaterialPageRoute(builder: builder), (_) => false);
  }

  void _showError(String message) {
    if (!mounted) {
      return;
    }
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final showsAppleLogin = Theme.of(context).platform == TargetPlatform.iOS;

    return Container(
      height: 345,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          const SizedBox(height: 12),
          Container(
            width: 43,
            height: 6,
            decoration: BoxDecoration(
              color: const Color(0xFFE0E2E5),
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          const SizedBox(height: 18),
          const Text(
            '스케줄 관리를 더 쉽고 간편하게',
            style: TextStyle(
              fontFamily: 'Pretendard',
              fontSize: 18,
              fontWeight: FontWeight.w600,
              height: 1.4,
              color: Color(0xFF111111),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Divider(height: 1, thickness: 1, color: Color(0xFFE5E5EC)),
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              children: [
                _SocialButton(
                  key: const Key('kakao-login-button'),
                  label: '카카오로 시작하기',
                  backgroundColor: const Color(0xFFFFE200),
                  assetPath: 'assets/images/logo/kakaotalk.png',
                  iconWidth: 20,
                  iconHeight: 20,
                  iconColor: const Color(0xE6111111),
                  isLoading: _loadingProvider == SocialAuthProvider.kakao,
                  onPressed: _isLoading
                      ? null
                      : () => _authenticate(SocialAuthProvider.kakao),
                ),
                const SizedBox(height: 8),
                _SocialButton(
                  key: const Key('google-login-button'),
                  label: 'Google로 시작하기',
                  backgroundColor: Colors.white,
                  assetPath: 'assets/images/logo/google.png',
                  borderColor: const Color(0xFFE5E5EC),
                  isLoading: _loadingProvider == SocialAuthProvider.google,
                  onPressed: _isLoading
                      ? null
                      : () => _authenticate(SocialAuthProvider.google),
                ),
                if (showsAppleLogin) ...[
                  const SizedBox(height: 8),
                  _SocialButton(
                    key: const Key('apple-login-button'),
                    label: 'Apple로 시작하기',
                    backgroundColor: Colors.white,
                    assetPath: 'assets/images/logo/apple.png',
                    borderColor: const Color(0xFFE5E5EC),
                    isLoading: _loadingProvider == SocialAuthProvider.apple,
                    onPressed: _isLoading
                        ? null
                        : () => _authenticate(SocialAuthProvider.apple),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 24),
          const Text.rich(
            TextSpan(
              style: TextStyle(
                color: Color(0xFF505050),
                fontSize: 13,
                fontWeight: FontWeight.w400,
              ),
              children: [
                TextSpan(text: '이미 계정이 있거나 초대받았다면 '),
                TextSpan(
                  text: '바로 시작하기',
                  style: TextStyle(
                    color: Color(0xFF0084FF),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _SocialButton extends StatelessWidget {
  static const double _iconSize = 20;
  static const double _contentWidth = 230;

  static const TextStyle _labelStyle = TextStyle(
    fontFamily: 'Pretendard',
    fontSize: 16,
    fontWeight: FontWeight.w500,
    height: 1.375,
    color: Color(0xFF111111),
  );

  final String label;
  final Color backgroundColor;
  final String assetPath;
  final Color? borderColor;
  final double iconWidth;
  final double iconHeight;
  final Color? iconColor;
  final bool isLoading;
  final VoidCallback? onPressed;

  const _SocialButton({
    super.key,
    required this.label,
    required this.backgroundColor,
    required this.assetPath,
    required this.isLoading,
    required this.onPressed,
    this.borderColor,
    this.iconWidth = _iconSize,
    this.iconHeight = _iconSize,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton(
            onPressed: onPressed,
            style: ElevatedButton.styleFrom(
              elevation: 0,
              padding: EdgeInsets.zero,
              backgroundColor: backgroundColor,
              disabledBackgroundColor: backgroundColor,
              foregroundColor: const Color(0xFF111111),
              disabledForegroundColor: const Color(0xFF111111),
              side: borderColor == null
                  ? BorderSide.none
                  : BorderSide(color: borderColor!, width: 1),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: isLoading
                ? const SizedBox.square(
                    dimension: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Color(0xFF111111),
                    ),
                  )
                : Center(
                    child: SizedBox(
                      width: _contentWidth,
                      height: _iconSize,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: _iconSize,
                            height: _iconSize,
                            child: Center(
                              child: Image.asset(
                                assetPath,
                                width: iconWidth,
                                height: iconHeight,
                                fit: BoxFit.contain,
                                color: iconColor,
                                colorBlendMode:
                                    iconColor == null ? null : BlendMode.srcIn,
                              ),
                            ),
                          ),
                          const SizedBox(width: 28),
                          Expanded(
                            child: Text(
                              label,
                              style: _labelStyle,
                              maxLines: 1,
                              overflow: TextOverflow.visible,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
          ),
        );
      }
    }
