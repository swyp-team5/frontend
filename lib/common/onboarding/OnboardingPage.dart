import 'dart:async';
import 'package:flutter/material.dart';

import 'OnboardingBottomSheet.dart';

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  final PageController _controller = PageController();

  int currentPage = 0;

  // ---- 3번 터치 감지용 상태 ----
  int _titleTapCount = 0;
  Timer? _tapResetTimer;

  final List<_OnboardingItem> items = [
    _OnboardingItem(
      title: "착착과 함께 매장관리를\n더 쉽게 시작해요",
      image: "assets/images/onboarding/onboarding1.png",
    ),
    _OnboardingItem(
      title: "자동 생성 기능으로\n복잡한 스케줄을 착착!",
      image: "assets/images/onboarding/onboarding2.png",
    ),
    _OnboardingItem(
      title: "근무 변경 요청도\n착착에서 간편하게",
      image: "assets/images/onboarding/onboarding3.png",
    ),
    _OnboardingItem(
      title: "중요한 공지사항도\n이제 놓지지 않고 확인해요",
      image: "assets/images/onboarding/onboarding4.png",
    ),
  ];

  void _openSocialLogin() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => OnboardingBottomSheet(),
    );
  }

  //--------------------------------------
  // 타이틀 3회 터치 -> 테스트 로그인 폼 모달
  //--------------------------------------
  void _onTitleTap() {
    _titleTapCount++;

    _tapResetTimer?.cancel();
    _tapResetTimer = Timer(const Duration(milliseconds: 1200), () {
      _titleTapCount = 0;
    });

    if (_titleTapCount >= 3) {
      _titleTapCount = 0;
      _tapResetTimer?.cancel();
      _showTestLoginSheet();
    }
  }

  //--------------------------------------
  // 테스트용 아이디/비밀번호 직접 입력 모달
  //--------------------------------------
  void _showTestLoginSheet() {
    final idController = TextEditingController();
    final passwordController = TextEditingController();
    bool obscurePassword = true;
    bool isSubmitting = false;
    String? errorText;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (sheetContext, setSheetState) {
            return Padding(
              // 키보드가 올라올 때 모달이 가려지지 않도록
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(sheetContext).viewInsets.bottom,
              ),
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        '테스트 계정 로그인',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        '심사/테스트용 계정 정보를 입력해주세요.',
                        style: TextStyle(
                          fontSize: 13,
                          color: Color(0xff767676),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // 아이디 입력
                      TextField(
                        controller: idController,
                        keyboardType: TextInputType.emailAddress,
                        textInputAction: TextInputAction.next,
                        decoration: InputDecoration(
                          labelText: '아이디 (이메일)',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),

                      // 비밀번호 입력
                      TextField(
                        controller: passwordController,
                        obscureText: obscurePassword,
                        textInputAction: TextInputAction.done,
                        decoration: InputDecoration(
                          labelText: '비밀번호',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          suffixIcon: IconButton(
                            icon: Icon(
                              obscurePassword
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                            ),
                            onPressed: () {
                              setSheetState(() {
                                obscurePassword = !obscurePassword;
                              });
                            },
                          ),
                        ),
                        onSubmitted: (_) {
                          _submitTestLogin(
                            sheetContext: sheetContext,
                            id: idController.text.trim(),
                            password: passwordController.text,
                            setSheetState: setSheetState,
                            setSubmitting: (v) => isSubmitting = v,
                            setError: (v) => errorText = v,
                          );
                        },
                      ),

                      if (errorText != null) ...[
                        const SizedBox(height: 8),
                        Text(
                          errorText!,
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.red,
                          ),
                        ),
                      ],

                      const SizedBox(height: 20),

                      // 로그인 버튼
                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xff0084FF),
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          onPressed: isSubmitting
                              ? null
                              : () {
                            _submitTestLogin(
                              sheetContext: sheetContext,
                              id: idController.text.trim(),
                              password: passwordController.text,
                              setSheetState: setSheetState,
                              setSubmitting: (v) =>
                              isSubmitting = v,
                              setError: (v) => errorText = v,
                            );
                          },
                          child: isSubmitting
                              ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                              : const Text(
                            '로그인',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
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
      },
    );
  }

  Future<void> _submitTestLogin({
    required BuildContext sheetContext,
    required String id,
    required String password,
    required void Function(void Function()) setSheetState,
    required void Function(bool) setSubmitting,
    required void Function(String?) setError,
  }) async {
    if (id.isEmpty || password.isEmpty) {
      setSheetState(() {
        setError('아이디와 비밀번호를 모두 입력해주세요.');
      });
      return;
    }

    setSheetState(() {
      setSubmitting(true);
      setError(null);
    });

    try {
      // TODO: 실제 로그인 API/인증 로직으로 교체하세요.
      // 예시: final result = await AuthService.login(id: id, password: password);
      // 실패 시 예외를 던지거나 result에서 성공 여부를 확인하세요.

      await Future.delayed(const Duration(milliseconds: 600)); // 임시 딜레이

      if (!mounted) return;

      Navigator.of(sheetContext).pop(); // 모달 닫기

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('로그인 성공: $id')),
      );

      // TODO: 로그인 성공 후 다음 화면으로 이동
      // Navigator.of(context).pushReplacement(
      //   MaterialPageRoute(builder: (_) => const HomePage()),
      // );
    } catch (e) {
      setSheetState(() {
        setSubmitting(false);
        setError('로그인에 실패했습니다. 아이디/비밀번호를 확인해주세요.');
      });
    }
  }

  @override
  void dispose() {
    _tapResetTimer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 24),

            //--------------------------------------
            // Indicator
            //--------------------------------------
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                items.length,
                    (index) => AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: currentPage == index
                        ? const Color(0xff0084FF)
                        : const Color(0xffD9D9D9),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 50),

            //--------------------------------------
            // PageView
            //--------------------------------------
            Expanded(
              child: PageView.builder(
                controller: _controller,
                itemCount: items.length,
                onPageChanged: (index) {
                  setState(() {
                    currentPage = index;
                  });
                },
                itemBuilder: (context, index) {
                  final item = items[index];

                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      children: [
                        //----------------------------------
                        // 제목 (3번 터치 시 테스트 로그인 폼)
                        //----------------------------------
                        GestureDetector(
                          onTap: _onTitleTap,
                          behavior: HitTestBehavior.opaque,
                          child: Text(
                            item.title,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w700,
                              height: 1.35,
                            ),
                          ),
                        ),

                        const SizedBox(height: 40),

                        //----------------------------------
                        // 휴대폰 이미지
                        //----------------------------------
                        Expanded(
                          child: FittedBox(
                            fit: BoxFit.contain,
                            alignment: Alignment.bottomCenter,
                            child: Image.asset(item.image),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),

            //--------------------------------------
            // 회원가입 버튼
            //--------------------------------------
            Padding(
              padding: const EdgeInsets.fromLTRB(30, 0, 30, 20),
              child: SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xff0084FF),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onPressed: _openSocialLogin,

                  child: const Text(
                    "회원가입 바로가기",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 18),

            //--------------------------------------
            // 시작하기
            //--------------------------------------
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              // children: [
              //   const Text(
              //     "이미 계정이 있거나 초대받았다면 ",
              //     style: TextStyle(
              //       fontSize: 13,
              //       fontWeight: FontWeight.w400,
              //       color: Color(0xff767676),
              //     ),
              //   ),
              //
              //   GestureDetector(
              //     onTap: _openSocialLogin,
              //     child: const Text(
              //       "바로 시작하기",
              //       style: TextStyle(
              //         fontSize: 13,
              //         color: Color(0xff0084FF),
              //         fontWeight: FontWeight.w600,
              //       ),
              //     ),
              //   ),
              // ],
            ),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

class _OnboardingItem {
  final String title;
  final String image;

  const _OnboardingItem({required this.title, required this.image});
}