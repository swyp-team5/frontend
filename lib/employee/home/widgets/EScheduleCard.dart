import 'package:chack_chack/employee/home/EHomePage.dart';
import 'package:chack_chack/employee/home/schedule/ESubmitSchedulePage.dart';
import 'package:flutter/material.dart';

class EScheduleCard extends StatelessWidget {
  final int daysLeft;
  final HomeCardType type;
  final VoidCallback? onClose;

  const EScheduleCard({
    super.key,
    required this.daysLeft,
    required this.type,
    this.onClose,
  });

  String get _imagePath {
    switch (type) {
      case HomeCardType.weeklySchedule:
        return "assets/images/e_weeklySchedule_card.png";

      case HomeCardType.scheduleCompleted:
        return "assets/images/e_scheduleCompleted_card.png";

      case HomeCardType.scheduleChanged:
        return "assets/images/e_scheduleChanged_card.png";

      case HomeCardType.shiftRequest:
        return "assets/images/e_shiftRequest_card.png"; // 교대

      case HomeCardType.substituteRequest:
        return "assets/images/e_substituteRequest_card.png"; // 대타

      case HomeCardType.ownerWorkRequest:
        return "assets/images/e_ownerWorkRequest_card.png";

      case HomeCardType.none:
        return "";
    }
  }

  String get nextWeekRange {
    final now = DateTime.now();

    DateTime nextMonday;

    if (now.weekday == DateTime.monday) {
      // 월요일이면 이번주가 이미 제출 대상이므로
      // 다음다음주를 표시
      nextMonday = now.add(const Duration(days: 14));
    } else {
      // 화~일은 가장 가까운 다음 월요일
      nextMonday = now.add(
        Duration(days: 8 - now.weekday),
      );
    }

    final nextSunday = nextMonday.add(const Duration(days: 6));

    return "${nextMonday.month}.${nextMonday.day} - ${nextSunday.month}.${nextSunday.day}";
  }

  /// 교대 요청 더미 데이터
  DateTime get myScheduleDate => DateTime(2026, 6, 25);
  DateTime get otherScheduleDate => DateTime(2026, 6, 27);
  // api 연결 시 교체
  // final DateTime myScheduleDate;
  // final DateTime otherScheduleDate;

  String get shiftDateText =>
      "${myScheduleDate.month}월 ${myScheduleDate.day}일 ↔ "
          "${otherScheduleDate.month}월 ${otherScheduleDate.day}일";

  /// 대타 요청 더미 데이터
  DateTime get substituteDate => DateTime(2026, 6, 27);

  String get substituteTime => "16:00 - 20:00";

  String get substituteDateTimeText =>
      "${substituteDate.month}월 ${substituteDate.day}일 $substituteTime";


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
                  _imagePath,
                  fit: BoxFit.cover,
                ),
              ),
            ),

            /// Todo - 매주 스케줄(다음주 스케 제출 요청)
            if (type == HomeCardType.weeklySchedule)
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

                    Padding(
                      padding: const EdgeInsets.only(left: 5),
                      child: InkWell(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const ESubmitSchedulePage(),
                            ),
                          );
                        },
                        child: const Row(
                          children: [
                            Text(
                              "자세히 보기",
                              style: TextStyle(
                                color: Color(0xFF004A8F),
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
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
            Positioned(
              top: 16,
              right: 16,
              child: GestureDetector(
                onTap: onClose,
                child: Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.25),
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

            /// Todo - 스케줄 완성
            if (type == HomeCardType.scheduleCompleted)
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
                        color: const Color(0xFFD3F0D5),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        nextWeekRange,
                        style: const TextStyle(
                          color: Color(0xFF00B475),
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),

                    const SizedBox(height: 18),

                    Padding(
                      padding: const EdgeInsets.only(left: 5),
                      child: InkWell(
                        onTap: () {
                          // Navigator.push(
                          //   context,
                          //   MaterialPageRoute(
                          //     builder: (_) => const ESubmitSchedulePage(),
                          //   ),
                          // );
                        },
                        child: const Row(
                          children: [
                            Text(
                              "자세히 보기",
                              style: TextStyle(
                                color: Color(0xFF007360),
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            SizedBox(width: 2),
                            Icon(
                              Icons.chevron_right,
                              size: 18,
                              color: Color(0xFF007360),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

            /// Todo - 스케줄 변경
            if (type == HomeCardType.scheduleChanged)
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
                        color: const Color(0xFFD3F0D5),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        nextWeekRange,
                        style: const TextStyle(
                          color: Color(0xFF00B475),
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),

                    const SizedBox(height: 18),

                    Padding(
                      padding: const EdgeInsets.only(left: 5),
                      child: InkWell(
                        onTap: () {
                          // Navigator.push(
                          //   context,
                          //   MaterialPageRoute(
                          //     builder: (_) => const ESubmitSchedulePage(),
                          //   ),
                          // );
                        },
                        child: const Row(
                          children: [
                            Text(
                              "자세히 보기",
                              style: TextStyle(
                                color: Color(0xFF007360),
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            SizedBox(width: 2),
                            Icon(
                              Icons.chevron_right,
                              size: 18,
                              color: Color(0xFF007360),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

            /// Todo - 교대근무 요청
            if (type == HomeCardType.shiftRequest)
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
                        color: const Color(0xFFDDD7FE),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        shiftDateText,
                        style: const TextStyle(
                          color: Color(0xFF7D67FD),
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),

                    const SizedBox(height: 18),

                    Padding(
                      padding: const EdgeInsets.only(left: 5),
                      child: InkWell(
                        onTap: () {
                          // Navigator.push(
                          //   context,
                          //   MaterialPageRoute(
                          //     builder: (_) => const ESubmitSchedulePage(),
                          //   ),
                          // );
                        },
                        child: const Row(
                          children: [
                            Text(
                              "자세히 보기",
                              style: TextStyle(
                                color: Color(0xFF6450D4),
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            SizedBox(width: 2),
                            Icon(
                              Icons.chevron_right,
                              size: 18,
                              color: Color(0xFF6450D4),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

            /// Todo - 대타근무 요청
            if (type == HomeCardType.substituteRequest)
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
                        color: const Color(0xFFDDD7FE),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        substituteDateTimeText,
                        style: const TextStyle(
                          color: Color(0xFF7D67FD),
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),

                    const SizedBox(height: 18),

                    Padding(
                      padding: const EdgeInsets.only(left: 5),
                      child: InkWell(
                        onTap: () {
                          // Navigator.push(
                          //   context,
                          //   MaterialPageRoute(
                          //     builder: (_) => const ESubmitSchedulePage(),
                          //   ),
                          // );
                        },
                        child: const Row(
                          children: [
                            Text(
                              "자세히 보기",
                              style: TextStyle(
                                color: Color(0xFF6450D4),
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            SizedBox(width: 2),
                            Icon(
                              Icons.chevron_right,
                              size: 18,
                              color: Color(0xFF6450D4),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

            /// Todo - 사장님 근무 요청
            if (type == HomeCardType.ownerWorkRequest)
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
                        color: const Color(0xFFBFE1FF),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        nextWeekRange,
                        style: const TextStyle(
                          color: Color(0xFF0084FF),
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),

                    const SizedBox(height: 18),

                    Padding(
                      padding: const EdgeInsets.only(left: 5),
                      child: InkWell(
                        onTap: () {
                          // Navigator.push(
                          //   context,
                          //   MaterialPageRoute(
                          //     builder: (_) => const ESubmitSchedulePage(),
                          //   ),
                          // );
                        },
                        child: const Row(
                          children: [
                            Text(
                              "자세히 보기",
                              style: TextStyle(
                                color: Color(0xFF004A8F),
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
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