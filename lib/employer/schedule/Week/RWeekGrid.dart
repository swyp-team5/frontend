import 'package:flutter/material.dart';

import '../Month/RMonthAllSchedulePage.dart';
import 'RWeekScheduleCard.dart';

class RWeekGrid extends StatelessWidget {
  final List<DateTime> weekDates;

  /// yyyy-MM-dd -> 근무 목록
  final Map<String, List<RScheduleShift>> schedules;

  /// 휴무일
  final Set<String> holidays;

  const RWeekGrid({
    super.key,
    required this.weekDates,
    required this.schedules,
    required this.holidays,
  });

  String _dateKey(DateTime date) {
    return "${date.year.toString().padLeft(4, "0")}-"
        "${date.month.toString().padLeft(2, "0")}-"
        "${date.day.toString().padLeft(2, "0")}";
  }

  int _hour(String time) {
    return int.parse(time.split(":").first);
  }

  /// 30분 단위 위치 계산
  double _timeToPosition(String time, int startHour) {
    final parts = time.split(":");

    final hour = int.parse(parts[0]);
    final minute = int.parse(parts[1]);

    return (hour - startHour) * 2 +
        (minute >= 30 ? 1 : 0);
  }

  int get minHour {
    int min = 23;

    for (final day in schedules.values) {
      for (final shift in day) {
        final hour = _hour(shift.startTime);

        if (hour < min) {
          min = hour;
        }
      }
    }

    return min == 23 ? 0 : min;
  }

  int get maxHour {
    int max = 0;

    for (final day in schedules.values) {
      for (final shift in day) {
        final hour = _hour(shift.endTime);

        if (hour > max) {
          max = hour;
        }
      }
    }

    return max == 0 ? 24 : max;
  }


  @override
  Widget build(BuildContext context) {
    const halfHourHeight = 40.0;

    final startHour = minHour;
    final endHour = maxHour;

    final hourRows = endHour - startHour;
    final halfRows = hourRows * 2;

    return SingleChildScrollView(
      child: SizedBox(
        height: halfRows * halfHourHeight,
        child: Row(
          children: [
            /// ======================
            /// 시간축
            /// ======================
            SizedBox(
              width: 30,
              child: Column(
                children: List.generate(
                  hourRows,
                      (index) {
                    final hour = startHour + index;

                    return SizedBox(
                      height: halfHourHeight * 2,
                      child: Align(
                        alignment: Alignment.topCenter,
                        child: Text(
                          "$hour",
                          style: const TextStyle(
                            fontSize: 10,
                            color: Colors.grey,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),

            /// ======================
            /// 요일
            /// ======================
            Expanded(
              child: Row(
                children: List.generate(7, (dayIndex) {
                  final date = weekDates[dayIndex];
                  final key = _dateKey(date);

                  final shifts = schedules[key] ?? [];

                  final isHoliday = holidays.contains(key);

                  return Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: isHoliday
                            ? const Color(0xFFF5F5F5)
                            : Colors.white,
                        border: Border(
                          right: BorderSide(
                            color: Colors.grey.shade300,
                            width: .5,
                          ),
                        ),
                      ),
                      child: Stack(
                        children: [
                          /// ======================
                          /// 30분 셀
                          /// ======================
                          Column(
                            children: List.generate(
                              halfRows,
                                  (index) => Container(
                                height: halfHourHeight,
                                decoration: BoxDecoration(
                                  border: Border(
                                    top: BorderSide(
                                      color: Colors.grey.shade300,
                                      width: .5,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),

                          /// ======================
                          /// 스케줄 카드
                          /// ======================
                          // if (!isHoliday && workers.isNotEmpty)
                          //   Builder(
                          //     builder: (_) {
                          //       final start = workers
                          //           .map((e) => _timeToPosition(
                          //         e.startTime,
                          //         startHour,
                          //       ))
                          //           .reduce((a, b) => a < b ? a : b);
                          //
                          //       final end = workers
                          //           .map((e) => _timeToPosition(
                          //         e.endTime,
                          //         startHour,
                          //       ))
                          //           .reduce((a, b) => a > b ? a : b);
                          //
                          //       return Positioned(
                          //         top: start * halfHourHeight,
                          //         left: 0,
                          //         right: 0,
                          //         height: (end - start) * halfHourHeight,
                          //         child: RWeekScheduleCard(
                          //           workers: workers,
                          //         ),
                          //       );
                          //     },
                          //   ),
                          if (!isHoliday && shifts.isNotEmpty)
                            ...(() {

                              /// 역할별 그룹핑
                              final Map<String, List<RScheduleShift>> grouped = {};

                              for (final shift in shifts) {
                                grouped.putIfAbsent(shift.role, () => []);
                                grouped[shift.role]!.add(shift);
                              }

                              return grouped.entries.map((entry) {

                                final roleShifts = entry.value;

                                final start = roleShifts
                                    .map((e) => _timeToPosition(e.startTime, startHour))
                                    .reduce((a, b) => a < b ? a : b);

                                final end = roleShifts
                                    .map((e) => _timeToPosition(e.endTime, startHour))
                                    .reduce((a, b) => a > b ? a : b);

                                return Positioned(
                                  top: start * halfHourHeight,
                                  left: 0,
                                  right: 0,
                                  height: (end - start) * halfHourHeight,
                                  child: RWeekScheduleCard(
                                    shifts: roleShifts,
                                  ),
                                );
                              }).toList();

                            })(),
                        ],
                      ),
                    ),
                  );
                }),
              ),
            ),
          ],
        ),
      ),
    );
  }
}