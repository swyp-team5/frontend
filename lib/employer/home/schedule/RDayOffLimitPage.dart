import 'dart:convert';

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

  // --- 에러코드 -> 안내 메시지 매핑 ---
  // (백엔드 에러 코드 표 기준. 서버가 message를 함께 내려주면 그 값을 우선 사용하고,
  //  message가 비어있는 경우에만 아래 매핑으로 대체합니다.)
  static const Map<String, String> _errorCodeMessages = {
    // UNAUTHORIZED (4002)
    "4002": "인증 정보가 올바르지 않습니다.",
    "UNAUTHORIZED": "인증 정보가 올바르지 않습니다.",

    // RESOURCE_NOT_FOUND (4004)
    "4004": "사업장을 찾을 수 없습니다.",
    "RESOURCE_NOT_FOUND": "사업장을 찾을 수 없습니다.",

    // FORBIDDEN (4003)
    "4003": "권한이 없습니다.",
    "FORBIDDEN": "권한이 없습니다.",

    // CONFLICT (4005)
    "4005": "다음 주차 스케줄 조건이 이미 존재합니다.",
    "CONFLICT": "다음 주차 스케줄 조건이 이미 존재합니다.",

    // VALIDATION_FAILED (4000) - 세부 사유가 다양하므로 서버 message를 우선 사용하고,
    // message가 없을 때만 아래 기본 문구로 대체합니다.
    "4000": "입력한 스케줄 조건을 다시 확인해주세요.",
    "VALIDATION_FAILED": "입력한 스케줄 조건을 다시 확인해주세요.",
  };

  static const String _fallbackErrorMessage =
      "스케줄 등록에 실패했어요. 잠시 후 다시 시도해주세요.";

  // --- 에러 메시지 표(1~24번) 화이트리스트 ---
  // 서버가 던지는 예외 메시지가 아래 목록 중 하나를 "포함"하고 있을 때만
  // 그 문구를 그대로 신뢰해서 보여준다. (표에 없는 임의의 텍스트, 스택트레이스,
  // 500 에러 본문 등이 그대로 노출되는 것을 막기 위한 안전장치)
  static const List<String> _knownErrorMessages = [
    // 1
    "인증 정보가 올바르지 않습니다.",
    // 2
    "사업장을 찾을 수 없습니다.",
    // 3
    "권한이 없습니다.",
    // 4
    "스케줄 조건은 7일(월~일)을 모두 포함해야 합니다.",
    // 5
    "가게 오픈 시간은 마감 시간보다 빨라야 합니다.",
    // 6
    "최소 근무 횟수는 최대 근무 횟수보다 클 수 없습니다.",
    // 7
    "매장 휴일에는 근무 상세 시간을 입력할 수 없습니다.",
    // 8
    "그룹이 없는 날(휴일)에는 타임 상세 정보를 입력할 수 없습니다.",
    // 9
    "근무 교대 횟수와 타임별 상세 정보 개수가 일치하지 않습니다.",
    // 10
    "같은 요일 안에서 근무 파트 번호는 중복될 수 없습니다.",
    // 11
    "근무 시작 시간은 종료 시간보다 빨라야 합니다.",
    // 12
    "근무 시간은 가게 운영 시간 안에 있어야 합니다.",
    // 13 (겹치는 시간대는 메시지 뒤에 "(시작~종료 / 시작~종료)"가 붙으므로 접두 문구만 매칭)
    "교대 시간이 겹칩니다.",
    // 14 (뒤에 날짜 범위가 붙으므로 접두 문구만 매칭)
    "날짜는 다음 주",
    // 15
    "dayName과 실제 날짜의 요일이 일치하지 않습니다.",
    // 16
    "동일한 날짜가 중복될 수 없습니다.",
    // 17
    "같은 그룹 안에 동일한 요일이 중복될 수 없습니다.",
    // 18
    "같은 그룹 내 모든 요일의 workChangeCount가 동일해야 합니다.",
    // 19
    "같은 그룹 내 모든 요일의 타임 개수가 동일해야 합니다.",
    // 20
    "같은 그룹 내 모든 요일의 타임 상세 조건(파트번호, 시작/종료 시간, 필요 인원, 휴게 시간)이 동일해야 합니다.",
    // 21
    "제출 마감일은 오늘 이상이어야 합니다.",
    // 22
    "제출 마감일은 다음 주 시작 전까지만 설정할 수 있습니다.",
    // 23
    "다음 주차 스케줄 조건이 이미 존재합니다.",
    // 24
    "이미 생성된 다음 주 스케줄 조건이 있습니다.",
  ];

  /// 추출된 텍스트가 표(1~24번)에 있는 알려진 메시지 중 하나를 포함하는지 확인.
  /// 13번/14번처럼 뒤에 가변적인 값(시간대, 날짜 범위)이 붙는 메시지는
  /// 접두 문구만 대조한다.
  String? _matchKnownMessage(String text) {
    for (final known in _knownErrorMessages) {
      if (text.contains(known)) {
        return text; // 원문 그대로 반환 (13/14번은 가변 값까지 포함해서 보여줌)
      }
    }
    return null;
  }

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

  /// 이번 주 월요일 (한국 시간 기준)
  DateTime get _thisMonday {
    final now = _koreaNow;
    return DateTime(now.year, now.month, now.day)
        .subtract(Duration(days: now.weekday - 1));
  }

  /// 이번 주 일요일 = 마감일
  DateTime get _dueDate => _thisMonday.add(const Duration(days: 6));

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

  /// "없음", "30분", "1시간", "1시간 30분" 형태의 문자열을
  /// 분(minute) 단위 정수로 정확히 변환한다.
  int _parseBreakTimeToMinutes(String breakTime) {
    if (breakTime == "없음" || breakTime.trim().isEmpty) return 0;

    int hours = 0;
    int minutes = 0;

    final hourMatch = RegExp(r'(\d+)\s*시간').firstMatch(breakTime);
    if (hourMatch != null) {
      hours = int.parse(hourMatch.group(1)!);
    }

    final minuteMatch = RegExp(r'(\d+)\s*분').firstMatch(breakTime);
    if (minuteMatch != null) {
      minutes = int.parse(minuteMatch.group(1)!);
    }

    return hours * 60 + minutes;
  }

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
          restTime: _parseBreakTimeToMinutes(shift.breakTime),   // ← 여기만 교체됨
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

  /// 서버(또는 클라이언트)에서 던진 에러 객체에서 에러코드/메시지를 최대한 추출한다.
  ///
  /// 프로젝트의 실제 예외 클래스(ApiException 등)가 code/message 필드를 갖고 있다면
  /// 그 값을 그대로 사용하고, 그렇지 않은 일반 Exception이라면 toString() 결과에서
  /// "code": "...", "message": "..." 형태를 정규식으로 추출을 시도한다.
  ///
  /// ⚠️ 프로젝트의 실제 API 예외 클래스 형태(필드명 등)가 다르다면 이 부분만
  /// 해당 클래스에 맞게 수정해주세요.
  ({String? code, String? message}) _parseApiError(Object error) {
    // 1) 커스텀 예외 객체가 code/message 필드를 갖고 있는 경우
    try {
      final dynamic err = error;
      final String? code = err.code?.toString();
      final String? message = err.message?.toString();

      if (code != null || message != null) {
        return (code: code, message: message);
      }
    } catch (_) {
      // code/message 필드가 없는 타입이면 무시하고 다음 방식 시도
    }

    // 2) toString() 결과에서 JSON 형태의 code/message를 정규식으로 추출
    final raw = error.toString();

    final codeMatch = RegExp(
      r'"?(?:code|errorCode)"?\s*[:=]\s*"?([A-Z_0-9]+)"?',
    ).firstMatch(raw);

    final messageMatch = RegExp(
      r'"?message"?\s*[:=]\s*"([^"]+)"',
    ).firstMatch(raw);

    if (codeMatch != null || messageMatch != null) {
      return (
      code: codeMatch?.group(1),
      message: messageMatch?.group(1),
      );
    }

    // 3) ScheduleApiService가 `throw Exception('근무 시간은 가게 운영 시간 안에 있어야 합니다.')`
    // 처럼 서버 message를 그대로 담아 일반 Exception으로 던지는 경우.
    // 이때 error.toString()은 "Exception: 근무 시간은 가게 운영 시간 안에 있어야 합니다." 형태이므로
    // 앞의 "Exception: " / "Error: " 접두어만 제거해서 메시지로 사용한다.
    final stripped =
    raw.replaceFirst(RegExp(r'^(Exception|Error):\s*'), '').trim();

    if (stripped.isNotEmpty && stripped != raw) {
      return (code: null, message: stripped);
    }

    return (code: null, message: null);
  }

  /// 에러코드/서버메시지를 사용자에게 보여줄 최종 메시지로 변환.
  /// 서버 message가 있으면 그것을 우선 사용하고, 없으면 코드 기반 매핑을 사용한다.
  String _resolveErrorMessage(Object error) {
    final parsed = _parseApiError(error);

    // 1) 추출된 서버 메시지가 표(1~24번)의 알려진 문구 중 하나를 포함하면
    //    그 원문(가변 값 포함)을 그대로 사용한다.
    if (parsed.message != null && parsed.message!.trim().isNotEmpty) {
      final matched = _matchKnownMessage(parsed.message!.trim());
      if (matched != null) {
        return matched;
      }
    }

    // 2) 표에 없는 텍스트라면, 에러 코드 기반 매핑으로 대체한다.
    final code = parsed.code;
    if (code != null && _errorCodeMessages.containsKey(code)) {
      return _errorCodeMessages[code]!;
    }

    // 3) 코드도 알 수 없다면 최종 fallback 문구를 사용한다.
    return _fallbackErrorMessage;
  }

  /// 요일 하나라도 "휴무일"도 아니고 "등록된 근무 스케줄"도 없는 경우를 찾아낸다.
  ///
  /// ⚠️ 버그 수정 배경:
  /// 기존 _buildDayConditions()는 등록된 스케줄이 없는 요일을 발견하면
  /// noClosedDay(휴무일 없음) 체크 여부와 무관하게 무조건 holidayStatus: true로
  /// 처리해서 서버로 보내고 있었다. 그 결과 "휴무일 없음"을 체크한 상태에서
  /// 특정 요일(예: 월요일) 스케줄 등록을 깜빡해도 서버가 정상 응답을 줘버려서,
  /// 사용자가 기대한 "근무 계획이 빠졌다"는 경고가 뜨지 않는 문제가 있었다.
  ///
  /// 그래서 제출 전에 클라이언트에서 먼저: 휴무일이 아닌 요일인데
  /// registeredSchedules 중 그 요일을 포함하는 스케줄이 하나도 없다면
  /// 에러 메시지를 반환해서 제출을 막는다.
  String? _validateAllDaysCovered() {
    for (int i = 0; i < 7; i++) {
      final date = _weekStart.add(Duration(days: i));
      final kor = _weekdayIndexToKor[i];

      final closed = widget.noClosedDay ? false : _isClosed(date);
      if (closed) continue; // 휴무일로 지정된 요일은 스케줄이 없어도 정상

      final hasSchedule =
      widget.registeredSchedules.any((s) => s.days.contains(kor));

      if (!hasSchedule) {
        return "$kor요일에 등록된 근무 스케줄이 없어요. "
            "근무 스케줄을 등록하거나 매장 휴무일로 지정해주세요.";
      }
    }

    return null; // 모든 요일이 휴무이거나 스케줄로 커버됨
  }

  Future<void> _onSubmit() async {
    if (_isSubmitting) return;

    // 서버로 보내기 전, 요일 커버리지부터 먼저 검증한다.
    final coverageError = _validateAllDaysCovered();
    if (coverageError != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(coverageError)),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final request = ScheduleConditionRequest(
        workPlaceOpenTime: _fmtTime(widget.openTime),
        workPlaceCloseTime: _fmtTime(widget.closeTime),
        minPersonalWorkCount: widget.minWork,
        maxPersonalWorkCount: widget.maxWork,
        dueDate: _fmtDate(_dueDate), // 금주 일요일
        days: _buildDayConditions(),
      );

      debugPrint("📤 실제 전송 body: ${jsonEncode(request.toJson())}");

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

      final message = _resolveErrorMessage(e);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
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