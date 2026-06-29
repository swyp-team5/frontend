import 'package:flutter/material.dart';

import 'EMonthAllSchedulePage.dart';

class EMonthAllScheduleBottomSheet extends StatelessWidget {
  final DateTime date;
  final List<ScheduleShift> workers;

  const EMonthAllScheduleBottomSheet({
    super.key,
    required this.date,
    required this.workers,
  });

  String get weekDay {
    const days = ["월", "화", "수", "목", "금", "토", "일",];

    return days[date.weekday - 1];
  }

  String get WeekOfMonth {
    final firstDay = DateTime(date.year, date.month, 1);

    // 해당 월의 첫 주에 포함된 날짜 수 고려
    final weekNumber =
        ((date.day + firstDay.weekday - 2) ~/ 7) + 1;

    const weekTexts = ["", "첫째", "둘째", "셋째", "넷째", "다섯째", "여섯째",];

    return weekTexts[weekNumber];
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: workers.isEmpty ? 250 : 450,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(24),
        ),
      ),
      child: Column(
        children: [
          const SizedBox(height: 10),

          Container(
            width: 48, height: 5,
            decoration: BoxDecoration(
              color: const Color(0xFFE0E0E0),
              borderRadius: BorderRadius.circular(999),
            ),
          ),

          const SizedBox(height: 24),

          Stack(
            children: [
              Center(
                child: Text(
                  "${date.month}월 ${date.day}일 $weekDay요일",
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),

              Positioned(
                right: 20,
                child: GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    width: 28,
                    height: 28,
                    decoration: const BoxDecoration(
                      color: Color(0xFFF2F2F7),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.close,
                      size: 18,
                      color: Color(0xFFA5A5AF),
                    ),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(
              vertical: 14,
            ),
            decoration: const BoxDecoration(
              border: Border(
                top: BorderSide(
                  color: Color(0xFFE9E9EE),
                ),
              ),
            ),
            child: Center(
              child: Text(
                "${date.year}년 ${date.month}월 $WeekOfMonth주 $weekDay요일",
                style: const TextStyle(
                  fontSize: 14,
                  color: Color(0xFF505050),
                ),
              ),
            ),
          ),

          Expanded(
            child: workers.isEmpty
                ? const Center(
              child: Text(
                "등록된 근무가 없어요",
                style: TextStyle(
                  fontSize: 16,
                  color: Color(0xFF999999),
                ),
              ),
            )
                : ListView.separated(
              padding: const EdgeInsets.all(20),
              itemCount: workers.length,
              separatorBuilder: (_, __) =>
              const SizedBox(height: 16),
              itemBuilder: (_, index) {
                final shift = workers[index];

                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 5,
                      height: 54,
                      decoration: BoxDecoration(
                        color: _workerColor(shift),
                        borderRadius: BorderRadius.circular(999),
                      ),
                    ),

                    const SizedBox(width: 14),

                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                shift.role,
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w400,
                                  color: Color(0xFF767676),
                                ),
                              ),

                              const SizedBox(width: 8),

                              Text(
                                "${shift.startTime} - ${shift.endTime}",
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: Color(0xFF505050),
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 4),

                          RichText(
                            text: TextSpan(
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: Colors.black,
                              ),
                              children: [
                                TextSpan(
                                  text: shift.workers
                                      .map((e) => e.name)
                                      .join(" · "),
                                ),

                                if (shift.shortage)
                                  TextSpan(
                                    text: " · 근무자 부족 ${shift.shortageCount}명",
                                    style: const TextStyle(
                                      color: Color(0xFF767676),
                                      fontSize: 15,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Color _workerColor(ScheduleShift shift) {
    if (shift.shortage) {
      return const Color(0xFFFF5D5D);
    }

    switch (shift.role) {
      case "오픈":
        return const Color(0xFFBFE1FF);

      case "미들":
        return const Color(0xFFD8D1FE);

      case "마감":
        return const Color(0xFFACFBC1);

      default:
        return const Color(0xFFBDBDBD);
    }
  }
}