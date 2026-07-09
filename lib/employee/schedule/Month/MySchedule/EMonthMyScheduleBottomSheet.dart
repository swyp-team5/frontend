import 'package:flutter/material.dart';

class EMonthMyScheduleBottomSheet extends StatelessWidget {
  final DateTime date;

  /// 개인 스케줄
  /// 비어있으면 근무 없음
  final List<MySchedule> schedules;

  const EMonthMyScheduleBottomSheet({
    super.key,
    required this.date,
    required this.schedules,
  });

  String get weekDay {
    const days = ["월", "화", "수", "목", "금", "토", "일",];

    return days[date.weekday - 1];
  }

  String get weekOfMonth {
    final firstDay = DateTime(
      date.year,
      date.month,
      1,
    );

    final weekNumber =
        ((date.day + firstDay.weekday - 2) ~/ 7) + 1;

    const weekTexts = ["", "첫째", "둘째", "셋째", "넷째", "다섯째", "여섯째",];

    return weekTexts[weekNumber];
  }

  @override
  Widget build(BuildContext context) {

    return Container(
      height: 250,
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
              borderRadius: BorderRadius.circular(999,),
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
                  onTap: () {
                    Navigator.pop(context);
                  },
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
                "${date.year}년 ${date.month}월 $weekOfMonth주 $weekDay요일",
                style: const TextStyle(
                  fontSize: 14,
                  color: Color(0xFF505050),
                ),
              ),
            ),
          ),

          Expanded(
            child: schedules.isEmpty
                ? const Center(
              child: Text(
                "등록된 근무가 없어요",
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF999999),
                ),
              ),
            )
                : ListView.separated(
              padding:
              const EdgeInsets.all(20),
              itemCount: schedules.length,
              separatorBuilder:
                  (_, __) => const SizedBox(height: 16,),
              itemBuilder: (_, index) {
                final item = schedules[index];

                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 5, height: 54,
                      decoration: BoxDecoration(
                        color: const Color(0xFFE6F3FF,),
                        borderRadius: BorderRadius.circular(999,),
                      ),
                    ),

                    const SizedBox(width: 14,),

                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(item.name,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,),
                          ),

                          const SizedBox(height: 4,),

                          Text("${item.startTime} - ${item.closeTime}",
                            style: const TextStyle(
                              fontSize: 13,
                              color: Color(0xFF505050,),
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
}

class MySchedule {
  final String name;
  final String startTime;
  final String closeTime;
  final String timeName;

  const MySchedule({
    required this.name,
    required this.startTime,
    required this.closeTime,
    required this.timeName,
  });
}