import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

class EHomeCalendar extends StatelessWidget {
  final DateTime focusedDay;
  final DateTime? selectedDay;

  final void Function(DateTime selectedDay, DateTime focusedDay)
  onDaySelected;

  const EHomeCalendar({
    super.key,
    required this.focusedDay,
    required this.selectedDay,
    required this.onDaySelected,
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

        selectedDayPredicate: (day) {
          return isSameDay(selectedDay, day);
        },

        onDaySelected: onDaySelected,

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
            color: Color(0xFF9FA8DA),
            shape: BoxShape.circle,
          ),

          selectedDecoration: BoxDecoration(
            color: Colors.black,
            shape: BoxShape.circle,
          ),
        ),
      ),
    );
  }
}