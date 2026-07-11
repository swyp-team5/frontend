import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../employee/home/EHomePage.dart';
import '../../../auth/server_token_manager.dart';
import '../../api/terms_api.dart';
import '../../models/terms_models.dart';
import '../../models/signup_request.dart';
import '../../providers/signup_provider.dart';
import '../employer/RSignUpPage.dart';
import 'TermsDetailBottomSheet.dart';

enum UserRole {
  owner,
  worker,
}

class AgreementPage extends ConsumerStatefulWidget {
  final UserRole role;

  const AgreementPage({
    super.key,
    required this.role,
  });

  @override
  ConsumerState<AgreementPage> createState() => _AgreementPageState();
}

class _AgreementPageState extends ConsumerState<AgreementPage> {
  final TermsApi _termsApi = TermsApi();

  List<TermsItem> terms = [];
  bool isLoading = true;
  String? error;

  bool get allAgree => terms.isNotEmpty && terms.every((t) => t.agreed);

  bool get requiredAgree =>
      terms.where((t) => t.isRequired).every((t) => t.agreed);

  @override
  void initState() {
    super.initState();
    _loadTerms();
  }

  Future<void> _loadTerms() async {
    setState(() {
      isLoading = true;
      error = null;
    });

    try {
      final role = widget.role == UserRole.owner ? 'OWNER' : 'WORKER';
      final result = await _termsApi.getSignupTerms(role: role);

      // 이 화면은 역할 공통 동의 단계라, COMMON 약관만 보여준다.
      // (OWNER 전용 약관은 이후 RSignUp3에서 별도로 노출됨)
      final commonTerms = result.where((t) => t.termsType == 'COMMON').toList();

      if (!mounted) return;

      setState(() {
        terms = commonTerms;
        isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        isLoading = false;
        error = e.toString().replaceFirst('Exception: ', '');
      });
    }
  }

  void toggleAll(bool value) {
    setState(() {
      for (final t in terms) {
        t.agreed = value;
      }
    });
  }

  void toggleOne(TermsItem term, bool value) {
    setState(() {
      term.agreed = value;
    });
  }

  Widget agreementItem(TermsItem term) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 14),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => toggleOne(term, !term.agreed),
            child: Container(
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: term.agreed ? const Color(0xff0084FF) : const Color(0xffD9D9D9),
                  width: 1.5,
                ),
                color: term.agreed ? const Color(0xff0084FF) : Colors.white,
              ),
              child: term.agreed
                  ? const Icon(Icons.check, color: Colors.white, size: 18)
                  : null,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              "[${term.isRequired ? '필수' : '선택'}] ${term.title}",
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w500,
                color: Color(0xFF505050),
              ),
            ),
          ),
          IconButton(
            // content가 없는 약관(예: "만 14세 이상입니다")은 상세보기 자체가 없으므로 비활성화한다.
            onPressed: term.content == null
                ? null
                : () {
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                backgroundColor: Colors.transparent,
                builder: (_) => TermsDetailBottomSheet(
                  title: term.title,
                  content: term.content!,
                ),
              );
            },
            icon: Icon(
              Icons.arrow_forward_ios,
              size: 18,
              color: term.content == null ? const Color(0xFFD9D9D9) : null,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _submit() async {
    final notifier = ref.read(signupProvider.notifier);

    notifier.setTerms(
      terms.map((t) => TermsAgreement(termsId: t.termsId, agreed: t.agreed)).toList(),
    );

    if (widget.role == UserRole.owner) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const RSignUpPage()),
      );
      return;
    }

    try {
      final success = await notifier.signUp();
      if (!context.mounted) return;

      if (success) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const EHomePage()),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("회원가입 처리 중 오류가 발생했습니다.")),
        );
      }
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("회원가입 실패: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 22),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 24),
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: const Icon(Icons.arrow_back_ios_new),
              ),
              const SizedBox(height: 70),
              const Text(
                "서비스 이용을 위해\n동의가 필요해요",
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.w600, height: 1.35),
              ),
              const SizedBox(height: 36),

              if (isLoading)
                const Expanded(child: Center(child: CircularProgressIndicator()))
              else if (error != null)
                Expanded(
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(error!, style: const TextStyle(color: Colors.red)),
                        const SizedBox(height: 12),
                        ElevatedButton(onPressed: _loadTerms, child: const Text("다시 시도")),
                      ],
                    ),
                  ),
                )
              else
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: const Color(0xFFE5E5EC)),
                          ),
                          child: Row(
                            children: [
                              GestureDetector(
                                onTap: () => toggleAll(!allAgree),
                                child: Container(
                                  width: 30,
                                  height: 30,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: allAgree ? const Color(0xff0084FF) : const Color(0xffD9D9D9),
                                      width: 1.5,
                                    ),
                                    color: allAgree ? const Color(0xff0084FF) : Colors.white,
                                  ),
                                  child: allAgree
                                      ? const Icon(Icons.check, color: Colors.white, size: 18)
                                      : null,
                                ),
                              ),
                              const SizedBox(width: 12),
                              const Text(
                                "필수 및 선택 동의 모두 선택",
                                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Color(0xFF767676)),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 28),
                        ...terms.map(agreementItem),
                      ],
                    ),
                  ),
                ),

              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                height: 58,
                child: ElevatedButton(
                  onPressed: requiredAgree ? _submit : null,
                  style: ElevatedButton.styleFrom(
                    elevation: 0,
                    backgroundColor: const Color(0xff0084FF),
                    disabledBackgroundColor: const Color(0xff80C1FF),
                    disabledForegroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  child: const Text(
                    "동의 후 서비스 시작하기",
                    style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
