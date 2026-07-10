import 'package:chack_chack/employee/crews/widgets/ApplicationCalendar.dart';
import 'package:chack_chack/employee/crews/widgets/ApplicationForm.dart';
import 'package:chack_chack/employee/crews/widgets/ApplicationFormHeader.dart';
import 'package:chack_chack/employee/crews/widgets/ApplicationSubmitSheets.dart';
import 'package:chack_chack/employee/crews/widgets/ApplicationTabData.dart';
import 'package:chack_chack/employee/crews/widgets/ExchangeSubstituteTabBar.dart';
import 'package:chack_chack/employee/crews/widgets/MenuTile.dart';
import 'package:chack_chack/employee/crews/widgets/MockWorkerSchedules.dart';
import 'package:chack_chack/employee/crews/widgets/ReasonBottomSheet.dart';
import 'package:chack_chack/employee/crews/widgets/WorkerConfirmStep.dart';
import 'package:chack_chack/employee/crews/widgets/WorkerSelect.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'api/ScheduleApi.dart';
import 'model/ConfirmedSchedule.dart';
import 'model/MyWorkSchedule.dart';

class EApplicationFormPage extends StatefulWidget {
  /// 캘린더 활성화 정보 조회를 위한 근무지 ID
  final int workPlaceId;

  const EApplicationFormPage({super.key, required this.workPlaceId});

  @override
  State<EApplicationFormPage> createState() => _EApplicationFormPageState();
}

class _EApplicationFormPageState extends State<EApplicationFormPage> {
  /// false = 교대, true = 대타
  bool isSubstitute = false;

  late DateTime _focusedMonth;

  /// false = 신청서, true = 근무자 선택 화면
  bool showWorkerSelect = false;
  bool _workerMode = false;
  bool showWorkerInfo = false;

  /// 교대/대타 탭별 신청 데이터. 예전엔 필드가 탭마다 5개씩 두 벌 있었지만
  /// ApplicationTabData로 묶어서 인스턴스만 두 개 든다.
  final _exchangeData = ApplicationTabData();
  final _substituteData = ApplicationTabData();

  ApplicationTabData get _current =>
      isSubstitute ? _substituteData : _exchangeData;

  bool get canSubmit =>
      _current.canSubmit(requireWorkerDate: !isSubstitute);

  /// =========================
  /// GET /api/me/confirmed-schedules 연동
  /// =========================
  List<ConfirmedSchedule> _confirmedSchedules = [];
  bool _isLoadingSchedules = false;
  String? _scheduleError;

  /// 화면(캘린더/신청서)에서 쓰던 "내 근무" 데이터 형태로 변환
  List<MyWorkSchedule> get mySchedules => _confirmedSchedules
      .where((s) => s.workPlaceId == widget.workPlaceId)
      .map(
        (s) => MyWorkSchedule(
      name: "나",
      date: s.workDate,
      role: s.timeName,
      startTime: s.startTimeShort,
      endTime: s.closeTimeShort,
    ),
  )
      .toList();

  Future<void> _fetchConfirmedSchedules() async {
    setState(() {
      _isLoadingSchedules = true;
      _scheduleError = null;
    });

    // 지난 확정 근무 + 이번 달 진행 중 일정 + 다음 주(월이 넘어가는 경우 포함)
    // 확정 일정까지 한 번에 커버할 수 있도록 넉넉하게 범위를 잡는다.
    final from = DateTime(_focusedMonth.year, _focusedMonth.month - 1, 1);
    final to = DateTime(_focusedMonth.year, _focusedMonth.month + 2, 0);

    try {
      final response =
      await ScheduleApi.fetchConfirmedSchedules(from: from, to: to);

      if (!mounted) return;
      setState(() {
        _confirmedSchedules = response.schedules;
        _isLoadingSchedules = false;
      });
    } catch (e) {
      if (!mounted) return;
      // TODO: 원인 파악되면 kDebugMode 분기 지우고 사용자 문구만 남기기
      setState(() {
        _scheduleError = kDebugMode
            ? "근무 일정을 불러오지 못했습니다.\n[$e]"
            : "근무 일정을 불러오지 못했습니다.\n다시 시도해주세요.";
        _isLoadingSchedules = false;
      });
    }
  }

  DateTime getNextMonday() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final thisMonday = today.subtract(Duration(days: today.weekday - 1));
    return thisMonday.add(const Duration(days: 7));
  }

  @override
  void initState() {
    super.initState();

    final mondayNextWeek = getNextMonday();
    _focusedMonth = DateTime(mondayNextWeek.year, mondayNextWeek.month);

    _fetchConfirmedSchedules();
  }

  List<DateTime> get nextWeek {
    final monday = getNextMonday();
    return List.generate(7, (i) => monday.add(Duration(days: i)));
  }

  bool _sameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  bool isSelectable(DateTime day) {
    // 근무자 확정 이후에는 아무 날짜도 선택 불가
    if (_current.workerConfirmed) return false;

    // 처음 (내 근무 선택)
    if (!_workerMode) {
      if (!isNextWeek(day)) return false;
      return isMyWorkDay(day);
    }

    // 근무자 선택 단계
    if (_current.selectedWorker == null) return false;
    return isSelectedWorkerWorkDay(day);
  }

  bool isMyWorkDay(DateTime day) =>
      mySchedules.any((s) => _sameDay(s.date, day));

  bool isNextWeek(DateTime day) => nextWeek.any((d) => _sameDay(d, day));

  MyWorkSchedule? getSelectedSchedule() {
    final date = _current.selectedDate;
    if (date == null) return null;
    try {
      return mySchedules.firstWhere((s) => _sameDay(s.date, date));
    } catch (_) {
      return null;
    }
  }

  List<DateTime> buildCalendarDays() {
    final firstDay = DateTime(_focusedMonth.year, _focusedMonth.month, 1);
    final lastDay = DateTime(_focusedMonth.year, _focusedMonth.month + 1, 0);
    final startOffset = firstDay.weekday % 7;
    final prevMonthLast = DateTime(_focusedMonth.year, _focusedMonth.month, 0);

    final dates = <DateTime>[];
    for (int i = 0; i < 42; i++) {
      final day = i - startOffset + 1;
      if (day <= 0) {
        dates.add(DateTime(
          _focusedMonth.year,
          _focusedMonth.month - 1,
          prevMonthLast.day + day,
        ));
      } else if (day > lastDay.day) {
        dates.add(DateTime(
          _focusedMonth.year,
          _focusedMonth.month + 1,
          day - lastDay.day,
        ));
      } else {
        dates.add(DateTime(_focusedMonth.year, _focusedMonth.month, day));
      }
    }
    return dates;
  }

  // TODO: MockWorkerSchedules는 "근무지 근무자 일정 조회" API 연동 전까지의 임시 데이터.

  List<MyWorkSchedule> getWorkersForSelectedDate() {
    final date = _current.selectedDate;
    if (date == null) return [];
    return MockWorkerSchedules.all.where((s) => _sameDay(s.date, date)).toList();
  }

  bool isSelectedWorkerWorkDay(DateTime day) {
    final worker = _current.selectedWorker;
    if (worker == null) return false;
    return MockWorkerSchedules.all
        .any((s) => s.name == worker && _sameDay(s.date, day));
  }

  MyWorkSchedule? getSelectedWorkerSchedule() {
    final worker = _current.selectedWorker;
    final date = _current.selectedWorkerDate;
    if (worker == null || date == null) return null;
    try {
      return MockWorkerSchedules.all
          .firstWhere((s) => s.name == worker && _sameDay(s.date, date));
    } catch (_) {
      return null;
    }
  }

  MyWorkSchedule? getSelectedSubstituteWorkerSchedule() {
    final worker = _current.selectedWorker;
    final date = _current.selectedDate;
    if (worker == null || date == null) return null;
    try {
      return MockWorkerSchedules.all
          .firstWhere((s) => s.name == worker && _sameDay(s.date, date));
    } catch (_) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final days = buildCalendarDays();
    final selectedSchedule = getSelectedSchedule();
    final selectedWorkerSchedule = getSelectedWorkerSchedule();

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const ApplicationFormHeader(),
                  const SizedBox(height: 28),
                  if (_isLoadingSchedules)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 60),
                      child: Center(child: CircularProgressIndicator()),
                    )
                  else if (_scheduleError != null)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 40),
                      child: Column(
                        children: [
                          Text(
                            _scheduleError!,
                            textAlign: TextAlign.center,
                            style: const TextStyle(color: Colors.red),
                          ),
                          const SizedBox(height: 12),
                          TextButton(
                            onPressed: _fetchConfirmedSchedules,
                            child: const Text("다시 시도"),
                          ),
                        ],
                      ),
                    )
                  else
                    ApplicationCalendar(
                      isSubstitute: isSubstitute,
                      workPlaceId: widget.workPlaceId,
                      focusedMonth: _focusedMonth,
                      days: days,
                      selectedDate: _current.selectedDate,
                      selectedWorkerDate: _current.selectedWorkerDate,
                      workerMode: _workerMode,
                      showWorkerSelect: showWorkerSelect,
                      isMyWorkDay: isMyWorkDay,
                      isSelectedWorkerWorkDay: isSelectedWorkerWorkDay,
                      isSelectable: isSelectable,
                      isNextWeek: isNextWeek,
                      onPrevMonth: () {
                        setState(() {
                          _focusedMonth = DateTime(
                              _focusedMonth.year, _focusedMonth.month - 1);
                        });
                        _fetchConfirmedSchedules();
                      },
                      onNextMonth: () {
                        setState(() {
                          _focusedMonth = DateTime(
                              _focusedMonth.year, _focusedMonth.month + 1);
                        });
                        _fetchConfirmedSchedules();
                      },
                      onSelectDay: (day) {
                        setState(() {
                          if (_workerMode) {
                            _current.selectedWorkerDate = day;
                          } else {
                            _current.selectedDate = day;
                          }
                        });
                      },
                    ),
                ],
              ),
            ),
            ExchangeSubstituteTabBar(
              isSubstitute: isSubstitute,
              onChanged: (value) => setState(() => isSubstitute = value),
            ),
            Expanded(
              child: showWorkerSelect
                  ? WorkerSelect(
                workers: MockWorkerSchedules.workerNames,
                selectedWorker: _current.selectedWorker,
                onWorkerSelected: (worker) {
                  setState(() => _current.selectedWorker = worker);
                },
                onConfirm: () {
                  setState(() {
                    showWorkerSelect = false;
                    if (isSubstitute) {
                      // 대타는 이름만 확정하고 바로 신청서로
                      _current.workerConfirmed = true;
                      showWorkerInfo = false;
                    } else {
                      // 교대는 기존처럼 근무정보 확인
                      showWorkerInfo = true;
                    }
                  });
                },
              )
                  : showWorkerInfo
                  ? WorkerConfirmStep(
                workerName: _current.selectedWorker,
                schedule: getSelectedWorkerSchedule(),
                onConfirm: () {
                  setState(() {
                    showWorkerInfo = false;
                    _current.workerConfirmed = true;
                  });
                },
              )
                  : ApplicationForm(
                isSubstitute: isSubstitute,
                scheduleTile: MenuTile(
                  title: isSubstitute ? "대타 신청 날짜" : "교대 신청 날짜",
                  trailing: Text(
                    selectedSchedule == null
                        ? "선택 안함"
                        : "${selectedSchedule.date.month}월 "
                        "${selectedSchedule.date.day}일 "
                        "${selectedSchedule.startTime} - ${selectedSchedule.endTime}",
                    textAlign: TextAlign.right,
                    style: TextStyle(
                      color: selectedSchedule == null
                          ? const Color(0xff8F8F8F)
                          : Colors.black,
                      fontSize: 16,
                      fontWeight: selectedSchedule == null
                          ? FontWeight.w400
                          : FontWeight.w500,
                    ),
                  ),
                  onTap: () {},
                ),
                workerTile: MenuTile(
                  title: isSubstitute ? "대타 근무자" : "교대 상대 근무자",
                  trailing: _current.workerConfirmed
                      ? isSubstitute
                  // 대타 : 이름만 표시
                      ? Text(
                    _current.selectedWorker ?? "",
                    style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500),
                  )
                  // 교대 : 이름 + 근무정보 표시
                      : selectedWorkerSchedule != null
                      ? Column(
                    mainAxisAlignment:
                    MainAxisAlignment.center,
                    crossAxisAlignment:
                    CrossAxisAlignment.end,
                    children: [
                      Text(
                        selectedWorkerSchedule.name,
                        style: const TextStyle(
                            fontSize: 16,
                            fontWeight:
                            FontWeight.w500),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "${selectedWorkerSchedule.date.month}월 "
                            "${selectedWorkerSchedule.date.day}일 "
                            "${selectedWorkerSchedule.startTime} - "
                            "${selectedWorkerSchedule.endTime}",
                        style: const TextStyle(
                            fontSize: 13,
                            color: Color(0xff8F8F8F)),
                      ),
                    ],
                  )
                      : const Text("선택 안함",
                      style: TextStyle(
                          color: Color(0xff8F8F8F),
                          fontSize: 16))
                      : const Text("선택 안함",
                      style: TextStyle(
                          color: Color(0xff8F8F8F),
                          fontSize: 16)),
                  hasArrow: true,
                  onTap: () {
                    if (_current.selectedDate == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("먼저 날짜를 선택해주세요.")),
                      );
                      return;
                    }
                    if (getWorkersForSelectedDate().isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("해당 날짜에 근무자가 없습니다.")),
                      );
                      return;
                    }
                    setState(() {
                      showWorkerSelect = true;
                      _workerMode = true;
                    });
                  },
                ),
                reasonTile: MenuTile(
                  title: isSubstitute ? "대타 사유" : "교대 사유",
                  trailing: Text(
                    _current.selectedReason == null
                        ? "선택 안함"
                        : _current.selectedReason == "기타" &&
                        (_current.selectedEtc?.isNotEmpty ??
                            false)
                        ? "기타 / ${_current.selectedEtc}"
                        : _current.selectedReason!,
                    textAlign: TextAlign.right,
                    style: TextStyle(
                      color: _current.selectedReason == null
                          ? const Color(0xff8F8F8F)
                          : Colors.black,
                      fontSize: 16,
                      fontWeight: _current.selectedReason == null
                          ? FontWeight.w400
                          : FontWeight.w500,
                    ),
                  ),
                  hasArrow: true,
                  onTap: () async {
                    final result =
                    await showModalBottomSheet<Map<String, String?>>(
                      context: context,
                      isScrollControlled: true,
                      backgroundColor: Colors.transparent,
                      builder: (_) => ReasonBottomSheet(
                        isSubstitute: isSubstitute,
                        initialReason: _current.selectedReason,
                        initialEtc: _current.selectedEtc,
                      ),
                    );
                    if (result != null) {
                      setState(() {
                        _current.selectedReason = result["reason"];
                        _current.selectedEtc = result["etc"];
                      });
                    }
                  },
                ),
                onSubmit: canSubmit ? _handleSubmit : null,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _handleSubmit() {
    final mySchedule = getSelectedSchedule();
    if (mySchedule == null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text("내 근무를 선택해주세요.")));
      return;
    }

    final reason = _current.selectedReason == "기타"
        ? "기타 / ${_current.selectedEtc}"
        : _current.selectedReason!;

    if (isSubstitute) {
      final workerName = _current.selectedWorker;
      if (workerName == null) {
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text("대타 근무자를 선택해주세요.")));
        return;
      }

      ApplicationSubmitSheets.showSubstituteConfirm(
        context: context,
        mySchedule: mySchedule,
        workerName: workerName,
        reason: reason,
        onConfirm: () {
          Navigator.pop(context);
          // TODO : 대타 신청 API
        },
      );
    } else {
      final workerSchedule = getSelectedWorkerSchedule();
      if (workerSchedule == null) {
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text("교대 근무를 선택해주세요.")));
        return;
      }

      ApplicationSubmitSheets.showExchangeConfirm(
        context: context,
        mySchedule: mySchedule,
        workerSchedule: workerSchedule,
        reason: reason,
        onConfirm: () {
          Navigator.pop(context);
          // TODO : 교대 신청 API
        },
      );
    }
  }
}