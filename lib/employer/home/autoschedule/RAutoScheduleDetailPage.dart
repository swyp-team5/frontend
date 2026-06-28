import 'package:flutter/material.dart';

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
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xff1687F8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                "선택하기",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
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

            SizedBox(
              height: 56,
              child: Stack(
                children: [
                  const Align(
                    alignment: Alignment.center,
                    child: Text(
                      "근무 상세",
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 18,
                      ),
                    ),
                  ),

                  Align(
                    alignment: Alignment.centerLeft,
                    child: IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.arrow_back_ios_new),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            Text(
              "${nextMonday.month}월 ${nextMonday.day}일 - "
                  "${nextSunday.month}월 ${nextSunday.day}일",
              style: const TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 22,
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
                    const week = ["월", "화", "수", "목", "금", "토", "일",];

                    return Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            week[index],
                            style: const TextStyle(
                              color: Colors.grey,
                            ),
                          ),

                          const SizedBox(height: 6),

                          Text(
                            "${weekDays[index].day}",
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 20,
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
              ? "${shift.shortageCount}명\n부족"
              : "${shift.available}명",
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