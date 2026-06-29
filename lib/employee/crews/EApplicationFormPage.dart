import 'package:chack_chack/employee/crews/widgets/ApplicationCalendar.dart';
import 'package:chack_chack/employee/crews/widgets/ApplicationForm.dart';
import 'package:chack_chack/employee/crews/widgets/ExchangeConfirmBottomSheet.dart';
import 'package:chack_chack/employee/crews/widgets/ReasonBottomSheet.dart';
import 'package:chack_chack/employee/crews/widgets/SubstituteConfirmBottomSheet.dart';
import 'package:chack_chack/employee/crews/widgets/WorkerInfoCard.dart';
import 'package:chack_chack/employee/crews/widgets/WorkerSelect.dart';
import 'package:flutter/material.dart';

class MyWorkSchedule {
  final String name;
  final DateTime date;
  final String role;
  final String startTime;
  final String endTime;

  const MyWorkSchedule({
    required this.name,
    required this.date,
    required this.role,
    required this.startTime,
    required this.endTime,
  });
}

class EApplicationFormPage extends StatefulWidget {
  const EApplicationFormPage({super.key});

  @override
  State<EApplicationFormPage> createState() => _EApplicationFormPageState();
}

class _EApplicationFormPageState extends State<EApplicationFormPage> {

  /// false = 교대
  /// true = 대타
  bool isSubstitute = false;

  late DateTime _focusedMonth;

  /// false = 신청서
  /// true = 근무자 선택 화면
  bool showWorkerSelect = false;

  bool _workerMode = false;

  bool _exchangeWorkerConfirmed = false;
  bool _substituteWorkerConfirmed = false;

  bool showWorkerInfo = false;

  /// =========================
  /// 교대 신청 데이터
  /// =========================
  DateTime? _exchangeSelectedDate;
  DateTime? _exchangeSelectedWorkerDate;
  String? _exchangeSelectedWorker;
  String? _exchangeSelectedReason;
  String? _exchangeSelectedEtc;

  /// =========================
  /// 대타 신청 데이터
  /// =========================
  DateTime? _substituteSelectedDate;
  DateTime? _substituteSelectedWorkerDate;
  String? _substituteSelectedWorker;
  String? _substituteSelectedReason;
  String? _substituteSelectedEtc;

  // =========================
// 현재 탭에서 사용할 데이터
// =========================

  DateTime? get _selectedDate =>
      isSubstitute ? _substituteSelectedDate : _exchangeSelectedDate;

  set _selectedDate(DateTime? value) {
    if (isSubstitute) {
      _substituteSelectedDate = value;
    } else {
      _exchangeSelectedDate = value;
    }
  }

  DateTime? get _selectedWorkerDate =>
      isSubstitute ? _substituteSelectedWorkerDate : _exchangeSelectedWorkerDate;

  set _selectedWorkerDate(DateTime? value) {
    if (isSubstitute) {
      _substituteSelectedWorkerDate = value;
    } else {
      _exchangeSelectedWorkerDate = value;
    }
  }

  String? get _selectedWorker =>
      isSubstitute ? _substituteSelectedWorker : _exchangeSelectedWorker;

  set _selectedWorker(String? value) {
    if (isSubstitute) {
      _substituteSelectedWorker = value;
    } else {
      _exchangeSelectedWorker = value;
    }
  }

  String? get _selectedReason =>
      isSubstitute ? _substituteSelectedReason : _exchangeSelectedReason;

  set _selectedReason(String? value) {
    if (isSubstitute) {
      _substituteSelectedReason = value;
    } else {
      _exchangeSelectedReason = value;
    }
  }

  String? get _selectedEtc =>
      isSubstitute ? _substituteSelectedEtc : _exchangeSelectedEtc;

  set _selectedEtc(String? value) {
    if (isSubstitute) {
      _substituteSelectedEtc = value;
    } else {
      _exchangeSelectedEtc = value;
    }
  }

  bool get canSubmit {

    final selectedDate =
    isSubstitute
        ? _substituteSelectedDate
        : _exchangeSelectedDate;

    final selectedWorker =
    isSubstitute
        ? _substituteSelectedWorker
        : _exchangeSelectedWorker;

    final selectedWorkerDate =
    isSubstitute
        ? _substituteSelectedWorkerDate
        : _exchangeSelectedWorkerDate;

    final selectedReason =
    isSubstitute
        ? _substituteSelectedReason
        : _exchangeSelectedReason;

    final selectedEtc =
    isSubstitute
        ? _substituteSelectedEtc
        : _exchangeSelectedEtc;

    final hasSchedule = selectedDate != null;

    final hasWorker = isSubstitute
        ? (_workerConfirmed && selectedWorker != null)
        : (_workerConfirmed &&
        selectedWorker != null &&
        selectedWorkerDate != null);

    final hasReason = selectedReason != null;

    final hasEtc =
        selectedReason != "기타" ||
            (selectedEtc != null && selectedEtc.trim().isNotEmpty);

    return hasSchedule &&
        hasWorker &&
        hasReason &&
        hasEtc;
  }

  bool get _workerConfirmed =>
      isSubstitute
          ? _substituteWorkerConfirmed
          : _exchangeWorkerConfirmed;

  set _workerConfirmed(bool value) {
    if (isSubstitute) {
      _substituteWorkerConfirmed = value;
    } else {
      _exchangeWorkerConfirmed = value;
    }
  }

  /// 내 근무
  final List<MyWorkSchedule> mySchedules = [
    MyWorkSchedule(
      name: "나",
      date: DateTime(2026, 7, 6),
      role: "오픈",
      startTime: "09:00",
      endTime: "12:00",
    ),
    MyWorkSchedule(
      name: "나",
      date: DateTime(2026, 7, 8),
      role: "미들",
      startTime: "12:00",
      endTime: "16:00",
    ),
    MyWorkSchedule(
      name: "나",
      date: DateTime(2026, 7, 10),
      role: "오픈",
      startTime: "09:00",
      endTime: "12:00",
    ),
  ];

  /// 근무자1
  final List<MyWorkSchedule> worker1Schedules = [
    MyWorkSchedule(
      name: "윤서준",
      date: DateTime(2026, 7, 7),
      role: "미들",
      startTime: "12:00",
      endTime: "16:00",
    ),
    MyWorkSchedule(
      name: "윤서준",
      date: DateTime(2026, 7, 8),
      role: "오픈",
      startTime: "09:00",
      endTime: "12:00",
    ),
    MyWorkSchedule(
      name: "윤서준",
      date: DateTime(2026, 7, 10),
      role: "오픈",
      startTime: "09:00",
      endTime: "12:00",
    ),
  ];

  /// 근무자2
  final List<MyWorkSchedule> worker2Schedules = [
    MyWorkSchedule(
      name: "김유진",
      date: DateTime(2026, 7, 6),
      role: "미들",
      startTime: "12:00",
      endTime: "16:00",
    ),
    MyWorkSchedule(
      name: "김유진",
      date: DateTime(2026, 7, 8),
      role: "오픈",
      startTime: "09:00",
      endTime: "12:00",
    ),
    MyWorkSchedule(
      name: "김유진",
      date: DateTime(2026, 7, 9),
      role: "마감",
      startTime: "16:00",
      endTime: "20:00",
    ),
  ];

  DateTime getNextMonday() {
    final now = DateTime.now();

    final today = DateTime(
      now.year,
      now.month,
      now.day,
    );

    // 이번 주 월요일
    final thisMonday =
    today.subtract(Duration(days: today.weekday - 1));

    // 다음 주 월요일
    return thisMonday.add(const Duration(days: 7));


  }

  @override
  void initState() {
    super.initState();

    final mondayNextWeek = getNextMonday();


    _focusedMonth = DateTime(
      mondayNextWeek.year,
      mondayNextWeek.month,
    );
  }

  List<DateTime> get nextWeek {
    final monday = getNextMonday();

    return List.generate(
      7,
          (i) => monday.add(Duration(days: i)),
    );
  }

  bool isSelectable(DateTime day) {

    // ✅ 근무자 확정 이후에는 아무 날짜도 선택 불가
    if (_workerConfirmed) {
      return false;
    }

    // 처음 (내 근무 선택)
    if (!_workerMode) {
      if (!isNextWeek(day)) return false;
      return isMyWorkDay(day);
    }

    // 근무자 선택 단계
    if (_selectedWorker == null) {
      return false;
    }

    return isSelectedWorkerWorkDay(day);
  }

  bool isMyWorkDay(DateTime day) {
    return mySchedules.any(
          (schedule) =>
      schedule.date.year == day.year &&
          schedule.date.month == day.month &&
          schedule.date.day == day.day,
    );
  }

  bool isNextWeek(DateTime day) {
    return nextWeek.any(
          (d) =>
      d.year == day.year &&
          d.month == day.month &&
          d.day == day.day,
    );
  }

  bool isWorkerSelected() {
    return _selectedWorker != null;
  }

  MyWorkSchedule? getSelectedSchedule() {
    if (_selectedDate == null) return null;

    try {
      return mySchedules.firstWhere(
            (schedule) =>
        schedule.date.year == _selectedDate!.year &&
            schedule.date.month == _selectedDate!.month &&
            schedule.date.day == _selectedDate!.day,
      );
    } catch (_) {
      return null;
    }
  }

  List<DateTime> buildCalendarDays() {

    final firstDay =
    DateTime(_focusedMonth.year, _focusedMonth.month, 1);

    final lastDay =
    DateTime(_focusedMonth.year, _focusedMonth.month + 1, 0);

    final startOffset = firstDay.weekday % 7;

    final prevMonthLast =
    DateTime(_focusedMonth.year, _focusedMonth.month, 0);

    final dates = <DateTime>[];

    for (int i = 0; i < 42; i++) {

      final day = i - startOffset + 1;

      if (day <= 0) {
        dates.add(
          DateTime(
            _focusedMonth.year,
            _focusedMonth.month - 1,
            prevMonthLast.day + day,
          ),
        );
      } else if (day > lastDay.day) {
        dates.add(
          DateTime(
            _focusedMonth.year,
            _focusedMonth.month + 1,
            day - lastDay.day,
          ),
        );
      } else {
        dates.add(
          DateTime(
            _focusedMonth.year,
            _focusedMonth.month,
            day,
          ),
        );
      }
    }

    return dates;
  }

  List<MyWorkSchedule> getWorkersForSelectedDate() {
    if (_selectedDate == null) return [];

    final all = [
      ...worker1Schedules,
      ...worker2Schedules,
    ];

    return all.where((schedule) {
      return schedule.date.year == _selectedDate!.year &&
          schedule.date.month == _selectedDate!.month &&
          schedule.date.day == _selectedDate!.day;
    }).toList();
  }

  bool isSelectedWorkerWorkDay(DateTime day) {
    if (_selectedWorker == null) return false;

    final all = [
      ...worker1Schedules,
      ...worker2Schedules,
    ];

    return all.any(
          (schedule) =>
      schedule.name == _selectedWorker &&
          schedule.date.year == day.year &&
          schedule.date.month == day.month &&
          schedule.date.day == day.day,
    );
  }

  MyWorkSchedule? getSelectedWorkerSchedule() {
    if (_selectedWorker == null || _selectedWorkerDate == null) {
      return null;
    }

    final all = [
      ...worker1Schedules,
      ...worker2Schedules,
    ];

    try {
      return all.firstWhere(
            (schedule) =>
        schedule.name == _selectedWorker &&
            schedule.date.year == _selectedWorkerDate!.year &&
            schedule.date.month == _selectedWorkerDate!.month &&
            schedule.date.day == _selectedWorkerDate!.day,
      );
    } catch (_) {
      return null;
    }
  }

  MyWorkSchedule? getSelectedSubstituteWorkerSchedule() {
    if (_selectedWorker == null || _selectedDate == null) {
      return null;
    }

    final all = [
      ...worker1Schedules,
      ...worker2Schedules,
    ];

    try {
      return all.firstWhere(
            (schedule) =>
        schedule.name == _selectedWorker &&
            schedule.date.year == _selectedDate!.year &&
            schedule.date.month == _selectedDate!.month &&
            schedule.date.day == _selectedDate!.day,
      );
    } catch (_) {
      return null;
    }
  }


  @override
  Widget build(BuildContext context) {
    final days = buildCalendarDays();
    final selectedSchedule = getSelectedSchedule();
    final selectedWorkerSchedule = getSelectedWorkerSchedule();
    final substituteWorkerSchedule = getSelectedSubstituteWorkerSchedule();

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [

            /// =========================
            /// 상단 + 달력 (좌우 30)
            /// =========================
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 30,
                vertical: 20,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  /// 헤더
                  Row(
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: const Icon(
                          Icons.arrow_back_ios_new,
                          size: 22,
                        ),
                      ),
                      const Expanded(
                        child: Center(
                          child: Text(
                            "신청서 작성",
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 22),
                    ],
                  ),

                  const SizedBox(height: 28),

                  ApplicationCalendar(
                    isSubstitute: isSubstitute,

                    focusedMonth: _focusedMonth,
                    days: days,

                    selectedDate: _selectedDate,
                    selectedWorkerDate: _selectedWorkerDate,

                    workerMode: _workerMode,
                    showWorkerSelect: showWorkerSelect,

                    isMyWorkDay: isMyWorkDay,
                    isSelectedWorkerWorkDay: isSelectedWorkerWorkDay,
                    isSelectable: isSelectable,
                    isNextWeek: isNextWeek,

                    onPrevMonth: () {
                      setState(() {
                        _focusedMonth = DateTime(
                          _focusedMonth.year,
                          _focusedMonth.month - 1,
                        );
                      });
                    },

                    onNextMonth: () {
                      setState(() {
                        _focusedMonth = DateTime(
                          _focusedMonth.year,
                          _focusedMonth.month + 1,
                        );
                      });
                    },

                    onSelectDay: (day) {
                      setState(() {
                        if (_workerMode) {
                          _selectedWorkerDate = day;
                        } else {
                          _selectedDate = day;
                        }
                      });
                    },
                  ),
                ],
              ),
            ),

            Row(
              children: [
                Expanded(
                  child: InkWell(
                    onTap: () {
                      setState(() {
                        isSubstitute = false;
                      });
                    },
                    child: Container(
                      height: 52,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        border: Border(
                          bottom: BorderSide(
                            color: !isSubstitute
                                ? Colors.black
                                : const Color(0xffE9E9EE),
                            width: !isSubstitute ? 2 : 1,
                          ),
                        ),
                      ),
                      child: Text(
                        "교대",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: !isSubstitute
                              ? Colors.black
                              : Colors.grey,
                        ),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: InkWell(
                    onTap: () {
                      setState(() {
                        isSubstitute = true;
                      });
                    },
                    child: Container(
                      height: 52,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        border: Border(
                          bottom: BorderSide(
                            color: isSubstitute
                                ? Colors.black
                                : const Color(0xffE9E9EE),
                            width: isSubstitute ? 2 : 1,
                          ),
                        ),
                      ),
                      child: Text(
                        "대타",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: isSubstitute
                              ? Colors.black
                              : Colors.grey,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),

            Expanded(
              child: showWorkerSelect
                  ? WorkerSelect(
                workers: const ["윤서준", "김유진"],
                selectedWorker: _selectedWorker,

                onWorkerSelected: (worker) {
                  setState(() {
                    _selectedWorker = worker;
                  });
                },

                onConfirm: () {
                  setState(() {
                    showWorkerSelect = false;

                    if (isSubstitute) {
                      // 대타는 이름만 확정하고 바로 신청서로
                      _workerConfirmed = true;
                      showWorkerInfo = false;
                    } else {
                      // 교대는 기존처럼 근무정보 확인
                      showWorkerInfo = true;
                    }
                  });
                },
              )
                  : showWorkerInfo
                  ? _buildWorkerInfo()
                  : ApplicationForm(
                isSubstitute: isSubstitute,

                scheduleTile: _MenuTile(
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

                workerTile: _MenuTile(
                  title: isSubstitute ? "대타 근무자" : "교대 상대 근무자",

                  trailing: _workerConfirmed
                      ? isSubstitute
                  // ===========================
                  // 대타 : 이름만 표시
                  // ===========================
                      ? Text(
                    _selectedWorker ?? "",
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  )

                  // ===========================
                  // 교대 : 이름 + 근무정보 표시
                  // ===========================
                      : selectedWorkerSchedule != null
                      ? Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        selectedWorkerSchedule.name,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "${selectedWorkerSchedule.date.month}월 "
                            "${selectedWorkerSchedule.date.day}일 "
                            "${selectedWorkerSchedule.startTime} - "
                            "${selectedWorkerSchedule.endTime}",
                        style: const TextStyle(
                          fontSize: 13,
                          color: Color(0xff8F8F8F),
                        ),
                      ),
                    ],
                  )
                      : const Text(
                    "선택 안함",
                    style: TextStyle(
                      color: Color(0xff8F8F8F),
                      fontSize: 16,
                    ),
                  )
                      : const Text(
                    "선택 안함",
                    style: TextStyle(
                      color: Color(0xff8F8F8F),
                      fontSize: 16,
                    ),
                  ),

                  hasArrow: true,

                  onTap: () {
                    if (_selectedDate == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("먼저 날짜를 선택해주세요."),
                        ),
                      );
                      return;
                    }

                    if (getWorkersForSelectedDate().isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("해당 날짜에 근무자가 없습니다."),
                        ),
                      );
                      return;
                    }

                    setState(() {
                      showWorkerSelect = true;
                      _workerMode = true;
                    });
                  },
                ),

                reasonTile: _MenuTile(
                  title: isSubstitute ? "대타 사유" : "교대 사유",

                  trailing: Text(
                    _selectedReason == null
                        ? "선택 안함"
                        : _selectedReason == "기타" &&
                        (_selectedEtc?.isNotEmpty ?? false)
                        ? "기타 / $_selectedEtc"
                        : _selectedReason!,
                    textAlign: TextAlign.right,
                    style: TextStyle(
                      color: _selectedReason == null
                          ? const Color(0xff8F8F8F)
                          : Colors.black,
                      fontSize: 16,
                      fontWeight: _selectedReason == null
                          ? FontWeight.w400
                          : FontWeight.w500,
                    ),
                  ),

                  hasArrow: true,

                  onTap: () async {
                    final result = await showModalBottomSheet<Map<String, String?>>(
                      context: context,
                      isScrollControlled: true,
                      backgroundColor: Colors.transparent,
                      builder: (_) => ReasonBottomSheet(
                        isSubstitute: isSubstitute,
                        initialReason: _selectedReason,
                        initialEtc: _selectedEtc,
                      ),
                    );

                    if (result != null) {
                      setState(() {
                        _selectedReason = result["reason"];
                        _selectedEtc = result["etc"];
                      });
                    }
                  },
                ),

                onSubmit: canSubmit
                    ? () {

                  // ==========================
                  // 대타 신청
                  // ==========================

                  // 내 근무
                  final mySchedule = getSelectedSchedule();

                  if (mySchedule == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("내 근무를 선택해주세요.")),
                    );
                    return;
                  }

                  if (isSubstitute) {

                    // 대타는 근무자 이름만 있으면 됨
                    if (_selectedWorker == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("대타 근무자를 선택해주세요.")),
                      );
                      return;
                    }

                    showModalBottomSheet(
                      context: context,
                      backgroundColor: Colors.transparent,
                      isScrollControlled: true,
                      builder: (_) => SubstituteConfirmBottomSheet(
                        myName: "최세중(나)",

                        // 이름만 사용
                        workerName: _selectedWorker!,

                        // 내 근무 정보
                        myDate:
                        "${mySchedule.date.month}월 ${mySchedule.date.day}일",
                        myTime:
                        "${mySchedule.startTime} - ${mySchedule.endTime}",

                        // 대타는 내 근무를 대신하는 것이므로
                        // 날짜/시간도 동일
                        workerDate:
                        "${mySchedule.date.month}월 ${mySchedule.date.day}일",
                        workerTime:
                        "${mySchedule.startTime} - ${mySchedule.endTime}",

                        reason: _selectedReason == "기타"
                            ? "기타 / $_selectedEtc"
                            : _selectedReason!,

                        onConfirm: () {
                          Navigator.pop(context);

                          // TODO : 대타 신청 API
                        },
                      ),
                    );

                  } else {

                    // ==========================
                    // 교대 신청
                    // ==========================
                    final workerSchedule = getSelectedWorkerSchedule();

                    if (workerSchedule == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("교대 근무를 선택해주세요.")),
                      );
                      return;
                    }

                    showModalBottomSheet(
                      context: context,
                      backgroundColor: Colors.transparent,
                      isScrollControlled: true,
                      builder: (_) => ExchangeConfirmBottomSheet(
                        myName: "최세중(나)",
                        workerName: workerSchedule.name,

                        myDate:
                        "${mySchedule.date.month}월 ${mySchedule.date.day}일",
                        workerDate:
                        "${workerSchedule.date.month}월 ${workerSchedule.date.day}일",

                        myTime:
                        "${mySchedule.startTime} - ${mySchedule.endTime}",
                        workerTime:
                        "${workerSchedule.startTime} - ${workerSchedule.endTime}",

                        reason: _selectedReason == "기타"
                            ? "기타 / $_selectedEtc"
                            : _selectedReason!,

                        onConfirm: () {
                          Navigator.pop(context);

                          // TODO : 교대 신청 API
                        },
                      ),
                    );
                  }
                }
                    : null,
              ),
            )
          ],
        ),
      ),
    );
  }


  Widget _buildWorkerInfo() {
    final schedule = getSelectedWorkerSchedule();

    return Column(
      children: [
        const SizedBox(height: 40),

        WorkerInfoCard(
          workerName: _selectedWorker,
          schedule: schedule,
        ),

        const Spacer(),

        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 14,
            vertical: 16,
          ),
          child: SizedBox(
            width: double.infinity,
            height: 54,
            child: ElevatedButton(
              onPressed: () {
                setState(() {
                  showWorkerInfo = false;
                  _workerConfirmed = true;
                });
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0084FF),
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                "근무자 확정",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _MenuTile extends StatelessWidget {
  final String title;
  final String? subtitle;

  final Widget? trailing;   // nullable로 변경
  final String? value;      // nullable로 변경

  final bool hasArrow;
  final VoidCallback onTap;
  final Color? valueColor;
  final FontWeight? valueWeight;

  const _MenuTile({
    super.key,
    required this.title,
    this.subtitle,
    this.trailing,
    this.value,
    required this.onTap,
    this.hasArrow = false,
    this.valueColor,
    this.valueWeight,
  });

  @override
  Widget build(BuildContext context) {

    return InkWell(
      onTap: onTap,
      child: Container(
        height: 72,
        padding: const EdgeInsets.symmetric(horizontal: 20,),
        child: Row(
          children: [
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),

            trailing ??
                Text(
                  value ?? "",
                  style: TextStyle(
                    color: valueColor ?? const Color(0xff8F8F8F),
                    fontSize: 16,
                    fontWeight: valueWeight ?? FontWeight.w400,
                  ),
                ),

            if (hasArrow)
              const Padding(
                padding: EdgeInsets.only(left: 6),
                child: Icon(
                  Icons.chevron_right,
                  color: Color(0xffBDBDBD),
                ),
              ),
          ],
        ),
      ),
    );
  }
}