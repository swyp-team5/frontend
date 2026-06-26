import 'package:flutter/material.dart';

import '../Month/AllSchedule/EMonthAllSchedulePage.dart';
import '../Month/MySchedule/EMonthMyScheduleBottomSheet.dart';
import 'EWeekGrid.dart';

class EWeekSchedulePage extends StatelessWidget {
  final DateTime selectedDate;
  final ValueChanged<DateTime> onDateChanged;

  /// 개인 스케줄
  final Map<String, List<MySchedule>> monthSchedules;

  /// 전체 스케줄
  final Map<String, List<ScheduleWorker>> allSchedules;

  /// 휴무일
  final Set<String> holidays;

  /// 상단 토글
  final bool isAllView;

  const EWeekSchedulePage({
    super.key,
    required this.selectedDate,
    required this.onDateChanged,
    required this.monthSchedules,
    required this.allSchedules,
    required this.holidays,
    required this.isAllView,
  });

  DateTime getMonday(DateTime date) {
    return date.subtract(Duration(days: date.weekday - 1));
  }

  List<DateTime> getWeekDates(DateTime date) {
    final monday = getMonday(date);

    return List.generate(
      7,
          (i) => monday.add(Duration(days: i)),
    );
  }

  int getWeekOfMonth(DateTime date) {
    final firstDay = DateTime(date.year, date.month, 1);

    final firstWeek =
    firstDay.subtract(Duration(days: firstDay.weekday - 1));

    return (date.difference(firstWeek).inDays ~/ 7) + 1;
  }

  String getWeekTitle(DateTime date) {
    return "${date.year}년 ${date.month}월 ${getWeekOfMonth(date)}주차";
  }

  String _dateKey(DateTime date) {
    return "${date.year.toString().padLeft(4, "0")}-"
        "${date.month.toString().padLeft(2, "0")}-"
        "${date.day.toString().padLeft(2, "0")}";
  }

  @override
  Widget build(BuildContext context) {
    final weekDates = getWeekDates(selectedDate);

    return Column(
      children: [

        /// 요일
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Row(
            children: List.generate(
              7,
                  (index) {
                    const weeks = ["월","화","수","목","금","토","일"];

                    final isHoliday =
                    holidays.contains(_dateKey(weekDates[index]));

                    return Expanded(
                      child: Center(
                        child: Text(
                          weeks[index],
                          style: TextStyle(
                            color: isHoliday
                                ? Colors.grey.shade400
                                : Colors.grey,
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    );
              },
            ),
          ),
        ),

        const SizedBox(height: 4),

        /// 날짜
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Row(
            children: List.generate(
              7,
                  (index) {
                final day = weekDates[index];

                final selected =
                    day.year == selectedDate.year &&
                        day.month == selectedDate.month &&
                        day.day == selectedDate.day;

                final isHoliday = holidays.contains(_dateKey(day));

                return Expanded(
                  child: GestureDetector(
                    onTap: () => onDateChanged(day),
                    child: Center(
                      child: Container(
                        width: 34,
                        height: 34,
                        decoration: BoxDecoration(
                          color: selected
                              ? const Color(0xff1976FF)
                              : Colors.transparent,
                          borderRadius:
                          BorderRadius.circular(8),
                        ),
                        child: Center(
                          child: Text(
                            "${day.day}",
                            style: TextStyle(
                              color: selected
                                  ? Colors.white
                                  : isHoliday
                                  ? Colors.grey.shade400
                                  : Colors.black,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),

        const SizedBox(height: 12),

        /// 주차
        Container(
          height: 42,
          color: const Color(0xffF7F7F7),
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
                    getWeekTitle(selectedDate),
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
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

        /// 스케줄 표
        Expanded(
          child: EWeekGrid(
            weekDates: weekDates,
            schedules: isAllView
                ? allSchedules.map(
                  (k, v) => MapEntry(k, v.cast<dynamic>()),
            )
                : monthSchedules.map(
                  (k, v) => MapEntry(k, v.cast<dynamic>()),
            ),
            holidays: holidays,
            isAllView: isAllView,
          ),
        ),
      ],
    );
  }
}