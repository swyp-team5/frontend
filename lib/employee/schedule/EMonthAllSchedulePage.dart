import 'package:flutter/material.dart';

class ScheduleWorker {
  final String name;

  const ScheduleWorker({
    required this.name,
  });
}

class EMonthAllSchedulePage extends StatelessWidget {
  final DateTime selectedDate;
  final ValueChanged<DateTime> onDateChanged;

  /// API 응답
  final Map<String, List<ScheduleWorker>> schedules;

  const EMonthAllSchedulePage({
    super.key,
    required this.selectedDate,
    required this.onDateChanged,
    required this.schedules,
  });

  String _dateKey(DateTime date) {
    return "${date.year.toString().padLeft(4, '0')}-"
        "${date.month.toString().padLeft(2, '0')}-"
        "${date.day.toString().padLeft(2, '0')}";
  }

  @override
  Widget build(BuildContext context) {
    final firstDay = DateTime(
      selectedDate.year,
      selectedDate.month,
      1,
    );

    final lastDay = DateTime(
      selectedDate.year,
      selectedDate.month + 1,
      0,
    );

    final startOffset = firstDay.weekday % 7;

    final prevMonthLast =
    DateTime(selectedDate.year, selectedDate.month, 0);

    final List<DateTime> dates = [];

    for (int i = 0; i < 42; i++) {
      final day = i - startOffset + 1;

      if (day <= 0) {
        dates.add(
          DateTime(
            selectedDate.year,
            selectedDate.month - 1,
            prevMonthLast.day + day,
          ),
        );
      } else if (day > lastDay.day) {
        dates.add(
          DateTime(
            selectedDate.year,
            selectedDate.month + 1,
            day - lastDay.day,
          ),
        );
      } else {
        dates.add(
          DateTime(
            selectedDate.year,
            selectedDate.month,
            day,
          ),
        );
      }
    }

    const weekNames = ["일", "월", "화", "수", "목", "금", "토",];

    return Column(
      children: [
        /// 요일 헤더
        SizedBox(
          height: 36,
          child: Row(
            children: List.generate(
              7,
                  (index) => Expanded(
                child: Center(
                  child: Text(
                    weekNames[index],
                    style: const TextStyle(
                      color: Color(0xFFA7A7A7),
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),

        Expanded(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final cellHeight =
                  constraints.maxHeight / 6;

              return Table(
                defaultVerticalAlignment:
                TableCellVerticalAlignment.top,
                children: List.generate(
                  6,
                      (row) => TableRow(
                    children: List.generate(
                      7,
                          (col) {
                        final date =
                        dates[row * 7 + col];

                        final isCurrentMonth =
                            date.month ==
                                selectedDate.month;

                        final isSelected =
                            date.year ==
                                selectedDate.year &&
                                date.month ==
                                    selectedDate.month &&
                                date.day ==
                                    selectedDate.day;

                        final workers =
                            schedules[_dateKey(date)] ??
                                [];

                        return GestureDetector(
                          onTap: () =>
                              onDateChanged(date),
                          child: Container(
                            height: cellHeight,
                            padding:
                            const EdgeInsets.only(
                              top: 8,
                              left: 4,
                              right: 4,
                            ),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? const Color(
                                  0xFFF2F8FF)
                                  : Colors.white,
                              border: Border(
                                top: BorderSide(
                                  color:
                                  const Color(
                                    0xFFE9E9EE,
                                  ),
                                  width:
                                  row == 0
                                      ? 0
                                      : 1,
                                ),
                              ),
                            ),
                            child: Column(
                              children: [
                                Text(
                                  "${date.day}",
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight:
                                    FontWeight.w600,
                                    color: isSelected
                                        ? const Color(
                                        0xFF1976FF)
                                        : isCurrentMonth
                                        ? Colors
                                        .black
                                        : const Color(
                                        0xFFC8C8D2),
                                  ),
                                ),

                                const SizedBox(height: 4,),

                                if (isCurrentMonth)
                                  Expanded(
                                    child:
                                    _WorkerScheduleArea(
                                      workers: workers,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _WorkerScheduleArea extends StatelessWidget {
  final List<ScheduleWorker> workers;

  const _WorkerScheduleArea({
    required this.workers,
  });

  @override
  Widget build(BuildContext context) {
    if (workers.isEmpty) {
      return const SizedBox();
    }

    final visibleWorkers =
    workers.length >= 5
        ? workers.take(3).toList()
        : workers;

    final remainCount =
    workers.length >= 5
        ? workers.length - 3
        : 0;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (final worker in visibleWorkers)
          Padding(
            padding: const EdgeInsets.only(bottom: 1),
            child: _WorkerChip(worker: worker),
          ),

        if (remainCount > 0)
          Text(
            "+$remainCount",
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: Color(0xFF767676),
            ),
          ),
      ],
    );
  }
}

class _WorkerChip extends StatelessWidget {
  final ScheduleWorker worker;

  const _WorkerChip({
    required this.worker,
  });

  int get colorIndex =>
      worker.name.hashCode.abs() % 3;

  Color get backgroundColor {
    switch (colorIndex) {
      case 0:
        return const Color(0xFFE6F3FF);

      case 1:
        return const Color(0xFFEEEBFF);

      default:
        return const Color(0xFFDCFED8);
    }
  }

  Color get textColor {
    switch (colorIndex) {
      case 0:
        return const Color(0xFF0063BF);

      case 1:
        return const Color(0xFF7D67FD);

      default:
        return const Color(0xFF007360);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 18,
      padding: const EdgeInsets.symmetric(
        horizontal: 6, vertical: 1
      ),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius:
        BorderRadius.circular(8),
      ),
      alignment: Alignment.center,
      child: Text(
        worker.name,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: textColor,
        ),
      ),
    );
  }
}