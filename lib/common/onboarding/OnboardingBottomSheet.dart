import 'package:chack_chack/common/onboarding/signup/CommonSignUpPage.dart';
import 'package:flutter/material.dart';

class OnboardingBottomSheet extends StatelessWidget {
  const OnboardingBottomSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(28),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              //----------------------------------
              // Drag Handle
              //----------------------------------

              Container(
                width: 56,
                height: 6,
                decoration: BoxDecoration(
                  color: const Color(0xffE5E5E5),
                  borderRadius: BorderRadius.circular(100),
                ),
              ),

              const SizedBox(height: 28),

              //----------------------------------
              // Title
              //----------------------------------

              const Text(
                "스케줄 관리를 더 쉽고 간편하게",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
              ),

              const SizedBox(height: 20),

              const Divider(
                height: 1,
                color: Color(0xffECECEC),
              ),

              const SizedBox(height: 20),

              //----------------------------------
              // Kakao
              //----------------------------------

              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton.icon(
                  onPressed: () {
                    // TODO : 카카오 로그인
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xffFFEB3B),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  icon: Image.asset(
                    "assets/images/logo/kakaotalk.png",
                    width: 40,
                    height: 40,
                  ),
                  label: const Text(
                    "카카오로 시작하기",
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 14),

              //----------------------------------
              // Google
              //----------------------------------

              SizedBox(
                width: double.infinity,
                height: 56,
                child: OutlinedButton(
                  onPressed: () {
                    // TODO : Google 로그인
                  },
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(
                      color: Color(0xffE5E5E5),
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset(
                        "assets/images/logo/google.png",
                        width: 22,
                        height: 22,
                      ),
                      const SizedBox(width: 12),
                      const Text(
                        "Google로 시작하기",
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  )
                ),
              ),

              const SizedBox(height: 14),

              //----------------------------------
              // Apple
              //----------------------------------

              SizedBox(
                width: double.infinity,
                height: 56,
                child: OutlinedButton(
                  onPressed: () {
                    // TODO : Apple 로그인
                  },
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(
                      color: Color(0xffE5E5E5),
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset(
                        "assets/images/logo/apple.png",
                        width: 22,
                        height: 22,
                      ),
                      const SizedBox(width: 12),
                      const Text(
                        "Apple로 시작하기",
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  )
                ),
              ),

              const SizedBox(height: 32),

              //----------------------------------
              // 로그인
              //----------------------------------

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    "이미 계정이 있거나 초대받았다면 ",
                    style: TextStyle(
                      color: Color(0xff505050),
                      fontSize: 13,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const CommonSignUpPage(),
                        ),
                      );
                    },
                    child: const Text(
                      "바로 시작하기",
                      style: TextStyle(
                        color: Color(0xff0084FF),
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}