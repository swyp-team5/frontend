import 'package:chack_chack/employer/home/schedule/widgets/RCompleteMakingSchedule.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:table_calendar/table_calendar.dart';

import 'RMakingSchedulePage.dart'; // RegisteredSchedule
import 'api/ScheduleApiService.dart';
import 'models/ScheduleCondition.dart';

class RDayOffLimitPage extends StatefulWidget {
  final int workPlaceId;
  final TimeOfDay openTime;
  final TimeOfDay closeTime;
  final int minWork;
  final int maxWork;
  final List<RegisteredSchedule> registeredSchedules;
  final Set<DateTime> closedDays;
  final bool noClosedDay;

  const RDayOffLimitPage({
    super.key,
    required this.workPlaceId,
    required this.openTime,
    required this.closeTime,
    required this.minWork,
    required this.maxWork,
    required this.registeredSchedules,
    required this.closedDays,
    required this.noClosedDay,
  });

  @override
  State<RDayOffLimitPage> createState() => _RDayOffLimitPageState();
}

class _RDayOffLimitPageState extends State<RDayOffLimitPage> {
  late DateTime _focusedDay;

  final Set<DateTime> _selectedDays = {};

  bool noDayoffDay = false;
  bool _isSubmitting = false;

  bool get _canProceed => _selectedDays.isNotEmpty || noDayoffDay;

  // --- 요일 매핑 상수 ---
  static const _dayNameMap = {
    "월": "MONDAY", "화": "TUESDAY", "수": "WEDNESDAY", "목": "THURSDAY",
    "금": "FRIDAY", "토": "SATURDAY", "일": "SUNDAY",
  };
  static const _weekdayIndexToKor = ["월", "화", "수", "목", "금", "토", "일"];

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

  // --- 포맷 유틸 ---

  String _fmtTime(TimeOfDay t) =>
      "${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}:00";

  String _fmtDate(DateTime d) =>
      "${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}";

  bool _isClosed(DateTime date) =>
      widget.closedDays.any((e) => _isSame(e, date));

  bool _isLimited(DateTime date) =>
      _selectedDays.any((e) => _isSame(e, date)); // 이 페이지에서 고른 신청 제한일

  // --- 요청 바디 빌드 ---

  List<DayCondition> _buildDayConditions() {
    final List<DayCondition> result = [];

    for (int i = 0; i < 7; i++) {
      final date = _weekStart.add(Duration(days: i));
      final kor = _weekdayIndexToKor[i];
      final dayName = _dayNameMap[kor]!;

      final closed = widget.noClosedDay ? false : _isClosed(date);
      final limited = noDayoffDay ? false : _isLimited(date);

      if (closed) {
        result.add(DayCondition(
          dayName: dayName,
          date: _fmtDate(date),
          groupingId: null,
          workChangeCount: 0,
          holidayStatus: true,
          selectLimitStatus: limited,
          timeDetails: [],
        ));
        continue;
      }

      // 해당 요일이 포함된 등록 스케줄 찾기
      final scheduleIndex = widget.registeredSchedules.indexWhere(
            (s) => s.days.contains(kor),
      );

      if (scheduleIndex == -1) {
        // 등록된 스케줄이 없는 요일 -> 휴무 처리 (필요에 맞게 조정)
        result.add(DayCondition(
          dayName: dayName,
          date: _fmtDate(date),
          groupingId: null,
          workChangeCount: 0,
          holidayStatus: true,
          selectLimitStatus: limited,
          timeDetails: [],
        ));
        continue;
      }

      final schedule = widget.registeredSchedules[scheduleIndex];
      final timeDetails = schedule.shifts.asMap().entries.map((entry) {
        final idx = entry.key;
        final shift = entry.value;
        return TimeDetail(
          workPartNo: idx + 1,
          timeName: shift.name,
          workerCount: shift.requiredWorkers,
          startTime: _fmtTime(shift.startTime),
          closeTime: _fmtTime(shift.endTime),
          restTime: int.tryParse(
            shift.breakTime.replaceAll(RegExp(r'[^0-9]'), ''),
          ) ??
              0,
        );
      }).toList();

      result.add(DayCondition(
        dayName: dayName,
        date: _fmtDate(date),
        groupingId: scheduleIndex + 1,
        workChangeCount: timeDetails.length - 1,
        holidayStatus: false,
        selectLimitStatus: limited,
        timeDetails: timeDetails,
      ));
    }

    return result;
  }

  Future<void> _onSubmit() async {
    if (_isSubmitting) return;

    setState(() => _isSubmitting = true);

    try {
      final request = ScheduleConditionRequest(
        workPlaceOpenTime: _fmtTime(widget.openTime),
        workPlaceCloseTime: _fmtTime(widget.closeTime),
        minPersonalWorkCount: widget.minWork,
        maxPersonalWorkCount: widget.maxWork,
        dueDate: _fmtDate(_weekEnd), // TODO: 실제 마감일 입력값으로 교체
        days: _buildDayConditions(),
      );

      final response = await ScheduleApiService.postScheduleConditions(
        workPlaceId: widget.workPlaceId,
        body: request,
      );

      // ===== 연동 성공 로그 =====
      debugPrint("========== 스케줄 등록 성공 ==========");
      debugPrint("weekScheduleId = ${response.weekScheduleId}");
      debugPrint("workPlaceId    = ${response.workPlaceId}");
      debugPrint("weekScheduleName = ${response.weekScheduleName}");
      debugPrint("dueDate        = ${response.dueDate}");
      debugPrint("status         = ${response.status}");
      debugPrint("createdAt      = ${response.createdAt}");
      debugPrint("updatedAt      = ${response.updatedAt}");
      debugPrint("=====================================");

      // 홈 화면 등에서 재사용할 수 있도록 활성 weekScheduleId 저장
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt("activeWeekScheduleId", response.weekScheduleId);

      debugPrint("💾 activeWeekScheduleId 저장 완료: ${response.weekScheduleId}");

      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => const RCompleteMakingSchedule(),
        ),
      );
    } catch (e) {
      debugPrint("========== 스케줄 등록 실패 ==========");
      debugPrint(e.toString());
      debugPrint("=====================================");

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("스케줄 등록에 실패했어요: $e")),
      );
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
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
                    "휴무 신청 제한 날짜",
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

                      onDaySelected: (selectedDay, focusedDay) {
                        if (noDayoffDay) return;

                        if (!_isSelectable(selectedDay)) {
                          return;
                        }

                        setState(() {
                          if (_isSelected(selectedDay)) {
                            _selectedDays.removeWhere(
                                  (e) => _isSame(e, selectedDay),
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
                          noDayoffDay = !noDayoffDay;
                        });
                      }
                          : null,
                      child: Row(
                        children: [
                          Checkbox(
                            value: noDayoffDay,
                            activeColor: const Color(0xFF0084FF),
                            checkColor: Colors.white,
                            onChanged: _selectedDays.isEmpty
                                ? (v) {
                              setState(() {
                                noDayoffDay = v ?? false;
                              });
                            }
                                : null,
                          ),
                          Text(
                            "다음 주는 휴무 신청 제한이 없어요",
                            style: TextStyle(
                              fontSize: 15,
                              color: _selectedDays.isEmpty
                                  ? Colors.black
                                  : Colors.grey,
                              fontWeight: noDayoffDay
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
              onPressed: (_canProceed && !_isSubmitting) ? _onSubmit : null,
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
        ),
      ),
    );
  }
}