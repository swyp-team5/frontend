import 'package:flutter/material.dart';

import '../../common/widgets/BottomNavBar.dart';
import '../../employee/schedule/Month/AllSchedule/EMonthAllSchedulePage.dart';
import '../crews/RCrewPage.dart';
import '../home/RHomePage.dart';
import '../mypage/RMyPage.dart';
import 'Month/RMonthAllSchedulePage.dart';
import 'RAddSchedulePage.dart';
import 'REditSchedulePage.dart';
import 'Week/RWeekSchedulePage.dart';
import 'RYearMonthBottomSheet.dart';
import 'models/schedule_model.dart';

class RMainSchedulePage extends StatefulWidget {
  const RMainSchedulePage({super.key});

  @override
  State<RMainSchedulePage> createState() => _RMainSchedulePageState();
}

class _RMainSchedulePageState extends State<RMainSchedulePage> {
  /// true = 주간, false = 월간
  bool isWeekMode = true;

  /// 현재 선택된 날짜
  DateTime selectedDate = DateTime.now();

  int selectedYear = DateTime.now().year;
  int selectedMonth = DateTime.now().month;

  List<ScheduleModel> schedules = [];


  /// API 연동 전 더미 데이터
  final Map<String, List<RScheduleWorker>> allSchedules = {
    "2026-06-23": [
      RScheduleWorker(name: "김지연", startTime: "09:00", endTime: "11:00", role: "오픈",),
      RScheduleWorker(name: "이다빈", startTime: "09:00", endTime: "11:00", role: "오픈",),
      RScheduleWorker(name: "박춘식", startTime: "12:00", endTime: "16:00", role: "미들",),
      RScheduleWorker(name: "홍길동", startTime: "16:00", endTime: "20:00", role: "마감",),
      RScheduleWorker(name: "최민수", startTime: "16:00", endTime: "20:00", role: "마감",),
    ],

    "2026-06-24": [
      RScheduleWorker(name: "이다빈", startTime: "10:00", endTime: "13:00", role: "오픈",),
      RScheduleWorker(name: "박춘식", startTime: "12:00", endTime: "16:00", role: "미들",),
      RScheduleWorker(name: "서지훈", startTime: "12:00", endTime: "16:00", role: "미들",),
    ],

    "2026-06-25": [
      RScheduleWorker(name: "이다빈", startTime: "10:00", endTime: "14:00", role: "오픈",),
      RScheduleWorker(name: "김지연", startTime: "10:00", endTime: "14:00", role: "오픈",),
      RScheduleWorker(name: "박춘식", startTime: "14:00", endTime: "16:00", role: "미들",),
      RScheduleWorker(name: "강민석", startTime: "14:00", endTime: "16:00", role: "미들",),
      RScheduleWorker(name: "서지훈", startTime: "14:00", endTime: "16:00", role: "미들",),
      RScheduleWorker(name: "정은우", startTime: "16:00", endTime: "20:00", role: "마감",),
    ],

    "2026-06-30": [
      RScheduleWorker(name: "이다빈", startTime: "10:00", endTime: "14:00", role: "오픈",),
      RScheduleWorker(name: "김지연", startTime: "10:00", endTime: "14:00", role: "오픈",),
      RScheduleWorker(name: "박춘식", startTime: "14:00", endTime: "16:00", role: "미들",),
      RScheduleWorker(name: "강민석", startTime: "14:00", endTime: "16:00", role: "미들",),
      RScheduleWorker(name: "서지훈", startTime: "14:00", endTime: "16:00", role: "미들",),
      RScheduleWorker(name: "정은우", startTime: "16:00", endTime: "20:00", role: "마감",),
    ],
  };

  /// 휴무일 더미 데이터
  final Set<String> holidays = {
    "2026-06-22",
  };


  @override
  void initState() {
    super.initState();

    selectedYear = selectedDate.year;
    selectedMonth = selectedDate.month;
  }


  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: Colors.white,

      /// 공통 BottomNavBar 적용
      bottomNavigationBar: BottomNavBar(
        currentIndex: 2,
        onTap: (index) {
          if (index == 0) {
            Navigator.push(context,
                MaterialPageRoute(builder: (_) => const RHomePage()));
          } else if (index == 1) {
            Navigator.push(context,
                MaterialPageRoute(builder: (_) => const RCrewPage()));
          } else if (index == 2) {
            Navigator.push(context,
                MaterialPageRoute(builder: (_) => const RMainSchedulePage()));
          } else if (index == 4) {
            Navigator.push(
                context, MaterialPageRoute(builder: (_) => const RMyPage()));
          }
        },
      ),

      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                // ==========================
                // Header
                // ==========================
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 14,
                  ),
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: () async {

                          final result = await showModalBottomSheet<DateTime>(
                            context: context,
                            isScrollControlled: true,
                            backgroundColor: Colors.transparent,
                            builder: (_) => const RYearMonthBottomSheet(),
                          );

                          if (result != null) {
                            setState(() {
                              selectedDate = result;
                            });
                          }

                          if (result != null) {
                            setState(() {
                              selectedDate = result;
                            });
                          }
                        },
                        child: Row(
                          children: [
                            Text(
                              "${selectedDate.month}월",
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(width: 2),
                            const Icon(Icons.keyboard_arrow_down),
                          ],
                        ),
                      ),

                      const Spacer(),

                      IconButton(
                        onPressed: () {
                          // TODO : 필터
                        },
                        icon: const Icon(Icons.tune),
                      ),

                      PopupMenuButton<String>(
                        color: Colors.white,
                        elevation: 6,
                        splashRadius: 20,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        icon: const Icon(Icons.edit_outlined),
                        onSelected: (value) async {
                          if (value == 'edit') {
                            await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => RScheduleEditPage(
                                  selectedDate: selectedDate,
                                  schedules: allSchedules,
                                ),
                              ),
                            );

                            // 수정 후 다시 화면 갱신
                            setState(() {});
                          } else if (value == 'add') {
                            final ScheduleModel? schedule =
                            await Navigator.push<ScheduleModel>(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const RAddSchedulePage(),
                              ),
                            );

                            if (schedule != null) {
                              setState(() {
                                schedules.add(schedule);

                                // 캘린더 데이터 반영
                                for (final date in schedule.dates) {
                                  final key =
                                      "${date.year.toString().padLeft(4, '0')}-"
                                      "${date.month.toString().padLeft(2, '0')}-"
                                      "${date.day.toString().padLeft(2, '0')}";

                                  allSchedules.putIfAbsent(key, () => []);

                                  for (final worker in schedule.workers) {
                                    allSchedules[key]!.add(
                                      RScheduleWorker(
                                        name: worker,
                                        startTime: schedule.startTime,
                                        endTime: schedule.endTime,
                                        role: schedule.workName,
                                        breakTime: schedule.breakTime,
                                      ),
                                    );
                                  }
                                }
                              });
                            }
                          }
                        },
                        itemBuilder: (_) => [
                          const PopupMenuItem<String>(
                            value: 'edit',
                            padding: EdgeInsets.symmetric(horizontal: 20),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.edit_outlined,
                                  size: 20,
                                  color: Colors.black,
                                ),
                                SizedBox(width: 10),
                                Text(
                                  '수정',
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const PopupMenuDivider(height: 1),
                          const PopupMenuItem<String>(
                            value: 'add',
                            padding: EdgeInsets.symmetric(horizontal: 20),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.add_outlined,
                                  size: 20,
                                  color: Colors.black,
                                ),
                                SizedBox(width: 10),
                                Text(
                                  '추가',
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      )
                    ],
                  ),
                ),

                // ==========================
                // 내용
                // ==========================

                Expanded(
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 250),
                    child: isWeekMode
                        ? RWeekSchedulePage(
                      key: const ValueKey("week"),
                      selectedDate: selectedDate,
                      schedules: allSchedules,
                      holidays: holidays,
                      onDateChanged: (date) {
                        setState(() {
                          selectedDate = date;
                        });
                      },
                    )
                        : RMonthAllSchedulePage(
                      key: const ValueKey("month"),
                      selectedDate: selectedDate,
                      schedules: allSchedules,
                      onDateChanged: (date) {
                        setState(() {
                          selectedDate = date;
                        });
                      },
                    ),
                  ),
                ),
              ],
            ),

            // ==========================
            // 주 / 월 토글
            // ==========================

            Positioned(
              bottom: 14, left: 0, right: 0,
              child: Center(
                child: Container(
                  width: 88, height: 34,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF2F2F5),
                    borderRadius: BorderRadius.circular(17),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              isWeekMode = true;
                            });
                          },
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 180),
                            decoration: BoxDecoration(
                              color: isWeekMode
                                  ? const Color(0xFF3A3A3C)
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(17),
                            ),
                            alignment: Alignment.center,
                            child: Text("주",
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: isWeekMode
                                    ? Colors.white
                                    : const Color(0xFF8E8E93),
                              ),
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              isWeekMode = false;
                            });
                          },
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 180),
                            decoration: BoxDecoration(
                              color: !isWeekMode
                                  ? const Color(0xFF3A3A3C)
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(17),
                            ),
                            alignment: Alignment.center,
                            child: Text("월",
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: !isWeekMode
                                    ? Colors.white
                                    : const Color(0xFF8E8E93),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
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