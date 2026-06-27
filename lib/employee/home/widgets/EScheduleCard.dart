import 'package:chack_chack/employee/home/schedule/ESubmitSchedulePage.dart';
import 'package:flutter/material.dart';

class EScheduleCard extends StatelessWidget {
  final int daysLeft;

  const EScheduleCard({
    super.key,
    required this.daysLeft,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: AspectRatio(
        aspectRatio: 1059 / 414,
        child: Stack(
          children: [
            /// 배경 이미지
            Positioned.fill(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Image.asset(
                  "assets/images/e_main_card.png",
                  fit: BoxFit.cover,
                ),
              ),
            ),

            /// 하단 영역
            Positioned(
              left: 20,
              bottom: 18,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  /// D-Day 칩
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFBFE1FF),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      "마감까지 ${daysLeft}일",
                      style: const TextStyle(
                        color: Color(0xFF0084FF),
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),

                  const SizedBox(height: 18),

                  /// 자세히 보기
                  Padding(
                    padding: const EdgeInsets.only(left: 5),
                    child: InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                            const ESubmitSchedulePage(),
                          ),
                        );
                      },
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            "자세히 보기",
                            style: TextStyle(
                              color: Color(0xFF004A8F),
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          SizedBox(width: 2),
                          Icon(
                            Icons.chevron_right,
                            size: 18,
                            color: Color(0xFF004A8F),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}