import 'package:chack_chack/employer/signup/RSignUp1.dart';
import 'package:flutter/material.dart';

class RSignUpPage extends StatelessWidget {

  const RSignUpPage({super.key});

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),

      body: SafeArea(
        child: Stack(
          children: [

            /// 뒤로가기 버튼
            Positioned(
              top: 16,
              left: 16,

              child: IconButton(
                onPressed: () {
                  Navigator.pop(context);
                },

                icon: const Icon(
                  Icons.arrow_back_ios_new,
                  size: 28,
                ),
              ),
            ),

            /// 중앙 내용
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                ),

                child: Column(
                  mainAxisSize: MainAxisSize.min,

                  children: [

                    const Text(
                      '반가워요. 사장님.',

                      textAlign: TextAlign.center,

                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),

                    const SizedBox(height: 12),

                    const Text(
                      '착착 사용을 위해\n매장을 만들어주세요',

                      textAlign: TextAlign.center,

                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        height: 1.4,
                      ),
                    ),

                    const SizedBox(height: 40),

                    SizedBox(
                      width: 210,
                      height: 60,

                      child: ElevatedButton(
                        onPressed: () {

                          /// 매장 생성 페이지 이동
                          Navigator.push(
                            context,

                            MaterialPageRoute(
                              builder: (_) =>
                              const RSignUp1(),
                            ),
                          );
                        },

                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                          Colors.grey.shade400,

                          elevation: 0,

                          shape: RoundedRectangleBorder(
                            borderRadius:
                            BorderRadius.circular(14),
                          ),
                        ),

                        child: const Text(
                          '매장만들기',

                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
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