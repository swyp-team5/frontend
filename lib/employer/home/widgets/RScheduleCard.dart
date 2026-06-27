import 'package:flutter/material.dart';

class RScheduleCard extends StatelessWidget {
  final VoidCallback? onMakeScheduleTap;

  const RScheduleCard({
    super.key,
    this.onMakeScheduleTap,
  });

  /// 다음 주 기간
  String get nextWeekRange {
    final now = DateTime.now();

    // 이번 주 월요일
    final thisMonday = now.subtract(
      Duration(days: now.weekday - DateTime.monday),
    );

    // 다음 주 월요일
    final nextMonday = thisMonday.add(const Duration(days: 7));

    // 다음 주 일요일
    final nextSunday = nextMonday.add(const Duration(days: 6));

    return "${nextMonday.month}월 ${nextMonday.day}일 - "
        "${nextSunday.month}월 ${nextSunday.day}일";
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: AspectRatio(
        aspectRatio: 1080 / 693,
        child: Stack(
          children: [
            /// 배경 이미지
            Positioned.fill(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Image.asset(
                  "assets/images/r_main_card.png",
                  fit: BoxFit.cover,
                ),
              ),
            ),

            /// 다음주 날짜
            Positioned(
              left: 20,
              top: 90,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFBFE1FF),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  nextWeekRange,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF0084FF),
                  ),
                ),
              ),
            ),

            /// 스케줄 만들기 버튼
            Positioned(
              left: 24,
              right: 24,
              bottom: 16,
              child: SizedBox(
                height: 52,
                child: ElevatedButton(
                  onPressed: onMakeScheduleTap,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0084FF),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: const Text(
                    "스케줄 만들기",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}