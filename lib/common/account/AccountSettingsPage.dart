import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../auth/server_token_manager.dart';
import '../fcm/api/NotificationSettingsApi.dart';
import '../onboarding/OnboardingPage.dart';
import 'account_settings_api.dart';

class AccountSettingsPage extends StatefulWidget {
  final Future<bool> Function()? loadPushEnabled;
  final Future<SocialAccountProvider?> Function()? loadSocialProvider;
  final Future<void> Function(bool value)? updatePushEnabled;
  final Future<void> Function()? logout;
  final Future<void> Function()? withdraw;
  final Future<void> Function()? clearSession;
  final WidgetBuilder? signedOutBuilder;

  const AccountSettingsPage({
    super.key,
    this.loadPushEnabled,
    this.loadSocialProvider,
    this.updatePushEnabled,
    this.logout,
    this.withdraw,
    this.clearSession,
    this.signedOutBuilder,
  });

  @override
  State<AccountSettingsPage> createState() => _AccountSettingsPageState();
}

class _AccountSettingsPageState extends State<AccountSettingsPage> {
  final AccountSettingsApi _accountApi = AccountSettingsApi();

  bool _fcmPushEnabled = true;
  SocialAccountProvider? _socialProvider;
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    _loadNotificationSettings();
    _loadSocialProvider();
  }

  Future<void> _loadNotificationSettings() async {
    try {
      final enabled = widget.loadPushEnabled != null
          ? await widget.loadPushEnabled!()
          : (await NotificationSettingsApi.getSettings()).fcmPushEnabled;
      if (!mounted) {
        return;
      }
      setState(() => _fcmPushEnabled = enabled);
    } catch (error) {
      debugPrint('알림 설정 조회 실패: $error');
    }
  }

  Future<void> _toggleFcmPush(bool value) async {
    setState(() => _fcmPushEnabled = value);

    try {
      if (widget.updatePushEnabled != null) {
        await widget.updatePushEnabled!(value);
      } else {
        await NotificationSettingsApi.updateSettings(fcmPushEnabled: value);
      }
    } catch (error) {
      debugPrint('알림 설정 변경 실패: $error');
      if (!mounted) {
        return;
      }
      setState(() => _fcmPushEnabled = !value);
      _showSnackBar('알림 설정 변경에 실패했어요. 다시 시도해주세요.');
    }
  }

  Future<void> _loadSocialProvider() async {
    try {
      final provider = widget.loadSocialProvider != null
          ? await widget.loadSocialProvider!()
          : await _accountApi.loadSocialProvider();
      if (!mounted) {
        return;
      }
      setState(() => _socialProvider = provider);
    } catch (error) {
      debugPrint('소셜 계정 조회 실패: $error');
    }
  }

  Future<void> _logout() async {
    final confirmed = await _showLogoutConfirmSheet();
    if (confirmed != true) {
      return;
    }

    await _runAccountAction(
      action: widget.logout ?? _accountApi.logout,
      successMessage: null,
    );
  }

  Future<bool?> _showLogoutConfirmSheet() {
    return showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        final bottomInset = MediaQuery.paddingOf(context).bottom;
        return Padding(
          padding: EdgeInsets.fromLTRB(20, 0, 20, bottomInset),
          child: Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              key: const Key('logout-confirm-sheet'),
              width: 353,
              height: 231,
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                children: [
                  Container(
                    key: const Key('logout-confirm-handle'),
                    width: 43,
                    height: 6,
                    decoration: BoxDecoration(
                      color: const Color(0xFFE0E2E5),
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  const SizedBox(height: 18),
                  const Text(
                    '로그아웃하시겠습니까?',
                    style: TextStyle(
                      fontFamily: 'Pretendard',
                      color: Color(0xFF111111),
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      height: 1.4,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    '속한 모든 매장에서 로그아웃돼요',
                    style: TextStyle(
                      fontFamily: 'Pretendard',
                      color: Color(0xFF767676),
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      height: 1.45,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    key: const Key('logout-confirm-button'),
                    width: 313,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context, true),
                      style: ElevatedButton.styleFrom(
                        elevation: 0,
                        padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
                        backgroundColor: const Color(0xFF0084FF),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text(
                        '로그아웃',
                        style: TextStyle(
                          fontFamily: 'Pretendard',
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          height: 1.4,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 25),
                  SizedBox(
                    key: const Key('logout-cancel-button'),
                    width: 321,
                    height: 18,
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () => Navigator.pop(context, false),
                      child: const Center(
                        child: Text(
                          '취소',
                          style: TextStyle(
                            fontFamily: 'Pretendard',
                            color: Color(0xFF111111),
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            height: 1.4,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> _confirmWithdrawal() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('정말 탈퇴하시겠어요?'),
          content: const Text('탈퇴 신청 후 계정 이용이 제한될 수 있어요.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('취소'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text(
                '탈퇴',
                style: TextStyle(color: Color(0xFFFF3B30)),
              ),
            ),
          ],
        );
      },
    );

    if (confirmed != true) {
      return;
    }

    await _runAccountAction(
      action: widget.withdraw ?? _accountApi.withdraw,
      successMessage: '회원 탈퇴가 신청됐어요.',
    );
  }

  Future<void> _runAccountAction({
    required Future<void> Function() action,
    required String? successMessage,
  }) async {
    if (_isProcessing) {
      return;
    }

    setState(() => _isProcessing = true);
    try {
      await action();
      await (widget.clearSession ?? ServerTokenManager.clear)();
      if (!mounted) {
        return;
      }
      if (successMessage != null) {
        _showSnackBar(successMessage);
      }
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(
          builder: widget.signedOutBuilder ?? (_) => const OnboardingPage(),
        ),
        (_) => false,
      );
    } catch (error) {
      debugPrint('계정 설정 처리 실패: $error');
      if (!mounted) {
        return;
      }
      _showSnackBar('요청 처리에 실패했어요. 다시 시도해주세요.');
    } finally {
      if (mounted) {
        setState(() => _isProcessing = false);
      }
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: SafeArea(
        child: Column(
          children: [
            _Header(onBack: () => Navigator.pop(context)),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _Card(
                      key: const Key('account-settings-social-card'),
                      children: [
                        _MenuRow(
                          title: '연동된 소셜 계정',
                          trailing: _SocialAccountTrailing(
                            provider: _socialProvider,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),
                    _SectionTitle('마케팅 관리'),
                    const SizedBox(height: 14),
                    _Card(
                      children: [
                        _SwitchRow(
                          title: '푸시 알림',
                          value: _fcmPushEnabled,
                          onChanged: _toggleFcmPush,
                        ),
                        const Divider(height: 1, color: Color(0xFFF2F2F2)),
                        const _MenuRow(title: '약관 및 개인정보 처리 동의 내역'),
                      ],
                    ),
                    const SizedBox(height: 32),
                    _SectionTitle('계정 관리'),
                    const SizedBox(height: 14),
                    _Card(
                      children: [
                        _MenuRow(
                          title: '로그아웃',
                          onTap: _isProcessing ? null : _logout,
                        ),
                        const Divider(height: 1, color: Color(0xFFF2F2F2)),
                        _MenuRow(
                          title: '회원 탈퇴',
                          textColor: const Color(0xFFFF3B30),
                          onTap: _isProcessing ? null : _confirmWithdrawal,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SocialAccountTrailing extends StatelessWidget {
  final SocialAccountProvider? provider;

  const _SocialAccountTrailing({required this.provider});

  @override
  Widget build(BuildContext context) {
    if (provider == null) {
      return const Icon(Icons.chevron_right, color: Color(0xFFB8B8BE));
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _SocialAccountIcon(provider: provider!),
        const SizedBox(width: 10),
        const Icon(Icons.chevron_right, color: Color(0xFFB8B8BE)),
      ],
    );
  }
}

class _SocialAccountIcon extends StatelessWidget {
  final SocialAccountProvider provider;

  const _SocialAccountIcon({required this.provider});

  @override
  Widget build(BuildContext context) {
    return switch (provider) {
      SocialAccountProvider.kakao => SvgPicture.asset(
        'assets/images/logo/kakao.svg',
        width: 18,
        height: 17,
      ),
      SocialAccountProvider.google => Image.asset(
        'assets/images/logo/google.png',
        width: 18,
        height: 18,
      ),
      SocialAccountProvider.apple => Image.asset(
        'assets/images/logo/apple.png',
        width: 18,
        height: 18,
      ),
    };
  }
}

class _Header extends StatelessWidget {
  final VoidCallback onBack;

  const _Header({required this.onBack});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 64,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned(
            left: 14,
            child: IconButton(
              key: const Key('account-settings-back-button'),
              icon: const Icon(Icons.chevron_left, size: 28),
              onPressed: onBack,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints.tightFor(width: 32, height: 32),
            ),
          ),
          const Text(
            '계정 설정',
            style: TextStyle(
              color: Color(0xFF111111),
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;

  const _SectionTitle(this.title);

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: const TextStyle(
        color: Color(0xFF767676),
        fontSize: 16,
        fontWeight: FontWeight.w600,
      ),
    );
  }
}

class _Card extends StatelessWidget {
  final List<Widget> children;

  const _Card({super.key, required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(children: children),
    );
  }
}

class _MenuRow extends StatelessWidget {
  final String title;
  final Color textColor;
  final VoidCallback? onTap;
  final Widget? trailing;

  const _MenuRow({
    required this.title,
    this.textColor = const Color(0xFF111111),
    this.onTap,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        child: Row(
          children: [
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  color: textColor,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            trailing ??
                const Icon(Icons.chevron_right, color: Color(0xFFB8B8BE)),
          ],
        ),
      ),
    );
  }
}

class _SwitchRow extends StatelessWidget {
  final String title;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _SwitchRow({
    required this.title,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                color: Color(0xFF111111),
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Switch(
            value: value,
            activeColor: const Color(0xFF0084FF),
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}
