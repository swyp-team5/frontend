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
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
      itemCount: scenarios.length,
      separatorBuilder: (_, __) => const SizedBox(height: 20),
      itemBuilder: (context, index) {
        final selected = index == selectedIndex;

        return GestureDetector(
          onTap: () => onSelect(index),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: selected
                    ? const Color(0xFF1687F8)
                    : const Color(0xFFE5E5E5),
                width: selected ? 2.5 : 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.03),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Stack(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: RCalendarRow(
                    scenario: scenarios[index],
                  ),
                ),

                if (selected)
                  Positioned(
                    top: 16,
                    right: 16,
                    child: Container(
                      width: 28,
                      height: 28,
                      decoration: const BoxDecoration(
                        color: Color(0xFF1687F8),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.check,
                        size: 18,
                        color: Colors.white,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}