import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

import 'Month/RMonthAllSchedulePage.dart';
import 'Month/RWorkingDetailEditPage.dart';
import 'models/WorkersResponse.dart';

class RScheduleEditPage extends StatefulWidget {
  final int workPlaceId;
  final DateTime selectedDate;
  final Map<String, List<RScheduleShift>> schedules;

  const RScheduleEditPage({
    super.key,
    required this.workPlaceId,
    required this.selectedDate,
    required this.schedules,
  });

  @override
  State<RScheduleEditPage> createState() => _RScheduleEditPageState();
}

class _RScheduleEditPageState extends State<RScheduleEditPage> {
  late DateTime focusedDay;
  DateTime? selectedDay;

  @override
  void initState() {
    super.initState();

    focusedDay = widget.selectedDate;
    selectedDay = widget.selectedDate;
  }

  String dateKey(DateTime date) {
    return "${date.year.toString().padLeft(4, '0')}-"
        "${date.month.toString().padLeft(2, '0')}-"
        "${date.day.toString().padLeft(2, '0')}";
  }

  int _colorIndexForRole(String role) {
    switch (role) {
      case "오픈":
        return 0;
      case "미들":
        return 1;
      case "마감":
        return 2;
      default:
        return 3;
    }
  }


  Color roleColor(String role) {
    switch (role) {
      case "오픈":
        return const Color(0xFFE6F3FF);

      case "미들":
        return const Color(0xFFEEEBFF);

      case "마감":
        return const Color(0xFFDCFED8);

      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final List<RScheduleShift> shifts =
    selectedDay == null
        ? <RScheduleShift>[]
        : widget.schedules[dateKey(selectedDay!)] ?? [];

    return Scaffold(
      backgroundColor: Colors.white,

      body: SafeArea(
        child: Column(
          children: [

            /// Header
            Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 30
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [

                  const Center(
                    child: Text(
                      "스케줄 수정",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),

                  Align(
                    alignment: Alignment.centerLeft,
                    child: InkWell(
                      onTap: () {
                        Navigator.pop(context);
                      },
                      child: const Icon(
                        Icons.arrow_back_ios_new,
                        size: 22,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            TableCalendar(
              locale: 'ko_KR',

              firstDay: DateTime(2024),
              lastDay: DateTime(2035),

              focusedDay: focusedDay,

              availableGestures: AvailableGestures.horizontalSwipe,

              headerStyle: HeaderStyle(
                titleCentered: true,
                formatButtonVisible: false,

                titleTextStyle: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),

                leftChevronIcon: Container(
                  width: 28,
                  height: 28,
                  decoration: const BoxDecoration(
                    color: Color(0xffF4F4F8),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.chevron_left),
                ),

                rightChevronIcon: Container(
                  width: 28,
                  height: 28,
                  decoration: const BoxDecoration(
                    color: Color(0xffF4F4F8),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.chevron_right),
                ),
              ),

              calendarStyle: CalendarStyle(

                disabledTextStyle: const TextStyle(
                    color: Color(0xFFD1D1DD,)
                ),

                todayDecoration: const BoxDecoration(
                  color: Colors.transparent,
                ),

                todayTextStyle: const TextStyle(
                  color: Colors.black,
                ),

                selectedDecoration: const BoxDecoration(
                  color: Color(0xff1687F8),
                  shape: BoxShape.circle,
                ),

                selectedTextStyle: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),

                outsideTextStyle: const TextStyle(
                  color: Color(0xffCFCFD6),
                ),

                weekendTextStyle: const TextStyle(
                  color: Colors.black,
                ),

                defaultTextStyle: const TextStyle(
                  color: Colors.black,
                ),
              ),

              daysOfWeekStyle: const DaysOfWeekStyle(
                weekdayStyle: TextStyle(
                  color: Color(0xffA0A0A0),
                ),
                weekendStyle: TextStyle(
                  color: Color(0xffA0A0A0),
                ),
              ),

              selectedDayPredicate: (day) {
                return selectedDay != null &&
                    isSameDay(day, selectedDay);
              },

              onDaySelected: (selected, focused) {
                setState(() {
                  selectedDay = selected;
                  focusedDay = focused;
                });
              },

              onPageChanged: (focused) {
                setState(() {
                  focusedDay = focused;
                });
              },

              // 확정 배정이 있는 날짜(widget.schedules의 key)만 선택 가능하게 한다.
              // (widget.schedules는 이미 확정 스케줄 조회 API 결과로 만들어져 넘어오므로
              //  이 화면에서 별도로 API를 다시 호출할 필요가 없다.)
              enabledDayPredicate: (day) {
                return widget.schedules.containsKey(dateKey(day));
              },
            ),

            Expanded(
              child: selectedDay == null
                  ? const Center(
                child: Text(
                  "수정할 날짜를 선택해주세요",
                  style: TextStyle(
                    fontSize: 15,
                    color: Color(0xff505050),
                  ),
                ),
              )
                  : Builder(
                builder: (_) {
                  final groups = shifts;

                  const weekNames = [
                    "월", "화", "수", "목", "금", "토", "일",];

                  return ListView(
                    padding: const EdgeInsets.all(20),
                    children: [
                      Text(
                        "${selectedDay!.month}월 "
                            "${selectedDay!.day}일 "
                            "${weekNames[selectedDay!.weekday - 1]}요일",
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),

                      const SizedBox(height: 30),

                      ...groups.map((shift) {

                        final names =
                        shift.workers.map((e) => e.name).join(" · ");

                        return Padding(
                          padding: const EdgeInsets.only(bottom: 30),
                          child: Row(
                            crossAxisAlignment:
                            CrossAxisAlignment.start,
                            children: [
                              Container(
                                width: 5,
                                height: 50,
                                decoration: BoxDecoration(
                                  color: roleColor(shift.timeName),
                                  borderRadius:
                                  BorderRadius.circular(999),
                                ),
                              ),

                              const SizedBox(width: 14),

                              Expanded(
                                child: Column(
                                  crossAxisAlignment:
                                  CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "${shift.timeName} "
                                          "${shift.startTime} - ${shift.endTime}",
                                      style: const TextStyle(
                                        fontSize: 13,
                                        color: Color(0xFF505050),
                                      ),
                                    ),

                                    const SizedBox(height: 6),

                                    Text(
                                      names,
                                      style: const TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              IconButton(
                                onPressed: () async {
                                  // confirmedWeekScheduleId는 더 이상 여기서 넘기지 않습니다.
                                  // RWorkingDetailEditPage 진입 시(widget.date 기준) 그 페이지가
                                  // /confirmed-schedules/weekly API로 직접 조회합니다.
                                  final result = await Navigator.push<WorkingEditResult>(
                                    context,
                                    MaterialPageRoute(
                                        builder: (_) => RWorkingDetailEditPage(
                                          workPlaceId: widget.workPlaceId,
                                          timeDetailId: shift.timeDetailId,
                                          workPartNo: shift.workPartNo,
                                          role: shift.timeName,
                                          startTime: shift.startTime,
                                          endTime: shift.endTime,
                                          breakTime: shift.breakTime,
                                          date: selectedDay!,
                                          workers: shift.workers
                                              .map(
                                                (e) => WorkerItem(
                                              memberId: e.memberId,
                                              memberName: e.name,
                                              submitted: true,
                                            ),
                                          )
                                              .toList(),
                                        )
                                    ),
                                  );

                                  if (result != null) {
                                    setState(() {
                                      final oldKey = dateKey(selectedDay!);
                                      final newKey = dateKey(result.date);

                                      // 기존 날짜에서 그룹 제거
                                      widget.schedules[oldKey]?.remove(shift);

                                      // 기존 날짜가 비어있으면 삭제
                                      if (widget.schedules[oldKey]?.isEmpty ?? false) {
                                        widget.schedules.remove(oldKey);
                                      }

                                      // 새 날짜 생성
                                      widget.schedules.putIfAbsent(newKey, () => []);

                                      // 수정된 그룹 생성
                                      final updatedShift = RScheduleShift(
                                        timeDetailId: shift.timeDetailId, // 서버 timeDetailId는 유지
                                        workPartNo: shift.workPartNo,
                                        timeName: result.role,
                                        startTime: result.startTime,
                                        endTime: result.endTime,
                                        breakTime: result.breakTime,
                                        required: shift.required,
                                        workers: result.workers
                                            .map(
                                              (worker) => RScheduleWorker(
                                            memberId: worker.memberId,
                                            name: worker.memberName,
                                          ),
                                        )
                                            .toList(),
                                        colorIndex: shift.colorIndex, // 기존 색상 유지
                                      );

                                      widget.schedules[newKey]!.add(updatedShift);

                                      selectedDay = result.date;
                                      focusedDay = result.date;
                                    });
                                  }
                                },
                                icon: const Icon(
                                  Icons.chevron_right,
                                  color: Colors.black,
                                ),
                              ),
                            ],
                          ),
                        );
                      }),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}