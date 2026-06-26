import 'package:flutter/material.dart';

import '../Month/RMonthAllSchedulePage.dart';
import 'RWeekScheduleCard.dart';

class RWeekGrid extends StatelessWidget {
  final List<DateTime> weekDates;

  /// yyyy-MM-dd -> 근무 목록
  final Map<String, List<RScheduleWorker>> schedules;

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

  int get minHour {
    int min = 23;

    for (final day in schedules.values) {
      for (final worker in day) {
        final hour = _hour(worker.startTime);
        if (hour < min) {
          min = hour;
        }
      }
    }

    return min;
  }

  int get maxHour {
    int max = 0;

    for (final day in schedules.values) {
      for (final worker in day) {
        final hour = _hour(worker.endTime);
        if (hour > max) {
          max = hour;
        }
      }
    }

    return max;
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
            /// ======================
            /// 시간축
            /// ======================
            SizedBox(
              width: 30,
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

            /// ======================
            /// 요일
            /// ======================
            Expanded(
              child: Row(
                children: List.generate(7, (dayIndex) {
                  final date = weekDates[dayIndex];
                  final key = _dateKey(date);

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
                          /// 시간 셀
                          Column(
                            children: List.generate(
                              totalRows,
                                  (index) => Container(
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

                          /// 휴무가 아니고 근무가 있을 때만 카드 표시
                          if (!isHoliday && workers.isNotEmpty)
                            Builder(
                              builder: (_) {
                                final startHour = workers
                                    .map((e) => _hour(e.startTime))
                                    .reduce((a, b) => a < b ? a : b);

                                final endHour = workers
                                    .map((e) => _hour(e.endTime))
                                    .reduce((a, b) => a > b ? a : b);

                                final workerStartHour = workers
                                    .map((e) => _hour(e.startTime))
                                    .reduce((a, b) => a < b ? a : b);

                                final workerEndHour = workers
                                    .map((e) => _hour(e.endTime))
                                    .reduce((a, b) => a > b ? a : b);

                                return Positioned(
                                  top: (workerStartHour - startHour) * cellHeight,
                                  left: 0,
                                  right: 0,
                                  height: (workerEndHour - workerStartHour) * cellHeight,
                                  child: RWeekScheduleCard(
                                    workers: workers,
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