import 'package:flutter/material.dart';

import 'models/SchedulePreviewResponse.dart';
import 'models/ScheduleScenario.dart';
import 'models/ShiftCount.dart';
import 'models/ShiftType.dart';
import 'widgets/RWeekCalendar.dart';

class RSelectAutoSchedulePage extends StatefulWidget {
  final SchedulePreviewResponse preview;

  const RSelectAutoSchedulePage({
    super.key,
    required this.preview,
  });

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
    scenarios = widget.preview.candidates
        .map((candidate) => _mapCandidateToScenario(candidate))
        .toList();
  }

  ScheduleScenario _mapCandidateToScenario(PreviewCandidate candidate) {
    final List<ShiftCount> open = [];
    final List<ShiftCount> middle = [];
    final List<ShiftCount> close = [];

    for (final day in candidate.days) {
      // ⚠️ 가정: timeDetails 배열 순서 = [open, middle, close]
      for (int i = 0; i < day.timeDetails.length; i++) {
        final detail = day.timeDetails[i];

        final shiftCount = ShiftCount(
          // ⚠️ required(필요 인원)는 preview 응답에 없어서 0으로 임시 처리
          required: 0,
          available: detail.workerMemberIds.length,
          type: _indexToShiftType(i),
          isOff: detail.workerMemberIds.isEmpty,
        );

        switch (_indexToShiftType(i)) {
          case ShiftType.open:
            open.add(shiftCount);
            break;
          case ShiftType.middle:
            middle.add(shiftCount);
            break;
          case ShiftType.close:
            close.add(shiftCount);
            break;
        }
      }
    }

    return ScheduleScenario(
      title: "시안 ${candidate.candidateNo}",
      open: open,
      middle: middle,
      close: close,
    );
  }

  ShiftType _indexToShiftType(int index) {
    switch (index) {
      case 0:
        return ShiftType.open;
      case 1:
        return ShiftType.middle;
      default:
        return ShiftType.close;
    }
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();

    final nextMonday = DateTime(
      now.year,
      now.month,
      now.day,
    ).add(Duration(days: 8 - now.weekday));

    final nextSunday = nextMonday.add(const Duration(days: 6));

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
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

// import 'package:flutter/material.dart';
//
// import 'models/SchedulePreviewResponse.dart';
// import 'models/ScheduleScenario.dart';
// import 'models/ShiftCount.dart';
// import 'models/ShiftType.dart';
// import 'widgets/RWeekCalendar.dart';
//
// class RSelectAutoSchedulePage extends StatefulWidget {
//   final SchedulePreviewResponse preview;
//
//   const RSelectAutoSchedulePage({
//     super.key,
//     required this.preview,
//   });
//
//   @override
//   State<RSelectAutoSchedulePage> createState() =>
//       _RSelectAutoSchedulePageState();
// }
//
// class _RSelectAutoSchedulePageState
//     extends State<RSelectAutoSchedulePage> {
//   int selectedScenario = 0;
//
//   late final List<ScheduleScenario> scenarios;
//
//   @override
//   void initState() {
//     super.initState();
//     scenarios = widget.preview.candidates
//         .map((candidate) => _mapCandidateToScenario(candidate))
//         .toList();
//   }
//
//   ScheduleScenario _mapCandidateToScenario(PreviewCandidate candidate) {
//     final List<ShiftCount> open = [];
//     final List<ShiftCount> middle = [];
//     final List<ShiftCount> close = [];
//
//     for (final day in candidate.days) {
//       // ⚠️ 가정: timeDetails 배열 순서 = [open, middle, close]
//       for (int i = 0; i < day.timeDetails.length; i++) {
//         final detail = day.timeDetails[i];
//
//         final shiftCount = ShiftCount(
//           // ⚠️ required(필요 인원)는 preview 응답에 없어서 0으로 임시 처리
//           required: 0,
//           available: detail.workerMemberIds.length,
//           type: _indexToShiftType(i),
//           isOff: detail.workerMemberIds.isEmpty,
//         );
//
//         switch (_indexToShiftType(i)) {
//           case ShiftType.open:
//             open.add(shiftCount);
//             break;
//           case ShiftType.middle:
//             middle.add(shiftCount);
//             break;
//           case ShiftType.close:
//             close.add(shiftCount);
//             break;
//         }
//       }
//     }
//
//     return ScheduleScenario(
//       candidateNo: candidate.candidateNo,
//       title: "시안 ${candidate.candidateNo}",
//       open: open,
//       middle: middle,
//       close: close,
//     );
//   }
//
//   ShiftType _indexToShiftType(int index) {
//     switch (index) {
//       case 0:
//         return ShiftType.open;
//       case 1:
//         return ShiftType.middle;
//       default:
//         return ShiftType.close;
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final now = DateTime.now();
//
//     final nextMonday = DateTime(
//       now.year,
//       now.month,
//       now.day,
//     ).add(Duration(days: 8 - now.weekday));
//
//     final nextSunday = nextMonday.add(const Duration(days: 6));
//
//     return Scaffold(
//       backgroundColor: Colors.white,
//       body: SafeArea(
//         child: Column(
//           children: [
//             const Padding(
//               padding: EdgeInsets.fromLTRB(20, 30, 20, 0),
//               child: Align(
//                 alignment: Alignment.centerLeft,
//                 child: Text(
//                   "스케줄 선택",
//                   style: TextStyle(
//                     fontSize: 18,
//                     fontWeight: FontWeight.w600,
//                   ),
//                 ),
//               ),
//             ),
//
//             const SizedBox(height: 18),
//
//             Center(
//               child: Text(
//                 "${nextMonday.month}월 ${nextMonday.day}일 - "
//                     "${nextSunday.month}월 ${nextSunday.day}일",
//                 style: const TextStyle(
//                   fontSize: 20,
//                   fontWeight: FontWeight.w600,
//                 ),
//               ),
//             ),
//
//             const SizedBox(height: 16),
//
//             Container(
//               margin: const EdgeInsets.symmetric(horizontal: 90),
//               padding: const EdgeInsets.symmetric(vertical: 5),
//               decoration: BoxDecoration(
//                 color: const Color(0xFFF1F1F5),
//                 borderRadius: BorderRadius.circular(4),
//               ),
//               child: const Center(
//                 child: Text(
//                   "스케줄 시안 중 1개를 선택해주세요",
//                   style: TextStyle(
//                     color: Color(0xFF767676),
//                     fontSize: 14,
//                     fontWeight: FontWeight.w500,
//                   ),
//                 ),
//               ),
//             ),
//
//             const SizedBox(height: 20),
//
//             Padding(
//               padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
//               child: Row(
//                 children: [
//                   const SizedBox(width: 50),
//                   ...const [
//                     "월", "화", "수", "목", "금", "토", "일",
//                   ].map(
//                         (day) => Expanded(
//                       child: Center(
//                         child: Text(
//                           day,
//                           style: TextStyle(
//                             color: Color(0xFF767676),
//                             fontSize: 12,
//                             fontWeight: FontWeight.w400,
//                           ),
//                         ),
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//
//             Divider(height: 10),
//
//             Expanded(
//               child: RWeekCalendar(
//                 scenarios: scenarios,
//                 selectedIndex: selectedScenario,
//                 preview: widget.preview, // 추가
//                 onSelect: (index) {
//                   setState(() {
//                     selectedScenario = index;
//                   });
//                 },
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }