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
      builder: (_) => const OnboardingBottomSheet(),
    );
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
                        // 제목
                        //----------------------------------
                        Text(
                          item.title,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w700,
                            height: 1.35,
                          ),
                        ),

                        const SizedBox(height: 40),

                        //----------------------------------
                        // 휴대폰 이미지
                        //----------------------------------
                        Expanded(
                          child: Align(
                            alignment: Alignment.bottomCenter,
                            child: ConstrainedBox(
                              constraints: const BoxConstraints(
                                maxWidth: 260,
                                maxHeight: 250,
                              ),
                              child: Image.asset(
                                item.image,
                                fit: BoxFit.contain,
                              ),
                            ),
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
              children: [
                const Text(
                  "이미 계정이 있거나 초대받았다면 ",
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w400,
                    color: Color(0xff767676),
                  ),
                ),

                GestureDetector(
                  onTap: _openSocialLogin,
                  child: const Text(
                    "바로 시작하기",
                    style: TextStyle(
                      fontSize: 13,
                      color: Color(0xff0084FF),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
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
