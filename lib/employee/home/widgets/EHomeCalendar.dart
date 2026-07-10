import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

class EHomeCalendar extends StatelessWidget {
  final DateTime focusedDay;
  final DateTime? selectedDay;
  final Set<DateTime> workedDates;

  final void Function(DateTime selectedDay, DateTime focusedDay)
  onDaySelected;

  const EHomeCalendar({
    super.key,
    required this.focusedDay,
    required this.selectedDay,
    required this.onDaySelected,
    required this.workedDates,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      child: TableCalendar(
        locale: 'ko_KR',

        firstDay: DateTime.utc(2020, 1, 1),
        lastDay: DateTime.utc(2035, 12, 31),

        focusedDay: focusedDay,

        weekendDays: const [
          DateTime.sunday,
        ],

        // selectedDayPredicate: (day) {
        //   return isSameDay(selectedDay, day);
        // },

        // onDaySelected: onDaySelected,

        headerStyle: const HeaderStyle(
          formatButtonVisible: false,
          titleCentered: true,
          titleTextStyle: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),

        daysOfWeekStyle: const DaysOfWeekStyle(
          weekendStyle: TextStyle(
            color: Colors.red,
          ),
        ),

        calendarStyle: const CalendarStyle(
          weekendTextStyle: TextStyle(
            color: Colors.red,
          ),

          todayDecoration: BoxDecoration(
            color: Colors.transparent,
          ),

          todayTextStyle: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.normal,
          ),

          selectedDecoration: BoxDecoration(
            color: Colors.transparent,
          ),

          selectedTextStyle: TextStyle(
            color: Colors.black,
          ),
        ),

        calendarBuilders: CalendarBuilders(
          /// 일반 날짜
          defaultBuilder: (context, day, focusedDay) {
            final hasSchedule = workedDates.any(
                  (d) => isSameDay(d, day),
            );

            if (!hasSchedule) return null;

            return Container(
              margin: const EdgeInsets.all(6),
              decoration: const BoxDecoration(
                color: Color(0xFFE6F3FF),
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: Text(
                '${day.day}',
                style: const TextStyle(
                  color: Color(0xFF0084FF),
                  fontWeight: FontWeight.w600,
                ),
              ),
            );
          },

          // /// 오늘
          // todayBuilder: (context, day, focusedDay) {
          //   final hasSchedule = workedDates.any(
          //         (d) => isSameDay(d, day),
          //   );
          //
          //   if (hasSchedule) {
          //     return Container(
          //       margin: const EdgeInsets.all(6),
          //       decoration: const BoxDecoration(
          //         color: Color(0xFFE6F3FF),
          //         shape: BoxShape.circle,
          //       ),
          //       alignment: Alignment.center,
          //       child: Text(
          //         '${day.day}',
          //         style: const TextStyle(
          //           color: Color(0xFF0084FF),
          //           fontWeight: FontWeight.w600,
          //         ),
          //       ),
          //     );
          //   }
          //
          //   return Container(
          //     margin: const EdgeInsets.all(6),
          //     decoration: const BoxDecoration(
          //       color: Color(0xFF9FA8DA),
          //       shape: BoxShape.circle,
          //     ),
          //     alignment: Alignment.center,
          //     child: Text(
          //       '${day.day}',
          //       style: const TextStyle(
          //         color: Colors.white,
          //       ),
          //     ),
          //   );
          // },

          // /// 선택된 날짜
          // selectedBuilder: (context, day, focusedDay) {
          //   return Container(
          //     margin: const EdgeInsets.all(6),
          //     decoration: const BoxDecoration(
          //       color: Colors.black,
          //       shape: BoxShape.circle,
          //     ),
          //     alignment: Alignment.center,
          //     child: Text(
          //       '${day.day}',
          //       style: const TextStyle(
          //         color: Colors.white,
          //         fontWeight: FontWeight.w600,
          //       ),
          //     ),
          //   );
          // },
        ),
      ),
    );
  }
}