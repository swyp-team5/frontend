import 'package:flutter/material.dart';

import '../models/ScheduleScenario.dart';
import 'RCalendarRow.dart';

class RWeekCalendar extends StatelessWidget {
  final List<ScheduleScenario> scenarios;
  final int selectedIndex;
  final ValueChanged<int> onSelect;

  const RWeekCalendar({
    super.key,
    required this.scenarios,
    required this.selectedIndex,
    required this.onSelect,
  });



  @override
  Widget build(BuildContext context) {

    final now = DateTime.now();

    // 다음주 월요일
    final nextMonday = DateTime(
      now.year, now.month, now.day,).add(Duration(days: 8 - now.weekday));

    final weekDays = List.generate(7,
          (index) => nextMonday.add(Duration(days: index)),
    );

    const weekText = ["월", "화", "수", "목", "금", "토", "일",];

    return ListView.separated(
      padding: EdgeInsets.zero,
      itemCount: scenarios.length,
      separatorBuilder: (_, __) => Container(
        height: 25,
        color: const Color(0xFFF1F1F5),
      ),
      itemBuilder: (_, index) {
        return GestureDetector(
          onTap: () => onSelect(index),
          child: RCalendarRow(
            scenario: scenarios[index],
          ),
        );
      },
    );
  }
}