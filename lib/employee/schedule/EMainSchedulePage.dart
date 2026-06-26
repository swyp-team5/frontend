import 'package:flutter/material.dart';

import '../../common/widgets/BottomNavBar.dart';
import '../crews/ECrewPage.dart';
import '../home/EHomePage.dart';
import '../mypage/EMyPage.dart';
import 'EYearMonthBottomSheet.dart';
import 'Month/AllSchedule/EMonthAllSchedulePage.dart';
import 'Month/MySchedule/EMonthMyScheduleBottomSheet.dart';
import 'Month/MySchedule/EMonthMySchedulePage.dart';
import 'Week/EWeekSchedulePage.dart';

class EMainSchedulePage extends StatefulWidget {
  const EMainSchedulePage({super.key});

  @override
  State<EMainSchedulePage> createState() => _EMainSchedulePageState();
}

class _EMainSchedulePageState extends State<EMainSchedulePage> {
  /// true = 주간, false = 월간
  bool isWeekMode = true;

  /// 현재 선택된 날짜
  DateTime selectedDate = DateTime.now();

  int selectedYear = DateTime.now().year;
  int selectedMonth = DateTime.now().month;

  /// API 연동 전 더미 데이터
  final Map<String, List<MySchedule>> monthSchedules = {
    "2026-06-02": [
      MySchedule(name: "이다빈", startTime: "09:00", endTime: "13:00")
    ],
    "2026-06-05": [
      MySchedule(name: "이다빈", startTime: "10:00", endTime: "14:00")
    ],
    "2026-06-07": [
      MySchedule(name: "이다빈", startTime: "11:00", endTime: "14:00")
    ],
    "2026-06-10": [
      MySchedule(name: "이다빈", startTime: "12:00", endTime: "16:00")
    ],
    "2026-06-15": [
      MySchedule(name: "이다빈", startTime: "16:00", endTime: "20:00")
    ],
    "2026-06-19": [
      MySchedule(name: "이다빈", startTime: "14:00", endTime: "18:00")
    ],
    "2026-06-23": [
      MySchedule(name: "이다빈", startTime: "16:00", endTime: "20:00")
    ],
  };

  final Map<String, List<ScheduleWorker>> allSchedules = {
    "2026-06-23": [
      ScheduleWorker(name: "김지연", startTime: "09:00", endTime: "13:00"),
      ScheduleWorker(name: "이다빈", startTime: "10:00", endTime: "14:00"),
      ScheduleWorker(name: "박춘식", startTime: "12:00", endTime: "16:00"),
      ScheduleWorker(name: "홍길동", startTime: "15:00", endTime: "19:00"),
      ScheduleWorker(name: "최민수", startTime: "16:00", endTime: "20:00"),
    ],

    "2026-06-25": [
      ScheduleWorker(name: "이다빈", startTime: "09:00", endTime: "13:00"),
      ScheduleWorker(name: "김지연", startTime: "10:00", endTime: "14:00"),
      ScheduleWorker(name: "박춘식", startTime: "12:00", endTime: "16:00"),
      ScheduleWorker(name: "강민석", startTime: "14:00", endTime: "18:00"),
      ScheduleWorker(name: "서지훈", startTime: "15:00", endTime: "19:00"),
      ScheduleWorker(name: "정은우", startTime: "16:00", endTime: "20:00"),
    ],
  };

  /// 휴무일 더미 데이터
  final Set<String> holidays = {
    "2026-06-22",
  };

  bool isAllViewSelected = false;


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
                MaterialPageRoute(builder: (_) => const EHomePage()));
          } else if (index == 1) {
            Navigator.push(context,
                MaterialPageRoute(builder: (_) => const ECrewPage()));
          } else if (index == 2) {
            Navigator.push(context,
                MaterialPageRoute(builder: (_) => const EMainSchedulePage()));
          } else if (index == 4) {
            Navigator.push(
                context, MaterialPageRoute(builder: (_) => const EMyPage()));
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
                            builder: (_) => const EYearMonthBottomSheet(),
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

                      GestureDetector(
                        onTap: () {
                          setState(() {
                            isAllViewSelected = !isAllViewSelected;
                          });
                        },
                        child: Container(
                          height: 34,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: isAllViewSelected
                                ? const Color(0xFFEEEBFF)
                                : const Color(0xFFF1F1F5),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: isAllViewSelected
                                  ? const Color(0xFF7D67FD)
                                  : const Color(0xFFE0E2E5),
                              width: 1,
                            ),
                          ),
                          child: Text(
                            "전체 보기",
                            style: TextStyle(
                              fontSize: 12,
                              color: isAllViewSelected
                                  ? const Color(0xFF7D67FD)
                                  : const Color(0xFF767676),
                            ),
                          ),
                        ),
                      ),

                      IconButton(
                        onPressed: () {
                          // TODO : 필터
                        },
                        icon: const Icon(Icons.tune),
                      ),
                    ],
                  ),
                ),


                // 내용
                Expanded(
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 250),
                    child: isWeekMode
                        ? EWeekSchedulePage(
                      key: const ValueKey("week"),
                      selectedDate: selectedDate,
                      onDateChanged: (date) {
                        setState(() {
                          selectedDate = date;
                        });
                      },

                      /// 개인 스케줄
                      monthSchedules: monthSchedules,

                      /// 전체 스케줄
                      allSchedules: allSchedules,

                      /// 휴무일
                      holidays: holidays,

                      /// 상단 토글
                      isAllView: isAllViewSelected,
                    )
                        : isAllViewSelected
                        ? EMonthAllSchedulePage(
                      key: const ValueKey("month_all"),
                      selectedDate: selectedDate,
                      schedules: allSchedules,
                      holidays: holidays,
                      onDateChanged: (date) {
                        setState(() {
                          selectedDate = date;
                        });
                      },
                    )
                        : EMonthMySchedulePage(
                      key: const ValueKey("month_my"),
                      selectedDate: selectedDate,
                      schedules: monthSchedules,
                      holidays: holidays,
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

            // 주 / 월 토글
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