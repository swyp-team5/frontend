import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

/// "스케줄 만들기" 버튼을 눌렀을 때 뜨는, 제출 마감일을 고르는 바텀시트.
///
/// 선택 가능 범위: [todayKst] ~ [dueDate] (양 끝 포함)
/// 오늘은 항상 range의 시작점으로 고정 표시되고, 사용자가 고른 날짜가 끝점이 된다.
class RScheduleDeadlineBottomSheet extends StatefulWidget {
  final DateTime todayKst;
  final DateTime dueDate;

  /// 선택된 마감일을 인자로 받아 실제 등록 API를 호출하고,
  /// 성공하면 true, 실패하면 false를 반환해야 한다.
  final Future<bool> Function(DateTime selectedDeadline) onSubmit;

  const RScheduleDeadlineBottomSheet({
    super.key,
    required this.todayKst,
    required this.dueDate,
    required this.onSubmit,
  });

  /// 바텀시트를 띄우는 헬퍼.
  /// 반환값: 등록에 성공하면 true, 취소되거나 실패하면 false.
  static Future<bool> show(
      BuildContext context, {
        required DateTime todayKst,
        required DateTime dueDate,
        required Future<bool> Function(DateTime selectedDeadline) onSubmit,
      }) async {
    final result = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => RScheduleDeadlineBottomSheet(
        todayKst: todayKst,
        dueDate: dueDate,
        onSubmit: onSubmit,
      ),
    );

    return result ?? false;
  }

  @override
  State<RScheduleDeadlineBottomSheet> createState() =>
      _RScheduleDeadlineBottomSheetState();
}

class _RScheduleDeadlineBottomSheetState
    extends State<RScheduleDeadlineBottomSheet> {
  DateTime? _selectedDeadline;
  late DateTime _focusedDay;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _focusedDay = DateTime(widget.todayKst.year, widget.todayKst.month, 1);
  }

  bool _isSame(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  bool _isInRange(DateTime day) {
    final d = DateTime(day.year, day.month, day.day);
    return !d.isBefore(widget.todayKst) && !d.isAfter(widget.dueDate);
  }

  Widget _rangeCircle(DateTime day, {required bool bold}) {
    return Center(
      child: Container(
        width: 36,
        height: 36,
        alignment: Alignment.center,
        decoration: const BoxDecoration(
          color: Color(0xFF1687F8),
          shape: BoxShape.circle,
        ),
        child: Text(
          "${day.day}",
          style: TextStyle(
            color: Colors.white,
            fontSize: 15,
            fontWeight: bold ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  Future<void> _handleSubmit() async {
    if (_isSubmitting || _selectedDeadline == null) return;

    setState(() => _isSubmitting = true);

    final success = await widget.onSubmit(_selectedDeadline!);

    if (!mounted) return;

    if (success) {
      Navigator.pop(context, true);
    } else {
      setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: !_isSubmitting,
      child: Container(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Center(
              child: Container(
                width: 48,
                height: 5,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),

            // 제목 + 닫기 버튼: Row로 구성해서 X가 항상 우측 상단에 고정되도록 함
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(width: 28), // 오른쪽 닫기 버튼과 폭을 맞춰 제목이 정중앙에 오도록
                Expanded(
                  child: Column(
                    children: [
                      const Text(
                        "스케줄 제출 기한",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        "근무자들의 스케줄 제출 기한을 설정해주세요\n한번 제출한 기한은 수정이 불가능해요",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 13,
                          color: Color(0xFF767676),
                        ),
                      ),
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: _isSubmitting
                      ? null
                      : () => Navigator.pop(context, false),
                  child: Container(
                    width: 28,
                    height: 28,
                    decoration: const BoxDecoration(
                      color: Color(0xFFF2F2F6),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.close, size: 18),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            TableCalendar(
              locale: "ko_KR",
              firstDay: DateTime(2020),
              lastDay: DateTime(2100),
              focusedDay: _focusedDay,
              calendarFormat: CalendarFormat.month,

              availableCalendarFormats: const {
                CalendarFormat.month: 'Month',
              },

              rangeStartDay: widget.todayKst,
              rangeEndDay: _selectedDeadline,

              selectedDayPredicate: (_) => false,

              onPageChanged: (focusedDay) {
                setState(() {
                  _focusedDay = DateTime(focusedDay.year, focusedDay.month, 1);
                });
              },

              onDaySelected: (selectedDay, focusedDay) {
                if (_isSubmitting || !_isInRange(selectedDay)) return;

                setState(() {
                  _selectedDeadline = DateTime(
                    selectedDay.year,
                    selectedDay.month,
                    selectedDay.day,
                  );
                });
              },

              headerStyle: const HeaderStyle(
                titleCentered: true,
                formatButtonVisible: false,
                titleTextStyle: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),

              calendarStyle: const CalendarStyle(
                outsideDaysVisible: true,
                isTodayHighlighted: false,

                rangeHighlightColor: Colors.transparent,

                defaultTextStyle: TextStyle(
                  fontSize: 15,
                  color: Colors.black,
                ),

                outsideTextStyle: TextStyle(
                  fontSize: 15,
                  color: Color(0xFFD0D3DA),
                ),
              ),

              calendarBuilders: CalendarBuilders(

                defaultBuilder: (context, day, focusedDay) {
                  final inRange = _isInRange(day);

                  return Center(
                    child: Text(
                      "${day.day}",
                      style: TextStyle(
                        fontSize: 15,
                        color: inRange
                            ? Colors.black
                            : const Color(0xFFD0D3DA),
                      ),
                    ),
                  );
                },

                outsideBuilder: (context, day, focusedDay) {
                  return Center(
                    child: Text(
                      "${day.day}",
                      style: const TextStyle(
                        fontSize: 15,
                        color: Color(0xFFD0D3DA),
                      ),
                    ),
                  );
                },

                // 가운데 날짜
                withinRangeBuilder: (context, day, focusedDay) {
                  return Container(
                    width: double.infinity,
                    height: double.infinity,
                    color: const Color(0xFFE8F3FF),
                    alignment: Alignment.center,
                    child: Text(
                      "${day.day}",
                      style: const TextStyle(
                        fontSize: 15,
                        color: Colors.black,
                      ),
                    ),
                  );
                },

                // 시작 날짜
                rangeStartBuilder: (context, day, focusedDay) {
                  return Stack(
                    children: [

                      Positioned.fill(
                        child: Row(
                          children: [
                            const Expanded(child: SizedBox()),
                            Expanded(
                              child: Container(
                                color: const Color(0xFFE8F3FF),
                              ),
                            ),
                          ],
                        ),
                      ),

                      Center(
                        child: Container(
                          width: 50,
                          height: 50,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: const Color(0xFF1687F8),
                            borderRadius: BorderRadius.circular(10), // 원하는 만큼 조절
                          ),
                          child: Text(
                            "${day.day}",
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        )
                      ),
                    ],
                  );
                },

                // 종료 날짜
                rangeEndBuilder: (context, day, focusedDay) {
                  return Stack(
                    children: [

                      Positioned.fill(
                        child: Row(
                          children: [
                            Expanded(
                              child: Container(
                                color: const Color(0xFFE8F3FF),
                              ),
                            ),
                            const Expanded(child: SizedBox()),
                          ],
                        ),
                      ),

                      Center(
                        child: Container(
                          width: 50,
                          height: 50,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: const Color(0xFF1687F8),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            "${day.day}",
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        )
                      ),
                    ],
                  );
                },
              ),
            ),

            const SizedBox(height: 20),

            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed:
                (_isSubmitting || _selectedDeadline == null)
                    ? null
                    : _handleSubmit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0084FF),
                  disabledBackgroundColor: const Color(0xFFA9D0FB),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isSubmitting
                    ? const SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2.5,
                  ),
                )
                    : const Text(
                  "스케줄 만들기",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}