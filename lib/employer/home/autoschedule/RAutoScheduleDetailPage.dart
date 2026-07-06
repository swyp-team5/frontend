import 'package:flutter/material.dart';

import '../../../common/employer/RAutoScheduleComplete.dart';
import 'models/ScheduleScenario.dart';
import 'models/ShiftCount.dart';
import 'models/ShiftTime.dart';
import 'models/ShiftType.dart';

class RAutoScheduleDetailPage extends StatelessWidget {
  final ScheduleScenario scenario;

  const RAutoScheduleDetailPage({
    super.key,
    required this.scenario,
  });

  static const double hourHeight = 50;

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();

    /// 다음주 월요일
    final nextMonday = DateTime(
      now.year,
      now.month,
      now.day,
    ).add(Duration(days: 8 - now.weekday));

    /// 다음주 날짜
    final weekDays = List.generate(
      7,
          (index) => nextMonday.add(
        Duration(days: index),
      ),
    );

    final nextSunday = weekDays.last;


    return Scaffold(
      backgroundColor: Colors.white,

      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: SizedBox(
            height: 50,
            child: ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const RAutoScheduleComplete(),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0084FF),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                "선택하기",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                  fontSize: 16,
                ),
              ),
            ),
          ),
        ),
      ),

      body: SafeArea(
        child: Column(
          children: [
            //---------------- AppBar ----------------

            Padding(
              padding: const EdgeInsets.fromLTRB(20, 30, 20, 0),
              child: SizedBox(
                height: 32,
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

                    const Center(
                      child: Text(
                        "근무 상세",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            Text(
              "${nextMonday.month}월 ${nextMonday.day}일 - "
                  "${nextSunday.month}월 ${nextSunday.day}일",
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 20,
              ),
            ),

            const SizedBox(height: 20),

            //---------------- 요일 ----------------

            Container(
              height: 70,
              decoration: const BoxDecoration(
                border: Border(
                  top: BorderSide(color: Color(0xffE5E5E5)),
                  bottom: BorderSide(color: Color(0xffE5E5E5)),
                ),
              ),
              child: Row(
                children: [
                  const SizedBox(width: 34),

                  ...List.generate(7, (index) {
                    const week = ["월", "화", "수", "목", "금", "토", "일"];

                    final isOff =
                        scenario.open[index].isOff &&
                            scenario.middle[index].isOff &&
                            scenario.close[index].isOff;

                    return Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            week[index],
                            style: TextStyle(
                              color: isOff ? const Color(0xFF999999) : Colors.black,
                              fontSize: 12,
                              fontWeight: FontWeight.w400,
                            ),
                          ),

                          const SizedBox(height: 6),

                          Text(
                            "${weekDays[index].day}",
                            style: TextStyle(
                              color: isOff ? const Color(0xFF999999) : Colors.black,
                              fontWeight: FontWeight.w600,
                              fontSize: 18,
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                ],
              ),
            ),

            //---------------- 시간표 ----------------

            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final dayWidth =
                      (constraints.maxWidth - 34) / 7;

                  return SingleChildScrollView(
                    child: SizedBox(
                      height: hourHeight * 15,
                      child: Stack(
                        children: [
                          //---------------- Grid ----------------

                          Row(
                            children: [
                              SizedBox(
                                width: 34,
                                child: Column(
                                  children: List.generate(
                                    15,
                                        (index) {
                                      final hour = index + 9;

                                      return Container(
                                        height: hourHeight,
                                        alignment: Alignment.topCenter,
                                        decoration:
                                        const BoxDecoration(
                                          border: Border(
                                            bottom: BorderSide(
                                              color: Color(
                                                  0xffECECEC),
                                            ),
                                          ),
                                        ),
                                        child: Text(
                                          "$hour",
                                          style:
                                          const TextStyle(
                                            fontSize: 10,
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ),

                              Expanded(
                                child: Row(
                                  children: List.generate(
                                    7,
                                        (_) => Expanded(
                                      child: Column(
                                        children:
                                        List.generate(
                                          15,
                                              (_) => Container(
                                            height:
                                            hourHeight,
                                            decoration:
                                            BoxDecoration(
                                              border:
                                              Border(
                                                right:
                                                BorderSide(
                                                  color: Colors
                                                      .grey
                                                      .shade300,
                                                ),
                                                bottom:
                                                BorderSide(
                                                  color: Colors
                                                      .grey
                                                      .shade300,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),

                          //---------------- Shift Blocks ----------------

                          ..._buildShiftBlocks(
                            scenario.open,
                            ShiftType.open,
                            dayWidth,
                          ),

                          ..._buildShiftBlocks(
                            scenario.middle,
                            ShiftType.middle,
                            dayWidth,
                          ),

                          ..._buildShiftBlocks(
                            scenario.close,
                            ShiftType.close,
                            dayWidth,
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _shift({
    required Color color,
    required int day,
    required int start,
    required int end,
    required String text,
    required double dayWidth,
    Color textColor = const Color(0xff2D5BD1),
  }) {
    return Positioned(
      left: 34 + day * dayWidth,
      top: (start - 9) * hourHeight,
      child: Container(
        width: dayWidth,
        height: (end - start) * hourHeight,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: color,
        ),
        child: Text(
          text,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 10,
            color: textColor,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  List<Widget> _buildShiftBlocks(
      List<ShiftCount> list,
      ShiftType type,
      double dayWidth,
      ) {
    final time = getShiftTime(type);

    return List.generate(
      list.length,
          (day) {
        final shift = list[day];

        if (shift.isOff) {
          return const SizedBox.shrink();
        }

        return _shift(
          day: day,
          start: time.start,
          end: time.end,
          dayWidth: dayWidth,
          color: shift.shortage
              ? Colors.redAccent
              : _color(type),
          text: shift.shortage
              ? "${shift.workers.join('\n')}\n(${shift.shortageCount}명 부족)"
              : shift.workers.join('\n'),
          textColor: shift.shortage
              ? Colors.white
              : _textColor(type),
        );
      },
    );
  }

  Color _color(ShiftType type) {
    switch (type) {
      case ShiftType.open:
        return const Color(0xffDCEEFF);

      case ShiftType.middle:
        return const Color(0xffE7E0FF);

      case ShiftType.close:
        return const Color(0xffDDF8D7);
    }
  }

  Color _textColor(ShiftType type) {
    switch (type) {
      case ShiftType.open:
        return const Color(0xff2D5BD1);

      case ShiftType.middle:
        return const Color(0xff6A5BEA);

      case ShiftType.close:
        return const Color(0xff2AA85A);
    }
  }
}

// import 'package:flutter/material.dart';
//
// import '../../../common/employer/RAutoScheduleComplete.dart';
// import 'api/ConfirmedWeekScheduleApi.dart';
// import 'models/ScheduleScenario.dart';
// import 'models/ShiftCount.dart';
// import 'models/ShiftTime.dart';
// import 'models/ShiftType.dart';
//
// class RAutoScheduleDetailPage extends StatefulWidget {
//   final ScheduleScenario scenario;
//   final int workPlaceId;
//   final int weekScheduleId;
//   final int scheduleGenerationRunId;
//   final int schedulePreviewId;
//
//   const RAutoScheduleDetailPage({
//     super.key,
//     required this.scenario,
//     required this.workPlaceId,
//     required this.weekScheduleId,
//     required this.scheduleGenerationRunId,
//     required this.schedulePreviewId,
//   });
//
//   @override
//   State<RAutoScheduleDetailPage> createState() =>
//       _RAutoScheduleDetailPageState();
// }
//
// class _RAutoScheduleDetailPageState extends State<RAutoScheduleDetailPage> {
//   static const double hourHeight = 50;
//
//   bool _isConfirming = false;
//
//   Future<void> _onConfirmTap() async {
//     setState(() => _isConfirming = true);
//
//     debugPrint("=== [RAutoScheduleDetailPage] 스케줄 확정 시작 ===");
//     debugPrint(
//         "workPlaceId=${widget.workPlaceId}, weekScheduleId=${widget.weekScheduleId}, "
//             "scheduleGenerationRunId=${widget.scheduleGenerationRunId}, "
//             "schedulePreviewId=${widget.schedulePreviewId}, "
//             "selectedCandidateNo=${widget.scenario.candidateNo}");
//
//     try {
//       final result = await ConfirmedWeekScheduleApi.confirm(
//         workPlaceId: widget.workPlaceId,
//         weekScheduleId: widget.weekScheduleId,
//         scheduleGenerationRunId: widget.scheduleGenerationRunId,
//         schedulePreviewId: widget.schedulePreviewId,
//         selectedCandidateNo: widget.scenario.candidateNo,
//       );
//
//       debugPrint(
//           "🟢 [RAutoScheduleDetailPage] 확정 성공 — confirmedWeekScheduleId=${result.confirmedWeekScheduleId}, "
//               "assignmentCount=${result.assignmentCount}, status=${result.status}");
//
//       if (!mounted) return;
//
//       Navigator.push(
//         context,
//         MaterialPageRoute(
//           builder: (_) => const RAutoScheduleComplete(),
//         ),
//       );
//     } catch (e) {
//       debugPrint("🔴 [RAutoScheduleDetailPage] 확정 실패: $e");
//
//       if (!mounted) return;
//
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))),
//       );
//     } finally {
//       if (mounted) setState(() => _isConfirming = false);
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final scenario = widget.scenario;
//     final now = DateTime.now();
//
//     /// 다음주 월요일
//     final nextMonday = DateTime(
//       now.year,
//       now.month,
//       now.day,
//     ).add(Duration(days: 8 - now.weekday));
//
//     /// 다음주 날짜
//     final weekDays = List.generate(
//       7,
//           (index) => nextMonday.add(
//         Duration(days: index),
//       ),
//     );
//
//     final nextSunday = weekDays.last;
//
//     return Scaffold(
//       backgroundColor: Colors.white,
//
//       bottomNavigationBar: SafeArea(
//         child: Padding(
//           padding: const EdgeInsets.all(16),
//           child: SizedBox(
//             height: 50,
//             child: ElevatedButton(
//               onPressed: _isConfirming ? null : _onConfirmTap,
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: const Color(0xFF0084FF),
//                 disabledBackgroundColor: const Color(0xFFA9D0FB),
//                 shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(8),
//                 ),
//               ),
//               child: _isConfirming
//                   ? const SizedBox(
//                 width: 22,
//                 height: 22,
//                 child: CircularProgressIndicator(
//                   color: Colors.white,
//                   strokeWidth: 2,
//                 ),
//               )
//                   : const Text(
//                 "선택하기",
//                 style: TextStyle(
//                   color: Colors.white,
//                   fontWeight: FontWeight.w500,
//                   fontSize: 16,
//                 ),
//               ),
//             ),
//           ),
//         ),
//       ),
//
//       body: SafeArea(
//         child: Column(
//           children: [
//             //---------------- AppBar ----------------
//
//             Padding(
//               padding: const EdgeInsets.fromLTRB(20, 30, 20, 0),
//               child: SizedBox(
//                 height: 32,
//                 child: Stack(
//                   alignment: Alignment.center,
//                   children: [
//                     Align(
//                       alignment: Alignment.centerLeft,
//                       child: GestureDetector(
//                         onTap: () => Navigator.pop(context),
//                         child: const Icon(
//                           Icons.arrow_back_ios_new,
//                           size: 22,
//                         ),
//                       ),
//                     ),
//
//                     const Center(
//                       child: Text(
//                         "근무 상세",
//                         style: TextStyle(
//                           fontSize: 18,
//                           fontWeight: FontWeight.w600,
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//
//             const SizedBox(height: 24),
//
//             Text(
//               "${nextMonday.month}월 ${nextMonday.day}일 - "
//                   "${nextSunday.month}월 ${nextSunday.day}일",
//               style: const TextStyle(
//                 fontWeight: FontWeight.w600,
//                 fontSize: 20,
//               ),
//             ),
//
//             const SizedBox(height: 20),
//
//             //---------------- 요일 ----------------
//
//             Container(
//               height: 70,
//               decoration: const BoxDecoration(
//                 border: Border(
//                   top: BorderSide(color: Color(0xffE5E5E5)),
//                   bottom: BorderSide(color: Color(0xffE5E5E5)),
//                 ),
//               ),
//               child: Row(
//                 children: [
//                   const SizedBox(width: 34),
//
//                   ...List.generate(7, (index) {
//                     const week = ["월", "화", "수", "목", "금", "토", "일"];
//
//                     final isOff =
//                         scenario.open[index].isOff &&
//                             scenario.middle[index].isOff &&
//                             scenario.close[index].isOff;
//
//                     return Expanded(
//                       child: Column(
//                         mainAxisAlignment: MainAxisAlignment.center,
//                         children: [
//                           Text(
//                             week[index],
//                             style: TextStyle(
//                               color: isOff ? const Color(0xFF999999) : Colors.black,
//                               fontSize: 12,
//                               fontWeight: FontWeight.w400,
//                             ),
//                           ),
//
//                           const SizedBox(height: 6),
//
//                           Text(
//                             "${weekDays[index].day}",
//                             style: TextStyle(
//                               color: isOff ? const Color(0xFF999999) : Colors.black,
//                               fontWeight: FontWeight.w600,
//                               fontSize: 18,
//                             ),
//                           ),
//                         ],
//                       ),
//                     );
//                   }),
//                 ],
//               ),
//             ),
//
//             //---------------- 시간표 ----------------
//
//             Expanded(
//               child: LayoutBuilder(
//                 builder: (context, constraints) {
//                   final dayWidth =
//                       (constraints.maxWidth - 34) / 7;
//
//                   return SingleChildScrollView(
//                     child: SizedBox(
//                       height: hourHeight * 15,
//                       child: Stack(
//                         children: [
//                           //---------------- Grid ----------------
//
//                           Row(
//                             children: [
//                               SizedBox(
//                                 width: 34,
//                                 child: Column(
//                                   children: List.generate(
//                                     15,
//                                         (index) {
//                                       final hour = index + 9;
//
//                                       return Container(
//                                         height: hourHeight,
//                                         alignment: Alignment.topCenter,
//                                         decoration:
//                                         const BoxDecoration(
//                                           border: Border(
//                                             bottom: BorderSide(
//                                               color: Color(
//                                                   0xffECECEC),
//                                             ),
//                                           ),
//                                         ),
//                                         child: Text(
//                                           "$hour",
//                                           style:
//                                           const TextStyle(
//                                             fontSize: 10,
//                                           ),
//                                         ),
//                                       );
//                                     },
//                                   ),
//                                 ),
//                               ),
//
//                               Expanded(
//                                 child: Row(
//                                   children: List.generate(
//                                     7,
//                                         (_) => Expanded(
//                                       child: Column(
//                                         children:
//                                         List.generate(
//                                           15,
//                                               (_) => Container(
//                                             height:
//                                             hourHeight,
//                                             decoration:
//                                             BoxDecoration(
//                                               border:
//                                               Border(
//                                                 right:
//                                                 BorderSide(
//                                                   color: Colors
//                                                       .grey
//                                                       .shade300,
//                                                 ),
//                                                 bottom:
//                                                 BorderSide(
//                                                   color: Colors
//                                                       .grey
//                                                       .shade300,
//                                                 ),
//                                               ),
//                                             ),
//                                           ),
//                                         ),
//                                       ),
//                                     ),
//                                   ),
//                                 ),
//                               ),
//                             ],
//                           ),
//
//                           //---------------- Shift Blocks ----------------
//
//                           ..._buildShiftBlocks(
//                             scenario.open,
//                             ShiftType.open,
//                             dayWidth,
//                           ),
//
//                           ..._buildShiftBlocks(
//                             scenario.middle,
//                             ShiftType.middle,
//                             dayWidth,
//                           ),
//
//                           ..._buildShiftBlocks(
//                             scenario.close,
//                             ShiftType.close,
//                             dayWidth,
//                           ),
//                         ],
//                       ),
//                     ),
//                   );
//                 },
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   Widget _shift({
//     required Color color,
//     required int day,
//     required int start,
//     required int end,
//     required String text,
//     required double dayWidth,
//     Color textColor = const Color(0xff2D5BD1),
//   }) {
//     return Positioned(
//       left: 34 + day * dayWidth,
//       top: (start - 9) * hourHeight,
//       child: Container(
//         width: dayWidth,
//         height: (end - start) * hourHeight,
//         alignment: Alignment.center,
//         decoration: BoxDecoration(
//           color: color,
//         ),
//         child: Text(
//           text,
//           textAlign: TextAlign.center,
//           style: TextStyle(
//             fontSize: 10,
//             color: textColor,
//             fontWeight: FontWeight.w600,
//           ),
//         ),
//       ),
//     );
//   }
//
//   List<Widget> _buildShiftBlocks(
//       List<ShiftCount> list,
//       ShiftType type,
//       double dayWidth,
//       ) {
//     final time = getShiftTime(type);
//
//     return List.generate(
//       list.length,
//           (day) {
//         final shift = list[day];
//
//         if (shift.isOff) {
//           return const SizedBox.shrink();
//         }
//
//         return _shift(
//           day: day,
//           start: time.start,
//           end: time.end,
//           dayWidth: dayWidth,
//           color: shift.shortage
//               ? Colors.redAccent
//               : _color(type),
//           text: shift.shortage
//               ? "${shift.workers.join('\n')}\n(${shift.shortageCount}명 부족)"
//               : shift.workers.join('\n'),
//           textColor: shift.shortage
//               ? Colors.white
//               : _textColor(type),
//         );
//       },
//     );
//   }
//
//   Color _color(ShiftType type) {
//     switch (type) {
//       case ShiftType.open:
//         return const Color(0xffDCEEFF);
//
//       case ShiftType.middle:
//         return const Color(0xffE7E0FF);
//
//       case ShiftType.close:
//         return const Color(0xffDDF8D7);
//     }
//   }
//
//   Color _textColor(ShiftType type) {
//     switch (type) {
//       case ShiftType.open:
//         return const Color(0xff2D5BD1);
//
//       case ShiftType.middle:
//         return const Color(0xff6A5BEA);
//
//       case ShiftType.close:
//         return const Color(0xff2AA85A);
//     }
//   }
// }