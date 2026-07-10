import 'package:flutter/material.dart';
import '../../home/schedule/api/CalendarActivateApi.dart';
import '../../home/schedule/models/CalendarActivate.dart';

class ApplicationCalendar extends StatefulWidget {
  final bool isSubstitute;
  final int workPlaceId;
  final bool hasSelectedWorker;
  final bool workerConfirmed;

  const ApplicationCalendar({
    super.key,
    required this.isSubstitute,
    required this.workPlaceId,
    required this.focusedMonth,
    required this.days,
    required this.selectedDate,
    required this.selectedWorkerDate,
    required this.workerMode,
    required this.showWorkerSelect,
    required this.isMyWorkDay,
    required this.isWorkerWorkDay,
    required this.isSelectedWorkerWorkDay,
    required this.isSelectable,
    required this.isNextWeek,
    required this.onSelectDay,
    required this.onPrevMonth,
    required this.onNextMonth,
    required this.hasSelectedWorker,
    required this.workerConfirmed,
  });

  final DateTime focusedMonth;
  final List<DateTime> days;

  final DateTime? selectedDate;
  final DateTime? selectedWorkerDate;

  final bool workerMode;
  final bool showWorkerSelect;

  final bool Function(DateTime) isMyWorkDay;
  final bool Function(DateTime) isSelectedWorkerWorkDay;
  final bool Function(DateTime) isWorkerWorkDay;
  final bool Function(DateTime) isSelectable;
  final bool Function(DateTime) isNextWeek;

  final ValueChanged<DateTime> onSelectDay;
  final VoidCallback onPrevMonth;
  final VoidCallback onNextMonth;

  @override
  State<ApplicationCalendar> createState() => _ApplicationCalendarState();
}

class _ApplicationCalendarState extends State<ApplicationCalendar> {
  bool _isSelectable(DateTime day) => widget.isSelectable(day);

  /// 캘린더 한 칸(day)의 배경색 / 텍스트색을 계산한다.
  /// 대타(isSubstitute)와 교대는 근무자 선택 화면에서 서로 다른 규칙을 쓴다.
  ///  - 교대 : 상대 근무자의 다른 근무일들을 연두/초록으로 함께 보여줘야 함
  ///  - 대타 : 오직 "내가 선택한 날짜" 하나만 의미가 있으므로 연두/초록이 필요 없고,
  ///           근무자를 고르기 전엔 회색, 고른 후엔 다시 파란색으로 표시되어야 함
  ({Color bg, Color text}) _resolveColors({
    required bool isCurrent,
    required bool isMySelected,
    required bool isWorkerSelected,
    required bool workerWorkDay,
    required bool selectable,
  }) {
    const blue = Color(0xff0084FF);
    const gray = Color(0xffE9E9EE);
    const darkGreen = Color(0xff27C840);
    const lightGreen = Color(0xffD9F6C5);
    const darkGreenText = Color(0xff6E8F4B);
    const disabledText = Color(0xffBDBDBD);
    const dimmedText = Color(0xffD1D1DD);

    Color bg;
    Color text;

    if (widget.workerMode && widget.showWorkerSelect) {
      // ==========================
      // 근무자 선택 화면
      // ==========================
      if (widget.isSubstitute) {
        // 대타 : 상대 근무자의 근무일 표시는 필요 없음.
        // 근무자를 아직 선택 안 했으면 회색, 선택했으면 파란색.
        if (isMySelected) {
          bg = widget.hasSelectedWorker ? blue : gray;
          text = widget.hasSelectedWorker ? Colors.white : Colors.black;
        } else {
          bg = Colors.transparent;
          text = selectable ? Colors.black : disabledText;
        }
      } else {
        // 교대 : 상대 근무자의 근무일들을 연두/초록으로 표시
        if (workerWorkDay) {
          bg = isWorkerSelected ? darkGreen : lightGreen;
          text = isWorkerSelected ? Colors.white : darkGreenText;
        } else if (isMySelected) {
          bg = gray;
          text = Colors.black;
        } else {
          bg = Colors.transparent;
          text = selectable ? Colors.black : disabledText;
        }
      }
    } else if (widget.workerMode) {
      // ==========================
      // 근무자 확정 후
      // ==========================
      if (widget.isSubstitute) {
        // 대타 : 확정 후에는 내 날짜(=대타 날짜)만 파랑
        if (isMySelected) {
          bg = blue;
          text = Colors.white;
        } else {
          bg = Colors.transparent;
          text = selectable ? Colors.black : disabledText;
        }
      } else {
        // 교대 : 내 날짜 파랑 + 확정된 상대 날짜 초록
        if (isMySelected) {
          bg = blue;
          text = Colors.white;
        } else if (workerWorkDay) {
          bg = isWorkerSelected ? darkGreen : lightGreen;
          text = isWorkerSelected ? Colors.white : darkGreenText;
        } else {
          bg = Colors.transparent;
          text = selectable ? Colors.black : disabledText;
        }
      }
    } else {
      // ==========================
      // 처음 (내 근무 선택 단계)
      // ==========================
      if (isMySelected) {
        bg = blue;
        text = Colors.white;
      } else if (workerWorkDay) {
        bg = isWorkerSelected ? darkGreen : lightGreen;
        text = isWorkerSelected ? Colors.white : darkGreenText;
      } else if (selectable) {
        // 선택 가능한 내 근무일: 연한 파란색 배경으로 강조
        bg = const Color(0xffE6F3FF);
        text = Colors.black;
      } else {
        bg = Colors.transparent;
        text = disabledText;
      }
    }

    if (!isCurrent) {
      text = dimmedText;
    }

    return (bg: bg, text: text);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        /// 월 이동
        Row(
          children: [
            GestureDetector(
              onTap: widget.onPrevMonth,
              child: Container(
                width: 30,
                height: 30,
                decoration: const BoxDecoration(
                  color: Color(0xffF4F4F8),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.chevron_left, color: Color(0xff999999)),
              ),
            ),
            Expanded(
              child: Center(
                child: Text(
                  "${widget.focusedMonth.year}년 ${widget.focusedMonth.month}월",
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                ),
              ),
            ),
            GestureDetector(
              onTap: widget.onNextMonth,
              child: Container(
                width: 30,
                height: 30,
                decoration: const BoxDecoration(
                  color: Color(0xffF4F4F8),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.chevron_right, color: Color(0xff999999)),
              ),
            ),
          ],
        ),

        const SizedBox(height: 20),

        Row(
          children: List.generate(7, (i) {
            const weeks = ["일", "월", "화", "수", "목", "금", "토"];
            return Expanded(
              child: Center(
                child: Text(
                  weeks[i],
                  style: const TextStyle(color: Color(0xffA7A7A7), fontWeight: FontWeight.w500),
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
            final day = widget.days[index];

            final isCurrent = day.month == widget.focusedMonth.month;

            final isMySelected = widget.selectedDate != null &&
                day.year == widget.selectedDate!.year &&
                day.month == widget.selectedDate!.month &&
                day.day == widget.selectedDate!.day;

            final isWorkerSelected = widget.selectedWorkerDate != null &&
                day.year == widget.selectedWorkerDate!.year &&
                day.month == widget.selectedWorkerDate!.month &&
                day.day == widget.selectedWorkerDate!.day;

            final selectable = _isSelectable(day);

            // 선택한 근무자의 근무일 (전체)
            final workerWorkDayRaw = widget.isSelectedWorkerWorkDay(day);

            // 확정 이후에는 확정된 날짜(isWorkerSelected) 외의 다른 근무일은 표시하지 않음
            final workerWorkDay = widget.workerConfirmed
                ? (workerWorkDayRaw && isWorkerSelected)
                : workerWorkDayRaw;

            final colors = _resolveColors(
              isCurrent: isCurrent,
              isMySelected: isMySelected,
              isWorkerSelected: isWorkerSelected,
              workerWorkDay: workerWorkDay,
              selectable: selectable,
            );

            return GestureDetector(
              onTap: selectable ? () => widget.onSelectDay(day) : null,
              child: Center(
                child: Container(
                  width: 48,
                  height: 48,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: colors.bg,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    "${day.day}",
                    style: TextStyle(
                      fontSize: 16,
                      color: colors.text,
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