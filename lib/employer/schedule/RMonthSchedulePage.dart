import 'package:flutter/material.dart';

class RMonthSchedulePage extends StatelessWidget {
  final DateTime selectedDate;
  final ValueChanged<DateTime> onDateChanged;

  const RMonthSchedulePage({
    super.key,
    required this.selectedDate,
    required this.onDateChanged,
  });

  @override
  Widget build(BuildContext context) {
    final firstDay = DateTime(
      selectedDate.year,
      selectedDate.month,
      1,
    );

    final lastDay = DateTime(
      selectedDate.year,
      selectedDate.month + 1,
      0,
    );

    // 일요일 시작
    final startOffset = firstDay.weekday % 7;

    final prevMonthLast =
    DateTime(selectedDate.year, selectedDate.month, 0);

    // 항상 6주(42칸)
    final List<DateTime> dates = [];

    for (int i = 0; i < 42; i++) {
      final day = i - startOffset + 1;

      if (day <= 0) {
        dates.add(
          DateTime(
            selectedDate.year,
            selectedDate.month - 1,
            prevMonthLast.day + day,
          ),
        );
      } else if (day > lastDay.day) {
        dates.add(
          DateTime(
            selectedDate.year,
            selectedDate.month + 1,
            day - lastDay.day,
          ),
        );
      } else {
        dates.add(
          DateTime(
            selectedDate.year,
            selectedDate.month,
            day,
          ),
        );
      }
    }

    const weekNames = ["일", "월", "화", "수", "목", "금", "토"];

    return Column(
      children: [
        // 요일
        SizedBox(
          height: 36,
          child: Row(
            children: List.generate(
              7,
                  (index) => Expanded(
                child: Center(
                  child: Text(
                    weekNames[index],
                    style: const TextStyle(
                      color: Color(0xFFA7A7A7),
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),

        // 월간 달력
        Expanded(
          child: Table(
            defaultVerticalAlignment:
            TableCellVerticalAlignment.top,
            children: List.generate(
              6,
                  (row) => TableRow(
                children: List.generate(
                  7,
                      (col) {
                    final date = dates[row * 7 + col];

                    final isCurrentMonth =
                        date.month == selectedDate.month;

                    final isSelected =
                        date.year == selectedDate.year &&
                            date.month == selectedDate.month &&
                            date.day == selectedDate.day;

                    return GestureDetector(
                      onTap: () => onDateChanged(date),
                      child: Container(
                        height: 140,
                        padding: const EdgeInsets.only(top: 10),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? const Color(0xFFF2F8FF)
                              : Colors.white,
                          border: Border(
                            top: BorderSide(
                              color: const Color(0xFFE9E9EE),
                              width: row == 0 ? 0 : 1,
                            ),
                          ),
                        ),
                        child: Align(
                          alignment: Alignment.topCenter,
                          child: Text(
                            "${date.day}",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: isSelected
                                  ? const Color(0xFF1976FF)
                                  : isCurrentMonth
                                  ? Colors.black
                                  : const Color(0xFFC8C8D2),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}