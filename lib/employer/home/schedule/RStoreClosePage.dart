import 'package:chack_chack/employer/home/schedule/RDayOffLimitPage.dart';
import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

import 'RMakingSchedulePage.dart';

class RStoreClosePage extends StatefulWidget {
  final int workPlaceId;
  final TimeOfDay openTime;
  final TimeOfDay closeTime;
  final int minWork;
  final int maxWork;
  final List<RegisteredSchedule> registeredSchedules;

  const RStoreClosePage({
    super.key,
    required this.workPlaceId,
    required this.openTime,
    required this.closeTime,
    required this.minWork,
    required this.maxWork,
    required this.registeredSchedules,
  });

  @override
  State<RStoreClosePage> createState() => _RStoreClosePageState();
}

class _RStoreClosePageState extends State<RStoreClosePage> {
  late DateTime _focusedDay;

  final Set<DateTime> _selectedDays = {};

  bool noClosedDay = false;

  bool get _canProceed => noClosedDay || _selectedDays.isNotEmpty;

  @override
  void initState() {
    super.initState();

    // 다음 주가 포함된 달을 기본으로 보여준다.
    _focusedDay = DateTime(_weekStart.year, _weekStart.month, 1);
  }

  /// 한국 시간
  DateTime get _koreaNow =>
      DateTime.now().toUtc().add(const Duration(hours: 9));

  /// 다음 주 월요일
  /// (오늘 기준 이번 주 월요일 + 7일 → 항상 "다음 주"를 가리킴)
  DateTime get _weekStart {
    final now = _koreaNow;
    final thisMonday = now.subtract(Duration(days: now.weekday - 1));

    final nextMonday = DateTime(
      thisMonday.year,
      thisMonday.month,
      thisMonday.day,
    ).add(const Duration(days: 7));

    return nextMonday;
  }

  /// 다음 주 일요일
  DateTime get _weekEnd {
    return _weekStart.add(const Duration(days: 6));
  }

  bool _isSame(DateTime a, DateTime b) {
    return a.year == b.year &&
        a.month == b.month &&
        a.day == b.day;
  }

  bool _isSelected(DateTime day) {
    return _selectedDays.any((e) => _isSame(e, day));
  }

  bool _isSelectable(DateTime day) {
    final d = DateTime(day.year, day.month, day.day);

    return !d.isBefore(_weekStart) &&
        !d.isAfter(_weekEnd);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      body: SafeArea(
        child: Column(
          children: [
            /// 헤더
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 30,
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
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
                  const Text(
                    "매장 휴일 선택",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
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
                    TableCalendar(
                      locale: "ko_KR",

                      firstDay: DateTime(2020),
                      lastDay: DateTime(2100),

                      focusedDay: _focusedDay,

                      calendarFormat: CalendarFormat.month,

                      availableCalendarFormats: const {
                        CalendarFormat.month: 'Month'
                      },

                      selectedDayPredicate: _isSelected,

                      onPageChanged: (focusedDay) {
                        setState(() {
                          _focusedDay = DateTime(
                            focusedDay.year,
                            focusedDay.month,
                            1,
                          );
                        });
                      },

                      onDaySelected:
                          (selectedDay, focusedDay) {
                        if (noClosedDay) return;

                        if (!_isSelectable(selectedDay)) {
                          return;
                        }

                        setState(() {
                          if (_isSelected(selectedDay)) {
                            _selectedDays.removeWhere(
                                  (e) =>
                                  _isSame(e, selectedDay),
                            );
                          } else {
                            _selectedDays.add(
                              DateTime(
                                selectedDay.year,
                                selectedDay.month,
                                selectedDay.day,
                              ),
                            );
                          }
                        });
                      },

                      headerStyle: const HeaderStyle(
                        titleCentered: true,
                        formatButtonVisible: false,
                        titleTextStyle: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),

                      calendarStyle: const CalendarStyle(
                        outsideDaysVisible: true,
                        isTodayHighlighted: false,
                      ),

                      calendarBuilders: CalendarBuilders(
                        defaultBuilder:
                            (context, day, focusedDay) {
                          final selectable =
                          _isSelectable(day);

                          return Center(
                            child: Text(
                              "${day.day}",
                              style: TextStyle(
                                fontSize: 16,
                                color: selectable
                                    ? Colors.black
                                    : const Color(
                                    0xFFD0D3DA),
                              ),
                            ),
                          );
                        },

                        outsideBuilder:
                            (context, day, focusedDay) {
                          return Center(
                            child: Text(
                              "${day.day}",
                              style: const TextStyle(
                                fontSize: 16,
                                color: Color(
                                  0xFFD0D3DA,
                                ),
                              ),
                            ),
                          );
                        },

                        selectedBuilder:
                            (context, day, focusedDay) {
                          return Center(
                            child: Container(
                              width: 44,
                              height: 44,
                              decoration:
                              BoxDecoration(
                                color:
                                const Color(
                                  0xFF1687F8,
                                ),
                                borderRadius:
                                BorderRadius
                                    .circular(
                                  12,
                                ),
                              ),
                              alignment:
                              Alignment.center,
                              child: Text(
                                "${day.day}",
                                style:
                                const TextStyle(
                                  color:
                                  Colors.white,
                                  fontSize: 16,
                                  fontWeight:
                                  FontWeight
                                      .bold,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),

                    const SizedBox(height: 28),

                    InkWell(
                      onTap: _selectedDays.isEmpty
                          ? () {
                        setState(() {
                          noClosedDay = !noClosedDay;

                          if (noClosedDay) {
                            _selectedDays.clear();
                          }
                        });
                      }
                          : null,
                      child: Row(
                        children: [
                          Checkbox(
                            value: noClosedDay,
                            activeColor: const Color(0xFF0084FF), // 체크 시 배경색
                            checkColor: Colors.white,             // 체크 아이콘 색상
                            onChanged: _selectedDays.isEmpty
                                ? (v) {
                              setState(() {
                                noClosedDay = v ?? false;

                                if (noClosedDay) {
                                  _selectedDays.clear();
                                }
                              });
                            }
                                : null,
                          ),
                          Text(
                            "매장 휴일이 없어요",
                            style: TextStyle(
                              fontSize: 15,
                              color: _selectedDays.isEmpty
                                  ? Colors.black
                                  : Colors.grey,
                              fontWeight: noClosedDay
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                            ),
                          ),
                        ],
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
          padding: const EdgeInsets.all(20),
          child: SizedBox(
            height: 56,
            child: ElevatedButton(
              onPressed: _canProceed
                  ? () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => RDayOffLimitPage(
                      workPlaceId: widget.workPlaceId,
                      openTime: widget.openTime,
                      closeTime: widget.closeTime,
                      minWork: widget.minWork,
                      maxWork: widget.maxWork,
                      registeredSchedules: widget.registeredSchedules,
                      closedDays: noClosedDay ? {} : _selectedDays,
                      noClosedDay: noClosedDay,
                    ),
                  ),
                );
              }
                  : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: _canProceed
                    ? const Color(0xFF0084FF)
                    : const Color(0xFFA9D0FB), // 비활성화 색상
                disabledBackgroundColor: const Color(0xFFA9D0FB),
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                "다음",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}