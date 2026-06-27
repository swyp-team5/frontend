import 'package:chack_chack/employee/home/schedule/widgets/ESubmitScheduleBottomSheet.dart';
import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

import '../../../common/employee/EScheduleSubmitComplete.dart';
import 'models/ScheduleInfo.dart';

class ESubmitSchedulePage extends StatefulWidget {
  const ESubmitSchedulePage({super.key});

  @override
  State<ESubmitSchedulePage> createState() => _ESubmitSchedulePageState();
}

class _ESubmitSchedulePageState extends State<ESubmitSchedulePage> {
  late DateTime selectedDate;
  late DateTime startDate;
  late DateTime endDate;

  /// 현재 캘린더에서 선택된 날짜
  final Set<DateTime> selectedDays = {};

  /// 저장 완료된 날짜 + 선택한 시간
  final Map<DateTime, ScheduleInfo> savedSchedules = {};

  bool holiday = false;

  /// 더미 휴무일 (6월 29일)
  final List<DateTime> offDays = [
    DateTime(2026, 6, 29),
  ];

  bool get _canProceed => holiday || selectedDays.isNotEmpty;

  @override
  void initState() {
    super.initState();

    final now = DateTime.now();
    selectedDate = now;

    final weekday = now.weekday;
    final thisWeekStart =
    now.subtract(Duration(days: weekday % 7));

    startDate = thisWeekStart.add(const Duration(days: 7));
    endDate = startDate.add(const Duration(days: 6));
  }

  bool _isSame(DateTime a, DateTime b) {
    return a.year == b.year &&
        a.month == b.month &&
        a.day == b.day;
  }

  bool isSelectable(DateTime day) {
    final d = DateTime(day.year, day.month, day.day);

    return !d.isBefore(startDate) &&
        !d.isAfter(endDate) &&
        !isOffDay(day);
  }

  bool isSelected(DateTime day) {
    return selectedDays.any((e) => _isSame(e, day));
  }

  bool isOffDay(DateTime day) {
    return offDays.any(
          (e) =>
      e.year == day.year &&
          e.month == day.month &&
          e.day == day.day,
    );
  }

  bool isSaved(DateTime day) {
    return savedSchedules.keys.any((e) => _isSame(e, day));
  }

  void _onDayTap(DateTime day) async {
    if (!isSelectable(day) || holiday || isSaved(day)) return;

    setState(() {
      if (isSelected(day)) {
        selectedDays.removeWhere((e) => _isSame(e, day));
      } else {
        selectedDays.add(
          DateTime(day.year, day.month, day.day),
        );
      }
    });

    /// 여기서 BottomSheet 호출
    final result = await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) {
        return ESubmitScheduleBottomSheet(
          date: day,
        );
      },
    );

    /// BottomSheet 결과 받기
    if (result != null) {
      setState(() {
        savedSchedules.removeWhere((key, value) => _isSame(key, day));

        savedSchedules[DateTime(day.year, day.month, day.day)] =
            ScheduleInfo(
              types: List<String>.from(result["types"]),
              timeRange: result["timeRange"],
            );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 20),

            /// ✅ 커스텀 헤더 (RStoreClosePage 스타일)
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 10,
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  /// 뒤로가기
                  Align(
                    alignment: Alignment.centerLeft,
                    child: GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: const Icon(
                        Icons.arrow_back_ios_new,
                        size: 22,
                      ),
                    ),
                  ),

                  /// 타이틀
                  const Text(
                    "스케줄 제출",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),

            Expanded(
              child: Padding(
                padding:
                const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: [
                    SizedBox(height: 420,
                      child:
                      TableCalendar(
                        rowHeight: 60,
                        daysOfWeekHeight: 40,
                        locale: 'ko_KR',
                        firstDay: DateTime.now()
                            .subtract(const Duration(days: 365)),
                        lastDay: DateTime.now()
                            .add(const Duration(days: 365)),
                        focusedDay: selectedDate,
                        calendarFormat: CalendarFormat.month,

                        startingDayOfWeek:
                        StartingDayOfWeek.sunday,

                        selectedDayPredicate: (day) {
                          return isSelected(day) && !isSaved(day);
                        },

                        enabledDayPredicate: (day) {
                          return isSelectable(day);
                        },

                        onDaySelected:
                            (selectedDay, focusedDay) {
                          _onDayTap(selectedDay);
                        },

                        onPageChanged: (focusedDay) {
                          setState(() {
                            selectedDate = focusedDay;
                          });
                        },

                        headerStyle: HeaderStyle(
                          formatButtonVisible: false,
                          titleCentered: true,

                          titleTextStyle: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: Colors.black,
                          ),

                          leftChevronIcon: Transform.translate(
                            offset: const Offset(-15, 0), // 왼쪽으로 15
                            child: Container(
                              width: 30,
                              height: 30,
                              decoration: const BoxDecoration(
                                color: Color(0xFFF4F5FA),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.chevron_left,
                                color: Color(0xFFB7BCC8),
                              ),
                            ),
                          ),

                          rightChevronIcon: Transform.translate(
                            offset: const Offset(15, 0), // 오른쪽으로 15
                            child: Container(
                              width: 30,
                              height: 30,
                              decoration: const BoxDecoration(
                                color: Color(0xFFF4F5FA),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.chevron_right,
                                color: Color(0xFFB7BCC8),
                              ),
                            ),
                          ),
                        ),

                        daysOfWeekStyle: const DaysOfWeekStyle(
                          weekdayStyle: TextStyle(
                            fontSize: 15,
                            color: Color(0xFF9B9B9B),
                            fontWeight: FontWeight.w500,
                          ),
                          weekendStyle: TextStyle(
                            fontSize: 15,
                            color: Color(0xFF9B9B9B),
                            fontWeight: FontWeight.w500,
                          ),
                        ),

                        calendarStyle: CalendarStyle(
                          isTodayHighlighted: false,

                          outsideTextStyle: const TextStyle(
                            color: Color(0xFFD5D7E2),
                            fontSize: 16,
                          ),

                          defaultTextStyle: const TextStyle(
                            color: Colors.black,
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),

                          disabledTextStyle: const TextStyle(
                            color: Color(0xFFD5D7E2),
                            fontSize: 16,
                          ),

                          cellMargin: const EdgeInsets.all(4),

                          tablePadding: EdgeInsets.zero,
                        ),

                        calendarBuilders: CalendarBuilders(
                          defaultBuilder: (context, day, focusedDay) {
                            if (isSaved(day)) {
                              return Center(
                                child: Container(
                                  width: 44,
                                  height: 44,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFF1F1F5),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  alignment: Alignment.center,
                                  child: Text(
                                    '${day.day}',
                                    style: const TextStyle(
                                      color: Color(0xFF767676),
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              );
                            }

                            final enable = isSelectable(day);

                            return Center(
                              child: Text(
                                '${day.day}',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                  color: enable
                                      ? Colors.black
                                      : const Color(0xFFD5D7E2),
                                ),
                              ),
                            );
                          },

                          outsideBuilder: (context, day, focusedDay) {
                            return Center(
                              child: Text(
                                '${day.day}',
                                style: const TextStyle(
                                  fontSize: 16,
                                  color: Color(0xFFD5D7E2),
                                ),
                              ),
                            );
                          },

                          selectedBuilder: (context, day, focusedDay) {
                            return Center(
                              child: Container(
                                width: 44,
                                height: 44,
                                decoration: BoxDecoration(
                                  color: const Color(0xFF0084FF),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                alignment: Alignment.center,
                                child: Text(
                                  '${day.day}',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF1F1F5),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Center(
                        child: Text(
                          "근무가 불가능한 날짜를 선택해주세요",
                          style: TextStyle(color: Color(0xFF767676)),
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    /// 휴무 없음 체크
                    savedSchedules.isEmpty
                        ? Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 15,
                      ),
                      child: Row(
                        children: [
                          Transform.scale(
                            scale: 1.3,
                            child: SizedBox(
                              width: 22,
                              height: 22,
                              child: Checkbox(
                                value: holiday,
                                activeColor: const Color(0xFF0084FF),
                                onChanged: selectedDays.isEmpty
                                    ? (v) {
                                  setState(() {
                                    holiday = v ?? false;
                                  });
                                }
                                    : null,
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Text(
                            "불가능한 날짜가 없어요",
                            style: TextStyle(
                              color: const Color(0xFF505050),
                              fontSize: 15,
                              fontWeight:
                              holiday ? FontWeight.w600 : FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    )

                        : Expanded(
                      child: ListView.builder(
                        itemCount: savedSchedules.length,
                        itemBuilder: (context, index) {
                          final date = savedSchedules.keys.elementAt(index);
                          final info = savedSchedules.values.elementAt(index);

                          return Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            padding: const EdgeInsets.all(18),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF1F1F5),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "${date.month}월 ${date.day}일",
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.black,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        info.timeRange,
                                        style: const TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.black,
                                        ),
                                      ),

                                      const SizedBox(height: 8),

                                      Text(
                                        info.types.join(", "),
                                        style: const TextStyle(
                                          fontSize: 14,
                                          color: Color(0xFF767676),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                                GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      savedSchedules.remove(date);

                                      selectedDays.removeWhere(
                                            (e) => _isSame(e, date),
                                      );
                                    });
                                  },
                                  child: const Icon(
                                    Icons.close,
                                    color: Color(0xFF767676),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),

      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            20,
            0,
            20,
            20,
          ),
          child: SizedBox(
            height: 58,
            child: ElevatedButton(
              onPressed: _canProceed
                  ? () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => EScheduleSubmitComplete(
                      startDate: startDate,
                      endDate: endDate,
                    ),
                  ),
                );
              }
                  : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1687F8),
                disabledBackgroundColor:
                const Color(0xFFA9D0FB),
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                "다음",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}