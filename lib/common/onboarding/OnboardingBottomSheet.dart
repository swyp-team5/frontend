import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../employee/home/EHomePage.dart';
import '../../employer/home/RHomePage.dart';
import '../auth/api/social_auth_api.dart';
import '../auth/model/social_auth_models.dart';
import '../auth/social/social_auth_coordinator.dart';
import '../auth/social/social_identity_provider.dart';
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
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 56,
                height: 6,
                decoration: BoxDecoration(
                  color: const Color(0xFFE5E5E5),
                  borderRadius: BorderRadius.circular(100),
                ),
              ),
              const SizedBox(height: 28),
              const Text(
                '스케줄 관리를 더 쉽고 간편하게',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF111111),
                ),
              ),
              const SizedBox(height: 20),
              _SocialButton(
                key: const Key('kakao-login-button'),
                label: '카카오로 시작하기',
                backgroundColor: const Color(0xFFFEE500),
                assetPath: 'assets/images/logo/kakaotalk.png',
                isLoading: _loadingProvider == SocialAuthProvider.kakao,
                onPressed: _isLoading
                    ? null
                    : () => _authenticate(SocialAuthProvider.kakao),
              ),
              const SizedBox(height: 10),
              _SocialButton(
                key: const Key('google-login-button'),
                label: 'Google로 시작하기',
                backgroundColor: Colors.white,
                assetPath: 'assets/images/logo/google.png',
                borderColor: const Color(0xFFE5E5E5),
                isLoading: _loadingProvider == SocialAuthProvider.google,
                onPressed: _isLoading
                    ? null
                    : () => _authenticate(SocialAuthProvider.google),
              ),
              const SizedBox(height: 22),
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
        ),
      ),
    );
  }
}

class _SocialButton extends StatelessWidget {
  final String label;
  final Color backgroundColor;
  final String assetPath;
  final Color? borderColor;
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
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 38,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 14),
          backgroundColor: backgroundColor,
          disabledBackgroundColor: backgroundColor,
          foregroundColor: const Color(0xFF111111),
          disabledForegroundColor: const Color(0xFF111111),
          side: borderColor == null
              ? BorderSide.none
              : BorderSide(color: borderColor!),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
        ),
        child: isLoading
            ? const SizedBox.square(
                dimension: 18,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Color(0xFF111111),
                ),
              )
            : Stack(
                alignment: Alignment.center,
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Image.asset(assetPath, width: 18, height: 18),
                  ),
                  Text(
                    label,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
