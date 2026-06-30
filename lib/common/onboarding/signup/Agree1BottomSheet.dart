import 'package:flutter/material.dart';

class Agree1BottomSheet extends StatelessWidget {
  const Agree1BottomSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        height: MediaQuery.of(context).size.height * 0.78,
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
                  "[필수] 서비스 이용약관 동의",
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
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    sectionTitle("제 1조 (목적)"),
                    sectionBody(
                      "본 약관은 착착 서비스의 이용과 관련하여 회사와 이용자의 권리, 의무 및 책임사항을 규정함을 목적으로 합니다.",
                    ),

                    const SizedBox(height: 28),

                    sectionTitle("제 2조 (서비스 내용)"),

                    const SizedBox(height: 14),

                    greyBox(
                      "착착은 다음 서비스를 제공합니다",
                      [
                        "근무자 관리",
                        "자동 스케줄 생성",
                        "근태 관리",
                        "근무 교대 및 대타 신청",
                        "공지사항 관리",
                        "알림 서비스",
                      ],
                    ),

                    const SizedBox(height: 28),

                    sectionTitle("제 3조 (회원의 의무)"),

                    const SizedBox(height: 14),

                    greyBox(
                      "회원은 다음 행위를 해서는 안됩니다",
                      [
                        "타인의 계정 도용",
                        "허위 정보 등록",
                        "서비스 운영 방해",
                        "불법적인 목적의 이용",
                      ],
                    ),

                    const SizedBox(height: 28),

                    sectionTitle("제 4조 (서비스 변경)"),

                    sectionBody(
                      "회사는 서비스 운영상 필요한 경우\n서비스의 일부 또는 전부를 변경할 수 있습니다.",
                    ),

                    const SizedBox(height: 28),

                    sectionTitle("제 5조 (회원 탈퇴)"),

                    sectionBody(
                      "회원은 언제든지 회원 탈퇴를 요청할 수 있으며,\n회사는 관련 법령에 따라 개인정보를 처리합니다.",
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
                onPressed: () {
                  Navigator.pop(context);
                },
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

  Widget sectionTitle(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
      ),
    );
  }

  Widget sectionBody(String text) {
    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: Color(0xFF767676),
          height: 1.5,
        ),
      ),
    );
  }

  Widget greyBox(String description, List<String> items) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 20,
        vertical: 18,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F1F5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            description,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: Color(0xFF767676),
            ),
          ),

          const SizedBox(height: 20),

          ...List.generate(items.length, (index) {
            return Column(
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    items[index],
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                if (index != items.length - 1)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 16),
                    child: Divider(height: 1),
                  ),
              ],
            );
          }),
        ],
      ),
    );
  }
}