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
  DateTime? _selectedDate;
  /// 상대 근무자가 선택한 날짜
  DateTime? _selectedWorkerDate;

  /// 선택한 교대 상대
  String? _selectedWorker;

  /// false = 신청서
  /// true = 근무자 선택 화면
  bool showWorkerSelect = false;

  bool _workerMode = false;

  bool _workerConfirmed = false;

  bool showWorkerInfo = false;

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

    _selectedDate = null; // 처음에는 선택 안 함

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

    // ===== 처음(내 근무 선택 단계) =====
    if (!_workerMode) {

      // 다음주가 아니면 비활성
      if (!isNextWeek(day)) return false;

      // 다음주 내 근무일은 항상 선택 가능
      return isMyWorkDay(day);
    }

    // ===== 근무자 선택 이후 =====

    if (_selectedWorker == null) {
      return false;
    }

    // 선택한 근무자의 근무만 선택 가능
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

  Widget _buildWorkerSelect() {

    final workers = ["윤서준", "김유진"];

    return Column(

      children: [

        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 20,
          ),
          child: Row(

            children: [

              const Text(
                "교대 희망 상대를 선택하세요",
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF505050),
                ),
              ),

            ],
          ),
        ),

        Expanded(

          child: GridView.builder(

            padding: const EdgeInsets.symmetric(
              horizontal: 20,
            ),

            itemCount: workers.length,

            gridDelegate:
            const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 2.7,
            ),

            itemBuilder: (_, index) {

              final workerName = workers[index];

              final selected =
                  workerName == _selectedWorker;

              return GestureDetector(

                onTap: () {

                  setState(() {
                    _selectedWorker = workerName;
                  });

                },

                child: Container(

                  decoration: BoxDecoration(

                    color: selected
                        ? const Color(0xffE6F3FF)
                        : Colors.white,

                    borderRadius:
                    BorderRadius.circular(16),

                    border: Border.all(
                      color: selected
                          ? const Color(0xFF0084FF)
                          : Colors.transparent,
                    ),

                  ),

                  child: Row(

                    children: [

                      const SizedBox(width: 12),

                      Container(
                        width: 48, height: 48,

                        decoration: BoxDecoration(
                          color: Color(0xFFE0E2E5),
                          borderRadius:
                          BorderRadius.circular(8),
                        ),

                      ),

                      const SizedBox(width: 12),

                      Expanded(

                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "동료",
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 12,
                                color: Color(0xFF999999),
                              ),
                            ),

                            Text(
                              workerName,
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 16,
                              ),

                            ),

                            // Text(
                            //   "${worker.role} (${worker.startTime}~${worker.endTime})",
                            //   style: const TextStyle(
                            //     fontSize: 13,
                            //     color: Colors.grey,
                            //   ),
                            // ),

                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),

        Padding(

          padding: const EdgeInsets.all(20),

          child: SizedBox(

            width: double.infinity,
            height: 54,

            child: ElevatedButton(

              onPressed: _selectedWorker == null
                  ? null
                  : () {
                setState(() {
                  showWorkerSelect = false;
                  showWorkerInfo = true;
                });
              },

              style: ElevatedButton.styleFrom(
                backgroundColor:
                const Color(0xff79B5F3),
              ),

              child: const Text(
                "근무자 선택",
              ),

            ),
          ),
        ),

      ],
    );
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

                  /// 월 이동
                  Row(
                    children: [
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            _focusedMonth = DateTime(
                              _focusedMonth.year,
                              _focusedMonth.month - 1,
                            );
                          });
                        },
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
                            "${_focusedMonth.year}년 ${_focusedMonth.month}월",
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),

                      GestureDetector(
                        onTap: () {
                          setState(() {
                            _focusedMonth = DateTime(
                              _focusedMonth.year,
                              _focusedMonth.month + 1,
                            );
                          });
                        },
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
                    children: List.generate(
                      7,
                          (i) {
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
                      },
                    ),
                  ),

                  const SizedBox(height: 10),

                  /// 달력
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

                      final isCurrent = day.month == _focusedMonth.month;

                      final isMySelectedDay =
                          _selectedDate != null &&
                              day.year == _selectedDate!.year &&
                              day.month == _selectedDate!.month &&
                              day.day == _selectedDate!.day;

                      final isWorkerSelectedDay =
                          _selectedWorkerDate != null &&
                              day.year == _selectedWorkerDate!.year &&
                              day.month == _selectedWorkerDate!.month &&
                              day.day == _selectedWorkerDate!.day;

                      final myWorkDay = isMyWorkDay(day);

                      final selectedWorkerWorkDay =
                      isSelectedWorkerWorkDay(day);

                      final selectable = isSelectable(day);

                      return GestureDetector(

                        onTap: selectable
                            ? () {
                          setState(() {

                            if (_workerMode) {
                              _selectedWorkerDate = day;
                            } else {
                              _selectedDate = day;
                            }

                          });
                        }
                            : null,

                        child: Center(

                          child: Container(

                            width: 48,
                            height: 48,

                            alignment: Alignment.center,

                            decoration: BoxDecoration(

                              color: _workerMode
                                  ? (
                                  selectedWorkerWorkDay
                                      ? (
                                      isWorkerSelectedDay
                                          ? const Color(0xff27C840) // 선택한 날짜
                                          : showWorkerSelect
                                          ? const Color(0xffD9F6C5) // 근무자 선택 화면에서만 연두
                                          : Colors.transparent // 버튼 누르면 연두 제거
                                  )
                                      : (
                                      isMySelectedDay
                                          ? const Color(0xff0084FF) // 회색 → 파란색
                                          : Colors.transparent
                                  )
                              )
                                  : (
                                  isMySelectedDay
                                      ? const Color(0xff0084FF)
                                      : (myWorkDay && isNextWeek(day))
                                      ? const Color(0xffE6F3FF)
                                      : Colors.transparent
                              ),

                              borderRadius: BorderRadius.circular(10),

                            ),

                            child: Text(

                              "${day.day}",

                              style: TextStyle(

                                fontSize: 16,

                                fontWeight: FontWeight.w400,

                                color: !isCurrent
                                    ? const Color(0xffD1D1DD)

                                // 🔵 내가 선택한 날짜
                                    : isMySelectedDay
                                    ? Colors.white

                                // 🟢 상대가 선택한 날짜
                                    : isWorkerSelectedDay
                                    ? Colors.white

                                // 선택 가능한 나머지 날짜
                                    : selectable
                                    ? const Color(0xff8F8F8F)

                                // 비활성 날짜
                                    : const Color(0xffBDBDBD),

                              ),

                            ),

                          ),

                        ),

                      );

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
                    ? _buildWorkerSelect()
                    : showWorkerInfo
                    ? _buildWorkerInfo()
                    : Padding(
                  padding: EdgeInsets.zero,
                  child: Column(
                    children: [
                      Expanded(
                        child: ListView(
                          children: [
                            const SizedBox(height: 8),

                            _MenuTile(
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

                            _MenuTile(
                              title: isSubstitute ? "대타 근무자" : "교대 상대 근무자",

                              trailing: _workerConfirmed && selectedWorkerSchedule != null
                                  ? Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    selectedWorkerSchedule.name,
                                    textAlign: TextAlign.right,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.black,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    "${selectedWorkerSchedule.date.month}월 "
                                        "${selectedWorkerSchedule.date.day}일 "
                                        "${selectedWorkerSchedule.startTime} - "
                                        "${selectedWorkerSchedule.endTime}",
                                    textAlign: TextAlign.right,
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
                                  fontWeight: FontWeight.w400,
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

                            _MenuTile(
                              title: isSubstitute
                                  ? "대타 사유"
                                  : "교대 사유",
                              value: "선택 안함",
                              hasArrow: true,
                              onTap: () {},
                            ),
                          ],
                        ),
                      ),

                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 20,
                        ),
                        child: SizedBox(
                          width: double.infinity,
                          height: 54,
                          child: ElevatedButton(
                            onPressed: null,
                            style: ElevatedButton.styleFrom(
                              backgroundColor:
                              const Color(0xff79B5F3),
                              disabledBackgroundColor:
                              const Color(0xff79B5F3),
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius:
                                BorderRadius.circular(14),
                              ),
                            ),
                            child: const Text(
                              "신청하기",
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                                fontSize: 18,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
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
        const SizedBox(height: 20),

        /// 카드 UI
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFFF2F2F2), // 회색 배경
              borderRadius: BorderRadius.circular(18),
            ),
            child: schedule == null
                ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "${_selectedWorker ?? ""}님의 근무 정보",
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  "날짜를 선택해주세요.",
                  style: TextStyle(
                    color: Color(0xff8F8F8F),
                    fontSize: 14,
                  ),
                ),
              ],
            )
                : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                /// 제목
                Text(
                  "${_selectedWorker ?? ""}님의 근무 정보",
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                  ),
                ),

                const SizedBox(height: 20),

                /// 날짜
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "날짜",
                      style: TextStyle(
                        color: Color(0xff8F8F8F),
                        fontSize: 15,
                      ),
                    ),
                    Text(
                      "${schedule.date.year}년 ${schedule.date.month}월 ${schedule.date.day}일",
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 14),

                /// 근무시간
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "근무시간",
                      style: TextStyle(
                        color: Color(0xff8F8F8F),
                        fontSize: 15,
                      ),
                    ),
                    Text(
                      "${schedule.startTime} - ${schedule.endTime}",
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),

        const Spacer(),

        /// 버튼
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
                foregroundColor: Colors.white, // 텍스트 색
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

        padding: const EdgeInsets.symmetric(
          horizontal: 20,
        ),

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