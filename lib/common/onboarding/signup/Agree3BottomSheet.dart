import 'package:flutter/material.dart';

class Agree3BottomSheet extends StatelessWidget {
  const Agree3BottomSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        height: MediaQuery.of(context).size.height * 0.64,
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
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
                  "[선택] 마케팅 정보 수신 동의",
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
                      "착착은 서비스 관련 정보를 이용자에게 전송합니다",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 15,
                        color: Color(0xff767676),
                        fontWeight: FontWeight.w500,
                        height: 1,
                      ),
                    ),

                    const SizedBox(height: 24),

                    infoBox(
                      title: "수신 방법",
                      content: "앱 푸시",
                    ),

                    const SizedBox(height: 24),

                    const Text(
                      "선택 동의이며, 동의하지 않아도 서비스 이용은 가능합니다\n"
                          "단, 동의를 거부할 경우, 착착 서비스 관련 정보를\n받으실 수 없습니다",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        color: Color(0xff767676),
                        fontWeight: FontWeight.w500,
                        height: 1.5,
                      ),
                    ),

                    const SizedBox(height: 24),

                    infoBox(
                      title: "수신 동의 철회 방법",
                      content: "앱 : ‘마이페이지’ > ‘계정 설정’ > ‘푸시 알림’",
                    ),
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

  Widget infoBox({
    required String title,
    required String content,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: 20,
        vertical: 18,
      ),
      decoration: BoxDecoration(
        color: const Color(0xffF1F1F5),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xff9A9A9A),
              fontWeight: FontWeight.w500,
            ),
          ),

          const SizedBox(height: 20),

          Text(
            content,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.black,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}