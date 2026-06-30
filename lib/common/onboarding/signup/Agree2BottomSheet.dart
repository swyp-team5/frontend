import 'package:flutter/material.dart';

class Agree2BottomSheet extends StatelessWidget {
  const Agree2BottomSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        height: MediaQuery.of(context).size.height * 0.72,
        padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(28),
          ),
        ),
        child: Column(
          children: [
            //----------------------------------
            // 상단 바
            //----------------------------------
            Container(
              width: 56,
              height: 6,
              decoration: BoxDecoration(
                color: const Color(0xffD9D9D9),
                borderRadius: BorderRadius.circular(100),
              ),
            ),

            const SizedBox(height: 20),

            //----------------------------------
            // 제목
            //----------------------------------

            Row(
              children: [
                const Spacer(),

                const Text(
                  "[필수] 개인정보 수집 및 이용 동의",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),

                const Spacer(),

                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: const CircleAvatar(
                    radius: 16,
                    backgroundColor: Color(0xffF1F1F5),
                    child: Icon(
                      Icons.close,
                      size: 18,
                      color: Color(0xff9A9A9A),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 18),

            const Divider(height: 1),

            //----------------------------------
            // 내용
            //----------------------------------

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.only(top: 24),
                child: Column(
                  children: [
                    const Text(
                      "개인정보 보호법에 따라 착착에 가입하는 이용자로부터\n"
                          "다음과 같이 개인정보를 수집 및 이용합니다",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 15,
                        color: Color(0xff767676),
                        height: 1.5,
                        fontWeight: FontWeight.w500,
                      ),
                    ),

                    const SizedBox(height: 24),

                    //----------------------------------
                    // 표
                    //----------------------------------

                    Container(
                      decoration: BoxDecoration(
                        color: const Color(0xffF1F1F5),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 18,
                      ),
                      child: Column(
                        children: [
                          const Row(
                            children: [
                              Expanded(
                                child: Center(
                                  child: Text(
                                    "유형",
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: Color(0xff9A9A9A),
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ),
                              Expanded(
                                child: Center(
                                  child: Text(
                                    "처리 목적",
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: Color(0xff9A9A9A),
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ),
                              Expanded(
                                child: Center(
                                  child: Text(
                                    "보유 기간",
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: Color(0xff9A9A9A),
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 10),

                          const Divider(height: 1),

                          tableRow("이름", "회원 식별", "탈퇴 후 30일"),
                          tableRow("이메일", "로그인", "탈퇴 후 30일"),
                          tableRow("휴대폰 번호", "본인 확인", "탈퇴 후 30일"),
                          tableRow("매장 정보", "스케줄 관리", "탈퇴 후 30일"),
                          tableRow("근무자 정보", "근무자 관리", "탈퇴 후 30일"),
                        ],
                      ),
                    ),

                    const SizedBox(height: 28),

                    const Text(
                      "위 개인정보 수집 및 이용에 동의하지 않을 권리가 있으며,\n"
                          "동의하지 않을 경우 서비스 이용이 제한될 수 있습니다",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 15,
                        color: Color(0xff767676),
                        height: 1.5,
                        fontWeight: FontWeight.w500,
                      ),
                    ),

                    const SizedBox(height: 28),
                  ],
                ),
              ),
            ),

            //----------------------------------
            // 확인 버튼
            //----------------------------------

            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  elevation: 0,
                  backgroundColor: const Color(0xff0084FF),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  "확인",
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  static Widget tableRow(
      String type,
      String purpose,
      String period,
      ) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Row(
            children: [
              Expanded(
                child: Center(
                  child: Text(
                    type,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              Expanded(
                child: Center(
                  child: Text(
                    purpose,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              Expanded(
                child: Center(
                  child: Text(
                    period,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        const Divider(height: 1),
      ],
    );
  }
}