import 'package:flutter/material.dart';

import '../Month/RMonthAllSchedulePage.dart';
import 'RWeekGrid.dart';
import 'RWeekUtils.dart';

class RWeekSchedulePage extends StatelessWidget {
  final DateTime selectedDate;
  final ValueChanged<DateTime> onDateChanged;

  /// yyyy-MM-dd -> 근무목록
  final Map<String, List<RScheduleShift>> schedules;

  /// 휴무일
  final Set<String> holidays;

  const RWeekSchedulePage({
    super.key,
    required this.selectedDate,
    required this.onDateChanged,
    required this.schedules,
    required this.holidays,
  });

  @override
  Widget build(BuildContext context) {
    final weekDates = RWeekUtils.getWeekDates(selectedDate);

    return Column(
      children: [
        // ================= 요일 =================
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Row(
            children: List.generate(7, (index) {
              const weeks = ["월", "화", "수", "목", "금", "토", "일"];

              final isHoliday =
              holidays.contains(RWeekUtils.dateKey(weekDates[index]));

              return Expanded(
                child: Center(
                  child: Text(
                    weeks[index],
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: isHoliday
                          ? const Color(0xFFB5B5B5)
                          : Colors.grey,
                    ),
                  ),
                ),
              );
            }),
          ),
        ),

        const SizedBox(height: 4),

        // ================= 날짜 =================
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Row(
            children: List.generate(7, (index) {
              final day = weekDates[index];

              final isSelected =
                  day.year == selectedDate.year &&
                      day.month == selectedDate.month &&
                      day.day == selectedDate.day;

              final isHoliday =
              holidays.contains(RWeekUtils.dateKey(day));

              return Expanded(
                child: GestureDetector(
                  onTap: isHoliday
                      ? null
                      : () => onDateChanged(day),
                  child: Center(
                    child: Container(
                      width: 34,
                      height: 34,
                      decoration: BoxDecoration(
                        color: isSelected
                            ? const Color(0xFF1976FF)
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        "${day.day}",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: isHoliday
                              ? const Color(0xFFB5B5B5)
                              : isSelected
                              ? Colors.white
                              : Colors.black,
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }),
          ),
        ),

        const SizedBox(height: 12),

        // ================= 주차 =================
        Container(
          height: 42,
          color: const Color(0xFFF7F7F7),
          child: Row(
            children: [
              IconButton(
                onPressed: () {
                  onDateChanged(
                    selectedDate.subtract(
                      const Duration(days: 7),
                    ),
                  );
                },
                icon: const Icon(Icons.chevron_left),
              ),
              Expanded(
                child: Center(
                  child: Text(
                    RWeekUtils.getWeekTitle(selectedDate),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              IconButton(
                onPressed: () {
                  onDateChanged(
                    selectedDate.add(
                      const Duration(days: 7),
                    ),
                  );
                },
                icon: const Icon(Icons.chevron_right),
              ),
            ],
          ),
        ),

        // ================= 스케줄 =================
        Expanded(
          child: RWeekGrid(
            weekDates: weekDates,
            schedules: schedules,
            holidays: holidays,
          ),
        ),
      ],
    );
  }
}