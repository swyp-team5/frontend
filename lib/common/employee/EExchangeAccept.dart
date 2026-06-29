import 'package:chack_chack/employee/home/EHomePage.dart';
import 'package:flutter/material.dart';

class EExchangeAccept extends StatelessWidget {
  const EExchangeAccept({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              const Spacer(),

              /// 완료 이미지
              SizedBox(
                width: 200,
                height: 200,
                child: Image.asset(
                  "assets/images/accept.png",
                  fit: BoxFit.contain,
                ),
              ),

              const Text(
                "교대 신청이\n수락되었어요!",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w600,
                  height: 1.5,
                  color: Color(0xff202020),
                ),
              ),

              const SizedBox(height: 20),

              const Text(
                "사장님께 근무 변경 요청이 전송되어\n최종 수락 시 스케줄이 변동돼요",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  height: 1.5,
                  color: Colors.black,
                ),
              ),

              const Spacer(),

              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const EHomePage(),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xff0084FF),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    "홈으로 가기",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}