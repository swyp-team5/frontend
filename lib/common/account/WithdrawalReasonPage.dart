import 'package:flutter/material.dart';

/// 회원 탈퇴 사유를 선택/입력받는 페이지.
/// [onWithdraw] 콜백에서 실제 탈퇴 처리(API 호출, 세션 정리, 화면 전환)를 수행한다.
class WithdrawalReasonPage extends StatefulWidget {
  final Future<void> Function(List<String> reasons, String? etcDetail)
  onWithdraw;

  const WithdrawalReasonPage({super.key, required this.onWithdraw});

  @override
  State<WithdrawalReasonPage> createState() => _WithdrawalReasonPageState();
}

class _WithdrawalReasonPageState extends State<WithdrawalReasonPage> {
  static const int _etcMaxLength = 50;
  static const Color _withdrawColor = Color(0xFFFF4646);

  final List<String> _reasons = const [
    '필요한 기능이 없었어요',
    '사용하기 어렵고 불편해요',
    '다른 서비스를 사용할 예정이에요',
    '직원들이 앱을 사용하지 않아요',
    '기타',
  ];

  final Set<String> _selectedReasons = {};
  final TextEditingController _etcController = TextEditingController();

  bool _isSubmitting = false;

  bool get _isEtcSelected => _selectedReasons.contains('기타');

  /// 사유를 하나라도 선택해야 탈퇴 버튼이 활성화된다.
  bool get _isFormValid => _selectedReasons.isNotEmpty;

  @override
  void dispose() {
    _etcController.dispose();
    super.dispose();
  }

  void _toggleReason(String reason) {
    setState(() {
      if (_selectedReasons.contains(reason)) {
        _selectedReasons.remove(reason);
      } else {
        _selectedReasons.add(reason);
      }
    });
  }

  Future<void> _confirmAndWithdraw() async {
    if (_isSubmitting || !_isFormValid) {
      return;
    }

    final confirmed = await _showWithdrawConfirmSheet();

    if (confirmed != true || !mounted) {
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final etcDetail = _isEtcSelected && _etcController.text.trim().isNotEmpty
          ? _etcController.text.trim()
          : null;

      await widget.onWithdraw(_selectedReasons.toList(), etcDetail);
      // 실제 탈퇴 처리(API 호출 + 화면 전환)는 onWithdraw 콜백 쪽에서 담당한다.
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  Future<bool?> _showWithdrawConfirmSheet() {
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
              key: const Key('withdraw-confirm-sheet'),
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    key: const Key('withdraw-confirm-handle'),
                    width: 43,
                    height: 6,
                    decoration: BoxDecoration(
                      color: const Color(0xFFE0E2E5),
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  const SizedBox(height: 18),
                  const Text(
                    '회원 탈퇴하시겠습니까?',
                    style: TextStyle(
                      color: Color(0xFF111111),
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      height: 1.4,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    '정보들은 복구되지 않아요.',
                    style: TextStyle(
                      color: Color(0xFF767676),
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      height: 1.45,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    key: const Key('withdraw-confirm-button'),
                    width: double.infinity,
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
                        '탈퇴하기',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          height: 1.4,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    key: const Key('withdraw-cancel-button'),
                    width: double.infinity,
                    height: 18,
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () => Navigator.pop(context, false),
                      child: const Center(
                        child: Text(
                          '취소',
                          style: TextStyle(
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            _Header(onBack: () => Navigator.pop(context)),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 38, 24, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '착착을 탈퇴하려는\n이유에 대해서 말해주세요',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        height: 1.35,
                        color: Color(0xFF111111),
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      '더 나은 서비스를 위한 기반이 됩니다\n(중복 선택 가능)',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF767676),
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 28),

                    ..._reasons.map((reason) {
                      final selected = _selectedReasons.contains(reason);
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(12),
                          onTap: () => _toggleReason(reason),
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 18,
                            ),
                            decoration: BoxDecoration(
                              color: selected
                                  ? const Color(0xFFE6F3FF)
                                  : const Color(0xFFF5F5F7),
                              borderRadius: BorderRadius.circular(12),
                              border: selected
                                  ? Border.all(
                                color: const Color(0xFF0084FF),
                                width: 1.5,
                              )
                                  : null,
                            ),
                            child: Text(
                              reason,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                color: Color(0xFF111111),
                              ),
                            ),
                          ),
                        ),
                      );
                    }),

                    if (_isEtcSelected) ...[
                      const SizedBox(height: 4),
                      Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: const Color(0xFFE5E5E5)),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            TextField(
                              controller: _etcController,
                              maxLength: _etcMaxLength,
                              maxLines: 3,
                              onChanged: (_) => setState(() {}),
                              decoration: const InputDecoration(
                                border: InputBorder.none,
                                counterText: '',
                                hintText: '탈퇴 사유를 입력해주세요',
                              ),
                            ),
                            Text(
                              '${_etcController.text.length}/$_etcMaxLength',
                              style: const TextStyle(
                                fontSize: 12,
                                color: Color(0xFFB8B8BE),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 20),
              child: SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: (_isSubmitting || !_isFormValid)
                      ? null
                      : _confirmAndWithdraw,
                  style: ElevatedButton.styleFrom(
                    elevation: 0,
                    disabledBackgroundColor: _withdrawColor.withOpacity(0.6),
                    backgroundColor: _withdrawColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: _isSubmitting
                      ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                      : const Text(
                    '회원 탈퇴하기',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  final VoidCallback onBack;

  const _Header({required this.onBack});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: Align(
        alignment: Alignment.centerLeft,
        child: IconButton(
          icon: const Icon(Icons.chevron_left, size: 28),
          onPressed: onBack,
          padding: const EdgeInsets.only(left: 8),
        ),
      ),
    );
  }
}