import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

class REditCalendarBottomSheet extends StatefulWidget {
  final DateTime? initialDate;

  /// 확정 배정이 있는 날짜("yyyy-MM-dd") 집합. 이 집합에 포함된 날짜만 선택 가능하다.
  final Set<String> enabledDates;

  const REditCalendarBottomSheet({
    super.key,
    this.initialDate,
    required this.enabledDates,
  });

  static Future<DateTime?> show(
      BuildContext context, {
        DateTime? initialDate,
        required Set<String> enabledDates,
      }) {
    return showModalBottomSheet<DateTime>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(28),
        ),
      ),
      builder: (_) => REditCalendarBottomSheet(
        initialDate: initialDate,
        enabledDates: enabledDates,
      ),
    );
  }

  @override
  State<REditCalendarBottomSheet> createState() => _REditCalendarBottomSheetState();
}

class _REditCalendarBottomSheetState extends State<REditCalendarBottomSheet> {

  late DateTime focusedDay;
  late DateTime selectedDay;

  @override
  void initState() {
    super.initState();

    focusedDay = DateTime.now();

    if (widget.initialDate != null) {
      selectedDay = DateTime(
        widget.initialDate!.year,
        widget.initialDate!.month,
        widget.initialDate!.day,
      );
    } else {
      selectedDay = DateTime.now();
    }

    focusedDay = selectedDay;
  }

  String _dateKey(DateTime date) {
    return "${date.year.toString().padLeft(4, '0')}-"
        "${date.month.toString().padLeft(2, '0')}-"
        "${date.day.toString().padLeft(2, '0')}";
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [

            const SizedBox(height: 10),

            Container(
              width: 52,
              height: 6,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(99),
              ),
            ),

            const SizedBox(height: 20),

            Stack(
              alignment: Alignment.center,
              children: [

                const Center(
                  child: Text(
                    "근무 날짜",
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),

                Align(
                  alignment: Alignment.centerRight,
                  child: IconButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    icon: const Icon(Icons.close),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 8),

            const Text(
              "근무 날짜를 선택해주세요",
              style: TextStyle(
                color: Color(0xff888888),
                fontSize: 14,
              ),
            ),

            const SizedBox(height: 18),

            TableCalendar(
              locale: 'ko_KR',

              firstDay: DateTime(2024),
              lastDay: DateTime(2035),
              focusedDay: focusedDay,

              selectedDayPredicate: (day) {
                return isSameDay(day, selectedDay);
              },

              // 확정 배정이 있는 날짜만 선택 가능하게 한다.
              enabledDayPredicate: (day) {
                return widget.enabledDates.contains(_dateKey(day));
              },

              onDaySelected: (selected, focused) {
                setState(() {
                  selectedDay = DateTime(
                    selected.year,
                    selected.month,
                    selected.day,
                  );
                  focusedDay = focused;
                });
              },

              onPageChanged: (focused) {
                focusedDay = focused;
              },

              headerStyle: const HeaderStyle(
                titleCentered: true,
                formatButtonVisible: false,
                leftChevronIcon: Icon(Icons.chevron_left),
                rightChevronIcon: Icon(Icons.chevron_right),
                titleTextStyle: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),

              daysOfWeekStyle: const DaysOfWeekStyle(
                weekdayStyle: TextStyle(
                  color: Color(0xff888888),
                ),
                weekendStyle: TextStyle(
                  color: Color(0xff888888),
                ),
              ),

              calendarStyle: CalendarStyle(
                todayDecoration: const BoxDecoration(
                  color: Colors.transparent,
                ),

                todayTextStyle: const TextStyle(
                  color: Colors.black,
                ),

                selectedDecoration: BoxDecoration(
                  color: const Color(0xff1687F8),
                  borderRadius: BorderRadius.circular(12),
                ),

                selectedTextStyle: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),

                outsideTextStyle: const TextStyle(
                  color: Color(0xffCFCFD6),
                ),

                defaultDecoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                ),

                weekendDecoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                ),

                cellMargin: const EdgeInsets.all(4),
              ),
            ),

            const SizedBox(height: 24),

            SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context, selectedDay);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xff1687F8),
                  disabledBackgroundColor:
                  const Color(0xffA9D0FB),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius:
                    BorderRadius.circular(14),
                  ),
                ),
                child: const Text(
                  "저장",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}