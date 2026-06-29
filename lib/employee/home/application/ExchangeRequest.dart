import 'package:flutter/material.dart';

import '../../../common/employee/EExchangeReject.dart';
import 'ExAcceptionBottomSheet.dart';

class ExchangeRequest extends StatelessWidget {
  const ExchangeRequest({super.key});

  @override
  Widget build(BuildContext context) {
    // 더미 데이터
    const applicant = "윤서준";
    const myName = "나";

    const applicantDate = "7월 9일";
    const applicantTime = "13:00 - 18:00";

    const myDate = "7월 8일";
    const myTime = "13:00 - 18:00";

    const reason = "기타 / 동아리 면접";

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            /// 헤더
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 30,
              ),
              child: SizedBox(
                height: 24, // 아이콘 높이 맞추기용
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    /// 왼쪽 뒤로가기
                    Positioned(
                      left: 0,
                      child: GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: const Icon(
                          Icons.arrow_back_ios_new,
                          size: 22,
                        ),
                      ),
                    ),

                    /// 완전 가운데 타이틀
                    const Center(
                      child: Text(
                        "교대 신청 내역",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 30),
                child: Column(
                  children: [
                    const Spacer(),

                    /// 교대 카드
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 30,
                        vertical: 30,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xffF5F5F9),
                        borderRadius: BorderRadius.circular(22),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: _WorkInfo(
                              name: applicant,
                              badgeColor: Colors.white,
                              textColor: const Color(0xff00315F),
                              date: applicantDate,
                              time: applicantTime,
                            ),
                          ),

                          const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 14),
                            child: Icon(
                              Icons.swap_horiz,
                              color: Color(0xff8F8F8F),
                              size: 34,
                            ),
                          ),

                          Expanded(
                            child: _WorkInfo(
                              name: myName,
                              badgeColor: const Color(0xffE6F3FF),
                              textColor: const Color(0xff0063BF),
                              date: myDate,
                              time: myTime,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 30),

                    _InfoRow(title: "교대 신청자", value: applicant),

                    const SizedBox(height: 30),

                    _InfoRow(title: "교대 신청 사유", value: reason),

                    const Spacer(),

                    Row(
                      children: [
                        Expanded(
                          child: SizedBox(
                            height: 55,
                            child: OutlinedButton(
                              style: OutlinedButton.styleFrom(
                                side: BorderSide.none,
                              ),
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => const EExchangeReject(),
                                  ),
                                );
                              },
                              child: const Text(
                                "거절",
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(width: 10),

                        Expanded(
                          flex: 1,
                          child: SizedBox(
                            height: 55,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                elevation: 0,
                                backgroundColor: const Color(0xff0084FF),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              onPressed: () {
                                showModalBottomSheet(
                                  context: context,
                                  backgroundColor: Colors.transparent,
                                  isScrollControlled: true,
                                  builder: (_) => ExAcceptionBottomSheet(
                                    onAccept: () {
                                      Navigator.pop(context);

                                      // TODO: 교대 수락 API 호출
                                    },
                                  ),
                                );
                              },
                              child: const Text(
                                "수락",
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),
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

class _WorkInfo extends StatelessWidget {
  const _WorkInfo({
    required this.name,
    required this.badgeColor,
    required this.textColor,
    required this.date,
    required this.time,
  });

  final String name;
  final Color badgeColor;
  final Color textColor;
  final String date;
  final String time;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 6,
            vertical: 4,
          ),
          decoration: BoxDecoration(
            color: badgeColor,
            borderRadius: BorderRadius.circular(4),
          ),
          child: Text(
            name,
            style: TextStyle(
              color: textColor,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        const SizedBox(height: 12),
        Text(
          date,
          style: const TextStyle(
            fontSize: 16,
            color: Colors.black,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          time,
          style: const TextStyle(
            fontSize: 14,
            color: Color(0xFF505050),
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.title,
    required this.value,
  });

  final String title;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            color: Color(0xff505050),
            fontWeight: FontWeight.w500,
          ),
        ),
        const Spacer(),
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

}