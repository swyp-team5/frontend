import 'package:flutter/material.dart';

import '../../common/widgets/BottomNavBar.dart';
import '../crews/RCrewPage.dart';
import '../home/RHomePage.dart';
import '../mypage/RMyPage.dart';

class RWeekSchedulePage extends StatefulWidget {
  final DateTime selectedDate;
  final ValueChanged<DateTime> onDateChanged;

  const RWeekSchedulePage({
    super.key,
    required this.selectedDate,
    required this.onDateChanged,
  });

  @override
  State<RWeekSchedulePage> createState() => _RWeekSchedulePageState();
}

class _RWeekSchedulePageState extends State<RWeekSchedulePage> {

  final List<String> monthNames = List.generate(
    12,
        (index) => "${index + 1}월",
  );

  /// 월요일 기준 시작 날짜
  DateTime getMonday(DateTime date) {
    return date.subtract(Duration(days: date.weekday - 1));
  }

  /// 해당 주의 월~일
  List<DateTime> getWeekDates(DateTime date) {
    final monday = getMonday(date);

    return List.generate(
      7,
          (index) => monday.add(Duration(days: index)),
    );
  }

  /// 한국 기준 n주차 계산
  int getWeekOfMonth(DateTime date) {
    final firstDay = DateTime(date.year, date.month, 1);

    // 월요일 시작 기준으로 첫 주의 시작일
    final firstWeekStart =
    firstDay.subtract(Duration(days: firstDay.weekday - 1));

    return (date.difference(firstWeekStart).inDays ~/ 7) + 1;
  }

  String getWeekTitle(DateTime date) {
    return "${date.year}년 ${date.month}월 ${getWeekOfMonth(date)}주차";
  }

  // 주간 스케줄
  bool isWeekMode = true; // true = 주, false = 월

  // 주간/월간 스케줄 선택 토글
  Widget _buildWeekMonthToggle() {
    return Container(
      width: 84,
      height: 38,
      decoration: BoxDecoration(
        color: const Color(0xFFF2F2F5),
        borderRadius: BorderRadius.circular(19),
      ),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () {
                setState(() {
                  isWeekMode = true;
                });
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                decoration: BoxDecoration(
                  color: isWeekMode
                      ? const Color(0xFF3A3A3C)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(19),
                ),
                alignment: Alignment.center,
                child: Text(
                  "주",
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: isWeekMode
                        ? Colors.white
                        : const Color(0xFF8E8E93),
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: () {
                setState(() {
                  isWeekMode = false;
                });
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                decoration: BoxDecoration(
                  color: !isWeekMode
                      ? const Color(0xFF3A3A3C)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(19),
                ),
                alignment: Alignment.center,
                child: Text(
                  "월",
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: !isWeekMode
                        ? Colors.white
                        : const Color(0xFF8E8E93),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final weekDates = getWeekDates(widget.selectedDate);

    return Stack(
      children: [
        Column(
          children: [
            // ================= 요일 =================
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Row(
                children: List.generate(7, (index) {
                  const weeks = ["월", "화", "수", "목", "금", "토", "일"];

                  return Expanded(
                    child: Center(
                      child: Text(
                        weeks[index],
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
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
                      day.year == widget.selectedDate.year &&
                          day.month == widget.selectedDate.month &&
                          day.day == widget.selectedDate.day;

                  return Expanded(
                    child: GestureDetector(
                      onTap: () => widget.onDateChanged(day),
                      child: Center(
                        child: Container(
                          width: 34,
                          height: 34,
                          decoration: BoxDecoration(
                            color: isSelected
                                ? const Color(0xff1976FF)
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Center(
                            child: Text(
                              "${day.day}",
                              style: TextStyle(
                                color:
                                isSelected ? Colors.white : Colors.black,
                                fontWeight: FontWeight.bold,
                              ),
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
              color: const Color(0xffF7F7F7),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () {
                      widget.onDateChanged(
                        widget.selectedDate.subtract(
                          const Duration(days: 7),
                        ),
                      );
                    },
                    icon: const Icon(Icons.chevron_left),
                  ),
                  Expanded(
                    child: Center(
                      child: Text(
                        getWeekTitle(widget.selectedDate),
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      widget.onDateChanged(
                        widget.selectedDate.add(
                          const Duration(days: 7),
                        ),
                      );
                    },
                    icon: const Icon(Icons.chevron_right),
                  ),
                ],
              ),
            ),

            // ================= 스케줄 표 =================
            Expanded(
              child: SingleChildScrollView(
                child: SizedBox(
                  height: 24 * 80,
                  child: Row(
                    children: [
                      // 시간
                      SizedBox(
                        width: 26,
                        child: Column(
                          children: List.generate(
                            24,
                                (index) => SizedBox(
                              height: 80,
                              child: Align(
                                alignment: Alignment.topCenter,
                                child: Text(
                                  "$index",
                                  style: const TextStyle(
                                    fontSize: 10,
                                    color: Colors.grey,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),

                      // 요일별 스케줄
                      Expanded(
                        child: Row(
                          children: List.generate(7, (dayIndex) {
                            Color bg = Colors.white;

                            if (dayIndex == 0 || dayIndex == 2) {
                              bg = const Color(0xffDDECFB);
                            } else if (dayIndex == 1 || dayIndex == 3) {
                              bg = const Color(0xffDDEFD9);
                            } else if (dayIndex == 5 || dayIndex == 6) {
                              bg = const Color(0xffE8E3F8);
                            }

                            return Expanded(
                              child: Container(
                                color: bg,
                                child: Column(
                                  children: List.generate(
                                    24,
                                        (hour) => Container(
                                      height: 80,
                                      decoration: BoxDecoration(
                                        border: Border(
                                          top: BorderSide(
                                            color: Colors.grey.shade300,
                                            width: 0.5,
                                          ),
                                          right: BorderSide(
                                            color: Colors.grey.shade300,
                                            width: 0.5,
                                          ),
                                        ),
                                      ),
                                      child: hour == 3
                                          ? const Center(
                                        child: Text(
                                          "김민지\n최재현",
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                            fontSize: 9,
                                            color: Color(0xff1976FF),
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      )
                                          : null,
                                    ),
                                  ),
                                ),
                              ),
                            );
                          }),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}