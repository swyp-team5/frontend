import 'package:flutter/material.dart';

import '../Month/RMonthAllSchedulePage.dart';
import 'RWeekScheduleCard.dart';

/// 하루의 근무 그룹(같은 timeName)별 (start, end, shifts) 목록을 받아,
/// 실제로 겹치는 시간대에는 그 시간대에 동시에 진행 중인 모든 그룹의 근무를
/// 합쳐서 하나의 구간으로 만든다. 시간축을 모든 그룹의 시작/끝 지점(breakpoint)
/// 기준으로 잘게 나눈 뒤, 각 조각마다 그 시점에 활성 상태인 그룹들을 모아
/// 하나의 박스로 그리도록 반환한다. 폭은 항상 전체 너비를 그대로 쓴다.
List<(double start, double end, List<RScheduleShift> shifts)>
_mergeOverlappingSegments(
    List<(double start, double end, List<RScheduleShift> shifts)> groups) {
  if (groups.isEmpty) return [];

  final points = <double>{};
  for (final g in groups) {
    points.add(g.$1);
    points.add(g.$2);
  }
  final sortedPoints = points.toList()..sort();

  final result = <(double, double, List<RScheduleShift>)>[];

  for (int i = 0; i < sortedPoints.length - 1; i++) {
    final segStart = sortedPoints[i];
    final segEnd = sortedPoints[i + 1];
    if (segStart >= segEnd) continue;

    final active = <RScheduleShift>[];
    for (final g in groups) {
      if (g.$1 <= segStart && g.$2 >= segEnd) {
        active.addAll(g.$3);
      }
    }

    if (active.isEmpty) continue;

    result.add((segStart, segEnd, active));
  }

  return result;
}

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
                              if (!isHoliday && shifts.isNotEmpty)
                                ...(() {
                                  /// 역할별 그룹핑
                                  final Map<String, List<RScheduleShift>> grouped = {};

                                  for (final shift in shifts) {
                                    grouped.putIfAbsent(shift.timeName, () => []);
                                    grouped[shift.timeName]!.add(shift);
                                  }

                                  // 그룹(역할)별 시간 범위.
                                  final groupRanges = grouped.entries.map((entry) {
                                    final roleShifts = entry.value;

                                    final start = roleShifts
                                        .map((e) => _timeToPosition(e.startTime, startHour))
                                        .reduce((a, b) => a < b ? a : b);

                                    final end = roleShifts
                                        .map((e) => _timeToPosition(e.endTime, startHour))
                                        .reduce((a, b) => a > b ? a : b);

                                    return (start, end, roleShifts);
                                  }).toList();

                                  // 폭은 나누지 않고, 겹치는 시간대에는 그 시간대에
                                  // 동시에 진행 중인 근무들을 모두 합쳐서 한 박스로
                                  // 그린다(원래 있던 근무 + 새로 추가된 근무 모두 표시).
                                  final segments =
                                  _mergeOverlappingSegments(groupRanges);

                                  return segments.map((segment) {
                                    final (start, end, activeShifts) = segment;

                                    return Positioned(
                                      top: start * halfHourHeight,
                                      left: 0,
                                      right: 0,
                                      height: (end - start) * halfHourHeight,
                                      child: RWeekScheduleCard(
                                        shifts: activeShifts,
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