import 'package:flutter/material.dart';

import 'EWeekScheduleCard.dart';

class EWeekGrid extends StatelessWidget {
  final List<DateTime> weekDates;

  /// yyyy-MM-dd -> 근무 목록
  final Map<String, List<dynamic>> schedules;

  /// 휴무일
  final Set<String> holidays;

  /// 개인 / 전체 보기
  final bool isAllView;

  const EWeekGrid({
    super.key,
    required this.weekDates,
    required this.schedules,
    required this.holidays,
    required this.isAllView,
  });

  String _dateKey(DateTime date) {
    return "${date.year.toString().padLeft(4, "0")}-"
        "${date.month.toString().padLeft(2, "0")}-"
        "${date.day.toString().padLeft(2, "0")}";
  }

  int _hour(String time) {
    return int.parse(time.split(":").first);
  }

  double _timeToPosition(String time, int startHour) {
    final parts = time.split(":");

    final hour = int.parse(parts[0]);
    final minute = int.parse(parts[1]);

    return (hour - startHour) * 2 +
        (minute >= 30 ? 1 : 0);
  }

  String _startTime(dynamic e) => e.startTime;

  String _endTime(dynamic e) => e.endTime;

  int get minHour {
    int min = 23;

    for (final list in schedules.values) {
      for (final worker in list) {
        final h = _hour(_startTime(worker));
        if (h < min) min = h;
      }
    }

    return min == 23 ? 0 : min;
  }

  int get maxHour {
    int max = 0;

    for (final list in schedules.values) {
      for (final worker in list) {
        final h = _hour(_endTime(worker));
        if (h > max) max = h;
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
            /// =========================
            /// 시간축 (1시간만 표시)
            /// =========================
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

            /// =========================
            /// 요일별
            /// =========================
            Expanded(
              child: Row(
                children: List.generate(7, (dayIndex) {
                  final key = _dateKey(weekDates[dayIndex]);

                  final workers = schedules[key] ?? [];

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
                          /// =========================
                          /// 30분 셀
                          /// =========================
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

                          /// =========================
                          /// 스케줄 카드
                          /// =========================
                          if (!isHoliday && workers.isNotEmpty)
                            Builder(
                              builder: (_) {
                                final start =
                                workers
                                    .map((e) => _timeToPosition(
                                  e.startTime,
                                  startHour,
                                ))
                                    .reduce((a, b) => a < b ? a : b);

                                final end =
                                workers
                                    .map((e) => _timeToPosition(
                                  e.endTime,
                                  startHour,
                                ))
                                    .reduce((a, b) => a > b ? a : b);

                                return Positioned(
                                  top: start * halfHourHeight,
                                  left: 0,
                                  right: 0,
                                  height:
                                  (end - start) * halfHourHeight,
                                  child: EWeekScheduleCard(
                                    workers: workers,
                                    isAllView: isAllView,
                                  ),
                                );
                              },
                            ),
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