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

  String _startTime(dynamic e) => e.startTime;
  String _endTime(dynamic e) => e.endTime;
  String _name(dynamic e) => e.name;

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
    const cellHeight = 80.0;

    final startHour = minHour;
    final endHour = maxHour;
    final totalRows = endHour - startHour;

    return SingleChildScrollView(
      child: SizedBox(
        height: totalRows * cellHeight,
        child: Row(
          children: [
            /// 시간축
            SizedBox(
              width: 28,
              child: Column(
                children: List.generate(
                  totalRows,
                      (index) {
                    final hour = startHour + index;

                    return SizedBox(
                      height: cellHeight,
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

            Expanded(
              child: Row(
                children: List.generate(7, (dayIndex) {
                  final key = _dateKey(weekDates[dayIndex]);

                  final List<dynamic> workers =
                      schedules[key] ?? <dynamic>[];

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
                          /// 시간 셀
                          Column(
                            children: List.generate(
                              totalRows,
                                  (_) => Container(
                                height: cellHeight,
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

                          if (!isHoliday && workers.isNotEmpty)
                            Builder(
                              builder: (_) {
                                final firstHour = workers
                                    .map((e) => _hour(_startTime(e)))
                                    .reduce((a, b) => a < b ? a : b);

                                final lastHour = workers
                                    .map((e) => _hour(_endTime(e)))
                                    .reduce((a, b) => a > b ? a : b);

                                return Positioned(
                                  top: (firstHour - startHour) * cellHeight,
                                  left: 0,
                                  right: 0,
                                  height: (lastHour - firstHour) * cellHeight,
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