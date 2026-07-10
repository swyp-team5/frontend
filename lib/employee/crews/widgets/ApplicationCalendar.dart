import 'package:flutter/material.dart';
import '../../home/schedule/api/CalendarActivateApi.dart';
import '../../home/schedule/models/CalendarActivate.dart';

class ApplicationCalendar extends StatefulWidget {
  final bool isSubstitute;

  /// API 호출에 필요한 근무지 ID
  final int workPlaceId;

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

  /// 워커모드/근무확정 등 화면 자체의 비즈니스 로직 기반 선택 가능 여부.
  /// 최종 선택 가능 여부는 이 값 && API 기반(휴무/제한) 값을 함께 만족해야 함.
  final bool Function(DateTime) isSelectable;

  final bool Function(DateTime) isNextWeek;

  final ValueChanged<DateTime> onSelectDay;

  final VoidCallback onPrevMonth;
  final VoidCallback onNextMonth;

  @override
  State<ApplicationCalendar> createState() => _ApplicationCalendarState();
}

class _ApplicationCalendarState extends State<ApplicationCalendar> {

  @override
  void initState() {
    super.initState();
  }

  @override

  /// 최종 선택 가능 여부 = API 기반 && 화면 비즈니스 로직 기반
  bool _isSelectable(DateTime day) {
    return widget.isSelectable(day);
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
                child: const Icon(
                  Icons.chevron_left,
                  color: Color(0xff999999),
                ),
              ),
            ),

            Expanded(
              child: Center(
                child: Text(
                  "${widget.focusedMonth.year}년 ${widget.focusedMonth.month}월",
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
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
            final day = widget.days[index];

            final isCurrent = day.month == widget.focusedMonth.month;

            final isMySelected =
                widget.selectedDate != null &&
                    day.year == widget.selectedDate!.year &&
                    day.month == widget.selectedDate!.month &&
                    day.day == widget.selectedDate!.day;

            final isWorkerSelected =
                widget.selectedWorkerDate != null &&
                    day.year == widget.selectedWorkerDate!.year &&
                    day.month == widget.selectedWorkerDate!.month &&
                    day.day == widget.selectedWorkerDate!.day;

            final selectable = _isSelectable(day);

            final myWorkDay = widget.isMyWorkDay(day);

            // 모든 근무자의 근무일
            final allWorkerWorkDay = widget.isWorkerWorkDay(day);

            // 선택한 근무자의 근무일
            final workerWorkDay = widget.isSelectedWorkerWorkDay(day);

            return GestureDetector(
              onTap: selectable
                  ? () => widget.onSelectDay(day)
                  : null,
              child: Center(
                child: Container(
                  width: 48,
                  height: 48,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: widget.workerMode
                        ? widget.isSubstitute
                    // ==========================
                    // 대타 신청
                    // ==========================
                        ? (isMySelected
                        ? const Color(0xff0084FF)
                        : Colors.transparent)

                    // ==========================
                    // 교대 신청
                    // ==========================
                        : widget.showWorkerSelect
                        ? (allWorkerWorkDay
                        ? (isWorkerSelected
                        ? const Color(0xff27C840)
                        : const Color(0xffD9F6C5))
                        : (isMySelected
                        ? const Color(0xffF1F1F5)
                        : Colors.transparent))
                        : (isMySelected
                        ? const Color(0xff0084FF)
                        : workerWorkDay
                        ? (isWorkerSelected
                        ? const Color(0xff27C840)
                        : Colors.transparent)
                        : Colors.transparent)

                        : (isMySelected
                        ? const Color(0xff0084FF)
                        : (myWorkDay && widget.isNextWeek(day))
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
                          : widget.workerMode && widget.showWorkerSelect
                          ? widget.isSubstitute
                      // ---------- 대타 ----------
                          ? isMySelected
                          ? Colors.white
                          : selectable
                          ? Colors.black
                          : const Color(0xffBDBDBD)

                      // ---------- 교대 ----------
                          : isWorkerSelected
                          ? Colors.white
                          : allWorkerWorkDay
                          ? const Color(0xff8F8F8F)
                          : isMySelected
                          ? const Color(0xff999999)
                          : selectable
                          ? Colors.black
                          : const Color(0xffBDBDBD)

                      // ==========================
                      // 근무자 확정 이후
                      // ==========================
                          : widget.workerMode
                          ? widget.isSubstitute
                      // ---------- 대타 ----------
                          ? isMySelected
                          ? Colors.white
                          : selectable
                          ? Colors.black
                          : const Color(0xffBDBDBD)

                      // ---------- 교대 ----------
                          : isMySelected
                          ? Colors.white
                          : isWorkerSelected
                          ? Colors.white
                          : workerWorkDay
                          ? const Color(0xffBDBDBD)
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