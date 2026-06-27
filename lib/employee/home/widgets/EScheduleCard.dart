import 'package:flutter/material.dart';
import '../EHomePage.dart';

class EScheduleCard extends StatelessWidget {
  final HomeCardType type;
  final int daysLeft;
  final VoidCallback? onClose;
  final VoidCallback? onDetailTap;

  const EScheduleCard({
    super.key,
    required this.type,
    required this.daysLeft,
    this.onClose,
    this.onDetailTap,
  });

  //-----------------------------------------
  // 이미지
  //-----------------------------------------

  String get imagePath {
    switch (type) {
      case HomeCardType.weeklySchedule:
        return "assets/images/e_weeklySchedule_card.png";

      case HomeCardType.scheduleCompleted:
        return "assets/images/e_scheduleCompleted_card.png";

      case HomeCardType.scheduleChanged:
        return "assets/images/e_scheduleChanged_card.png";

      case HomeCardType.shiftRequest:
        return "assets/images/e_shiftRequest_card.png";

      case HomeCardType.substituteRequest:
        return "assets/images/e_substituteRequest_card.png";

      case HomeCardType.ownerWorkRequest:
        return "assets/images/e_ownerWorkRequest_card.png";

      case HomeCardType.none:
        return "";
    }
  }

  //-----------------------------------------
  // 다음주 기간
  //-----------------------------------------

  String get nextWeekRange {
    final now = DateTime.now();

    DateTime nextMonday;

    if (now.weekday == DateTime.monday) {
      nextMonday = now.add(const Duration(days: 14));
    } else {
      nextMonday = now.add(
        Duration(days: 8 - now.weekday),
      );
    }

    final nextSunday = nextMonday.add(
      const Duration(days: 6),
    );

    return "${nextMonday.month}월 ${nextMonday.day}일 - "
        "${nextSunday.month}월 ${nextSunday.day}일";
  }

  //-----------------------------------------
  // 더미 데이터
  //-----------------------------------------

  DateTime get myScheduleDate => DateTime(2026, 6, 25);

  DateTime get otherScheduleDate => DateTime(2026, 6, 27);

  String get shiftDateText =>
      "${myScheduleDate.month}월 ${myScheduleDate.day}일 ↔ "
          "${otherScheduleDate.month}월 ${otherScheduleDate.day}일";

  DateTime get substituteDate => DateTime(2026, 6, 27);

  String get substituteTime => "16:00 - 20:00";

  String get substituteDateTime =>
      "${substituteDate.month}월 ${substituteDate.day}일 $substituteTime";

  //-----------------------------------------
  // Chip 글자
  //-----------------------------------------

  String get chipText {
    switch (type) {
      case HomeCardType.weeklySchedule:
        return "마감까지 ${daysLeft}일";

      case HomeCardType.scheduleCompleted:
      case HomeCardType.scheduleChanged:
      case HomeCardType.ownerWorkRequest:
        return nextWeekRange;

      case HomeCardType.shiftRequest:
        return shiftDateText;

      case HomeCardType.substituteRequest:
        return substituteDateTime;

      case HomeCardType.none:
        return "";
    }
  }

  //-----------------------------------------
  // Chip 배경
  //-----------------------------------------

  Color get chipBackground {
    switch (type) {
      case HomeCardType.weeklySchedule:
      case HomeCardType.ownerWorkRequest:
        return const Color(0xFFBFE1FF);

      case HomeCardType.scheduleCompleted:
      case HomeCardType.scheduleChanged:
        return const Color(0xFFD3F0D5);

      case HomeCardType.shiftRequest:
      case HomeCardType.substituteRequest:
        return const Color(0xFFDDD7FE);

      case HomeCardType.none:
        return Colors.transparent;
    }
  }

  //-----------------------------------------
  // Chip 글자색
  //-----------------------------------------

  Color get chipTextColor {
    switch (type) {
      case HomeCardType.weeklySchedule:
      case HomeCardType.ownerWorkRequest:
        return const Color(0xFF0084FF);

      case HomeCardType.scheduleCompleted:
      case HomeCardType.scheduleChanged:
        return const Color(0xFF00B475);

      case HomeCardType.shiftRequest:
      case HomeCardType.substituteRequest:
        return const Color(0xFF7D67FD);

      case HomeCardType.none:
        return Colors.transparent;
    }
  }

  //-----------------------------------------
  // 자세히보기 색
  //-----------------------------------------

  Color get detailColor {
    switch (type) {
      case HomeCardType.weeklySchedule:
      case HomeCardType.ownerWorkRequest:
        return const Color(0xFF004A8F);

      case HomeCardType.scheduleCompleted:
      case HomeCardType.scheduleChanged:
        return const Color(0xFF007360);

      case HomeCardType.shiftRequest:
      case HomeCardType.substituteRequest:
        return const Color(0xFF6450D4);

      case HomeCardType.none:
        return Colors.transparent;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (type == HomeCardType.none) {
      return const SizedBox.shrink();
    }

    return SizedBox(
      width: double.infinity,
      child: AspectRatio(
        aspectRatio: 1059 / 414,
        child: Stack(
          children: [
            Positioned.fill(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Image.asset(
                  imagePath,
                  fit: BoxFit.cover,
                ),
              ),
            ),

            /// 닫기 버튼
            Positioned(
              top: 16,
              right: 16,
              child: GestureDetector(
                onTap: onClose,
                child: Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(.25),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.close,
                    size: 18,
                    color: Colors.grey,
                  ),
                ),
              ),
            ),

            /// 하단 UI
            Positioned(
              left: 20,
              bottom: 18,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: chipBackground,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      chipText,
                      style: TextStyle(
                        color: chipTextColor,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),

                  const SizedBox(height: 18),

                  Padding(
                    padding: const EdgeInsets.only(left: 5),
                    child: InkWell(
                      onTap: onDetailTap,
                      child: Row(
                        children: [
                          Text(
                            "자세히 보기",
                            style: TextStyle(
                              color: detailColor,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(width: 2),
                          Icon(
                            Icons.chevron_right,
                            size: 18,
                            color: detailColor,
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