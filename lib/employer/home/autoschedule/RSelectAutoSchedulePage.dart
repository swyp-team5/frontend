import 'package:flutter/material.dart';

import 'models/ScheduleScenario.dart';
import 'models/ShiftCount.dart';
import 'widgets/RWeekCalendar.dart';

class RSelectAutoSchedulePage extends StatefulWidget {
  const RSelectAutoSchedulePage({super.key});

  @override
  State<RSelectAutoSchedulePage> createState() =>
      _RSelectAutoSchedulePageState();
}

class _RSelectAutoSchedulePageState
    extends State<RSelectAutoSchedulePage> {
  int selectedScenario = 0;

  late final List<ScheduleScenario> scenarios;

  @override
  void initState() {
    super.initState();

    scenarios = [
      /// ---------------- 시안1 ----------------
      ScheduleScenario(
        title: "시안 1",
        open: const [
          ShiftCount(required: 2, available: 1, isOff: true), // 월요일 휴무
          ShiftCount(required: 2, available: 2,),
          ShiftCount(required: 2, available: 1,),
          ShiftCount(required: 2, available: 2,),
          ShiftCount(required: 4, available: 3,),
          ShiftCount(required: 4, available: 4,),
          ShiftCount(required: 4, available: 3,),
        ],
        middle: const [
          ShiftCount(required: 2, available: 2, isOff: true), // 월요일 휴무
          ShiftCount(required: 2, available: 2,),
          ShiftCount(required: 2, available: 2,),
          ShiftCount(required: 2, available: 2,),
          ShiftCount(required: 2, available: 1,),
          ShiftCount(required: 2, available: 1,),
          ShiftCount(required: 2, available: 2,),
        ],
        close: const [
          ShiftCount(required: 2, available: 2, isOff: true), // 월요일 휴무
          ShiftCount(required: 3, available: 3,),
          ShiftCount(required: 2, available: 2,),
          ShiftCount(required: 3, available: 2,),
          ShiftCount(required: 2, available: 2,),
          ShiftCount(required: 2, available: 2,),
          ShiftCount(required: 2, available: 2,),
        ],
      ),

      /// ---------------- 시안2 ----------------
      ScheduleScenario(
        title: "시안 2",
        open: const [
          ShiftCount(required: 2, available: 1, isOff: true), // 월요일 휴무
          ShiftCount(required: 2, available: 2,),
          ShiftCount(required: 3, available: 2,),
          ShiftCount(required: 2, available: 2,),
          ShiftCount(required: 4, available: 3),
          ShiftCount(required: 4, available: 4,),
          ShiftCount(required: 4, available: 4,),
        ],
        middle: const [
          ShiftCount(required: 2, available: 1, isOff: true), // 월요일 휴무
          ShiftCount(required: 2, available: 2,),
          ShiftCount(required: 2, available: 1,),
          ShiftCount(required: 2, available: 2,),
          ShiftCount(required: 2, available: 1,),
          ShiftCount(required: 2, available: 2,),
          ShiftCount(required: 2, available: 2,),
        ],
        close: const [
          ShiftCount(required: 2, available: 1, isOff: true), // 월요일 휴무
          ShiftCount(required: 2, available: 2,),
          ShiftCount(required: 2, available: 1,),
          ShiftCount(required: 2, available: 2,),
          ShiftCount(required: 2, available: 1,),
          ShiftCount(required: 2, available: 2,),
          ShiftCount(required: 2, available: 2,),
        ],
      ),

      /// ---------------- 시안3 ----------------
      ScheduleScenario(
        title: "시안 3",
        open: const [
          ShiftCount(required: 2, available: 1, isOff: true), // 월요일 휴무
          ShiftCount(required: 2, available: 2,),
          ShiftCount(required: 2, available: 1,),
          ShiftCount(required: 2, available: 2,),
          ShiftCount(required: 2, available: 1,),
          ShiftCount(required: 2, available: 1,),
          ShiftCount(required: 2, available: 2,),
        ],
        middle: const [
          ShiftCount(required: 2, available: 1, isOff: true), // 월요일 휴무
          ShiftCount(required: 2, available: 2,),
          ShiftCount(required: 2, available: 1,),
          ShiftCount(required: 2, available: 2,),
          ShiftCount(required: 2, available: 1,),
          ShiftCount(required: 2, available: 1,),
          ShiftCount(required: 2, available: 2,),
        ],
        close: const [
          ShiftCount(required: 2, available: 1, isOff: true), // 월요일 휴무
          ShiftCount(required: 2, available: 2,),
          ShiftCount(required: 2, available: 1,),
          ShiftCount(required: 2, available: 2,),
          ShiftCount(required: 2, available: 1,),
          ShiftCount(required: 2, available: 1,),
          ShiftCount(required: 2, available: 2,),
        ],
      ),

      /// ---------------- 시안4 ----------------
      ScheduleScenario(
        title: "시안 4",
        open: const [
          ShiftCount(required: 2, available: 1, isOff: true), // 월요일 휴무
          ShiftCount(required: 2, available: 2,),
          ShiftCount(required: 2, available: 1,),
          ShiftCount(required: 2, available: 2,),
          ShiftCount(required: 2, available: 2,),
          ShiftCount(required: 2, available: 2,),
          ShiftCount(required: 2, available: 2,),
        ],
        middle: const [
          ShiftCount(required: 2, available: 1, isOff: true), // 월요일 휴무
          ShiftCount(required: 2, available: 2,),
          ShiftCount(required: 2, available: 1,),
          ShiftCount(required: 2, available: 2,),
          ShiftCount(required: 2, available: 1,),
          ShiftCount(required: 2, available: 1,),
          ShiftCount(required: 2, available: 2,),
        ],
        close: const [
          ShiftCount(required: 2, available: 1, isOff: true), // 월요일 휴무
          ShiftCount(required: 2, available: 2,),
          ShiftCount(required: 2, available: 1,),
          ShiftCount(required: 2, available: 2,),
          ShiftCount(required: 2, available: 1,),
          ShiftCount(required: 2, available: 1,),
          ShiftCount(required: 2, available: 2,),
        ],
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();

    /// 다음주 월요일
    final nextMonday = DateTime(
      now.year,
      now.month,
      now.day,
    ).add(Duration(days: 8 - now.weekday));

    /// 다음주 일요일
    final nextSunday = nextMonday.add(const Duration(days: 6));

    return Scaffold(
      backgroundColor: Colors.white,

      body: SafeArea(
        child: Column(
          children: [
            /// 헤더
            const Padding(
              padding: EdgeInsets.fromLTRB(20, 30, 20, 0),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "스케줄 선택",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 18),

            /// 날짜 (가운데)
            Center(
              child: Text(
                "${nextMonday.month}월 ${nextMonday.day}일 - "
                    "${nextSunday.month}월 ${nextSunday.day}일",
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),

            const SizedBox(height: 16),

            /// 안내문
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 90),
              padding: const EdgeInsets.symmetric(vertical: 5),
              decoration: BoxDecoration(
                color: const Color(0xFFF1F1F5),
                borderRadius: BorderRadius.circular(4),
              ),
              child: const Center(
                child: Text(
                  "스케줄 시안 중 1개를 선택해주세요",
                  style: TextStyle(
                    color: Color(0xFF767676),
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),

            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
              child: Row(
                children: [
                  const SizedBox(width: 50),

                  ...const [
                    "월", "화", "수", "목", "금", "토", "일",
                  ].map(
                        (day) => Expanded(
                      child: Center(
                        child: Text(
                          day,
                          style: TextStyle(
                            color: Color(0xFF767676),
                            fontSize: 12,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            Divider(height: 10),

            /// 달력
            Expanded(
              child: RWeekCalendar(
                scenarios: scenarios,
                selectedIndex: selectedScenario,
                onSelect: (index) {
                  setState(() {
                    selectedScenario = index;
                  });
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}