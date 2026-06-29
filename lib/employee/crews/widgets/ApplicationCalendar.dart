import 'package:flutter/material.dart';

class ApplicationCalendar extends StatelessWidget {
  const ApplicationCalendar({
    super.key,
    required this.focusedMonth,
    required this.days,
    required this.selectedDate,
    required this.selectedWorkerDate,
    required this.workerMode,
    required this.showWorkerSelect,
    required this.isMyWorkDay,
    required this.isSelectedWorkerWorkDay,
    required this.isSelectable,
    required this.isNextWeek,
    required this.onSelectDay,
    required this.onPrevMonth,
    required this.onNextMonth,
  });

  final DateTime focusedMonth;

  final List<DateTime> days;

  final DateTime? selectedDate;
  final DateTime? selectedWorkerDate;

  final bool workerMode;
  final bool showWorkerSelect;

  final bool Function(DateTime) isMyWorkDay;
  final bool Function(DateTime) isSelectedWorkerWorkDay;
  final bool Function(DateTime) isSelectable;
  final bool Function(DateTime) isNextWeek;

  final ValueChanged<DateTime> onSelectDay;

  final VoidCallback onPrevMonth;
  final VoidCallback onNextMonth;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [

        /// 월 이동
        Row(
          children: [
            GestureDetector(
              onTap: onPrevMonth,
              child: Container(
                width: 30,
                height: 30,
                decoration: const BoxDecoration(
                  color: Color(0xffF4F4F8),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.chevron_left,
                  color: Color(0xff999999),
                ),
              ),
            ),

            Expanded(
              child: Center(
                child: Text(
                  "${focusedMonth.year}년 ${focusedMonth.month}월",
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),

            GestureDetector(
              onTap: onNextMonth,
              child: Container(
                width: 30,
                height: 30,
                decoration: const BoxDecoration(
                  color: Color(0xffF4F4F8),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.chevron_right,
                  color: Color(0xff999999),
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 20),

        /// 요일
        Row(
          children: List.generate(7, (i) {
            const weeks = ["일", "월", "화", "수", "목", "금", "토"];

            return Expanded(
              child: Center(
                child: Text(
                  weeks[i],
                  style: const TextStyle(
                    color: Color(0xffA7A7A7),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            );
          }),
        ),

        const SizedBox(height: 10),

        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: 42,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 7,
            childAspectRatio: 1,
          ),
          itemBuilder: (_, index) {
            final day = days[index];

            final isCurrent = day.month == focusedMonth.month;

            final isMySelected =
                selectedDate != null &&
                    day.year == selectedDate!.year &&
                    day.month == selectedDate!.month &&
                    day.day == selectedDate!.day;

            final isWorkerSelected =
                selectedWorkerDate != null &&
                    day.year == selectedWorkerDate!.year &&
                    day.month == selectedWorkerDate!.month &&
                    day.day == selectedWorkerDate!.day;

            final selectable = isSelectable(day);

            final myWorkDay = isMyWorkDay(day);
            final workerWorkDay = isSelectedWorkerWorkDay(day);

            return GestureDetector(
              onTap: selectable
                  ? () => onSelectDay(day)
                  : null,
              child: Center(
                child: Container(
                  width: 48,
                  height: 48,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: workerMode
                        ? showWorkerSelect
                    // 근무자 선택 중
                        ? (workerWorkDay
                        ? (isWorkerSelected
                        ? const Color(0xff27C840)
                        : const Color(0xffD9F6C5))
                        : (isMySelected
                        ? const Color(0xffF1F1F5)
                        : Colors.transparent))
                    // 근무자 확정 후
                        : (isMySelected
                        ? const Color(0xff0084FF)
                        : workerWorkDay
                        ? (isWorkerSelected
                        ? const Color(0xff27C840)
                        : Colors.transparent)
                        : Colors.transparent)
                        : (isMySelected
                        ? const Color(0xff0084FF)
                        : (myWorkDay && isNextWeek(day))
                        ? const Color(0xffE6F3FF)
                        : Colors.transparent),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    "${day.day}",
                    style: TextStyle(
                      fontSize: 16,
                      color: !isCurrent
                          ? const Color(0xffD1D1DD)

                      // ==========================
                      // 근무자 선택 단계
                      // ==========================
                          : workerMode && showWorkerSelect
                          ? isWorkerSelected
                          ? Colors.white
                          : workerWorkDay
                          ? const Color(0xff8F8F8F) // ← 회색
                          : isMySelected
                          ? const Color(0xff999999)
                          : selectable
                          ? Colors.black
                          : const Color(0xffBDBDBD)

                      // ==========================
                      // 근무자 확정 이후
                      // ==========================
                          : workerMode
                          ? isMySelected
                          ? Colors.white
                          : isWorkerSelected
                          ? Colors.white
                          : workerWorkDay
                          ? const Color(0xffBDBDBD) // ← 선택 안 된 상대 근무일은 회색
                          : selectable
                          ? Colors.black
                          : const Color(0xffBDBDBD)

                      // ==========================
                      // 처음
                      // ==========================
                          : isMySelected
                          ? Colors.white
                          : selectable
                          ? Colors.black
                          : const Color(0xffBDBDBD),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}