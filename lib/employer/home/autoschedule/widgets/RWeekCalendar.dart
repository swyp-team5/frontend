import 'package:chack_chack/employer/home/autoschedule/RAutoScheduleDetailPage.dart';
import 'package:flutter/material.dart';

import '../models/ScheduleScenario.dart';
import 'RCalendarRow.dart';

class RWeekCalendar extends StatelessWidget {
  final List<ScheduleScenario> scenarios;
  final int selectedIndex;
  final ValueChanged<int> onSelect;

  const RWeekCalendar({
    super.key,
    required this.scenarios,
    required this.selectedIndex,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: EdgeInsets.zero,
      itemCount: scenarios.length,
      separatorBuilder: (_, __) => Container(
        height: 25,
        color: const Color(0xFFF1F1F5),
      ),
      itemBuilder: (_, index) {
        return RCalendarRow(
          scenario: scenarios[index],
          onTap: () {
            onSelect(index);

            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => RAutoScheduleDetailPage(
                  scenario: scenarios[index],
                ),
              ),
            );
          },
        );
      },
    );
  }
}

// import 'package:chack_chack/employer/home/autoschedule/RAutoScheduleDetailPage.dart';
// import 'package:flutter/material.dart';
//
// import '../models/SchedulePreviewResponse.dart';
// import '../models/ScheduleScenario.dart';
// import 'RCalendarRow.dart';
//
// class RWeekCalendar extends StatelessWidget {
//   final List<ScheduleScenario> scenarios;
//   final int selectedIndex;
//   final ValueChanged<int> onSelect;
//   final SchedulePreviewResponse preview; // 추가
//
//   const RWeekCalendar({
//     super.key,
//     required this.scenarios,
//     required this.selectedIndex,
//     required this.onSelect,
//     required this.preview, // 추가
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     return ListView.separated(
//       padding: EdgeInsets.zero,
//       itemCount: scenarios.length,
//       separatorBuilder: (_, __) => Container(
//         height: 25,
//         color: const Color(0xFFF1F1F5),
//       ),
//       itemBuilder: (_, index) {
//         return RCalendarRow(
//           scenario: scenarios[index],
//           onTap: () {
//             onSelect(index);
//
//             Navigator.push(
//               context,
//               MaterialPageRoute(
//                 builder: (_) => RAutoScheduleDetailPage(
//                   scenario: scenarios[index],
//                   workPlaceId: preview.workPlaceId, // 추가
//                   weekScheduleId: preview.weekScheduleId, // 추가
//                   scheduleGenerationRunId: preview.scheduleGenerationRunId, // 추가
//                   schedulePreviewId: preview.schedulePreviewId, // 추가
//                 ),
//               ),
//             );
//           },
//         );
//       },
//     );
//   }
// }