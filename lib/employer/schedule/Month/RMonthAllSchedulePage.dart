import 'package:flutter/material.dart';

import 'RMonthAllScheduleBottomSheet.dart';

class RScheduleWorker {
  final String name;

  const RScheduleWorker({
    required this.name,
  });
}

class RScheduleShift {
  String startTime;
  String endTime;
  String role;
  String breakTime;
  final int required;  // 필요한 인원
  final List<RScheduleWorker> workers;  // 실제 근무 가능한 직원

  RScheduleShift({
    required this.startTime,
    required this.endTime,
    required this.role,
    this.breakTime = "없음",
    required this.required,
    required this.workers,
  });

  int get assigned => workers.length;

  bool get shortage => assigned < required;

  int get shortageCount => required - assigned;
}

class RMonthAllSchedulePage extends StatefulWidget {
  final DateTime selectedDate;
  final ValueChanged<DateTime> onDateChanged;

  /// API 응답
  final Map<String, List<RScheduleShift>> schedules;

  const RMonthAllSchedulePage({
    super.key,
    required this.selectedDate,
    required this.onDateChanged,
    required this.schedules,
  });

  @override
  State<RMonthAllSchedulePage> createState() =>
      _RMonthAllSchedulePageState();
}

class _RMonthAllSchedulePageState
    extends State<RMonthAllSchedulePage> {

  String _dateKey(DateTime date) {
    return "${date.year.toString().padLeft(4, '0')}-"
        "${date.month.toString().padLeft(2, '0')}-"
        "${date.day.toString().padLeft(2, '0')}";
  }

  @override
  Widget build(BuildContext context) {
    final firstDay = DateTime(
      widget.selectedDate.year,
      widget.selectedDate.month,
      1,
    );

    final lastDay = DateTime(
      widget.selectedDate.year,
      widget.selectedDate.month + 1,
      0,
    );

    final startOffset = firstDay.weekday % 7;

    final prevMonthLast =
    DateTime(widget.selectedDate.year, widget.selectedDate.month, 0);

    final List<DateTime> dates = [];

    for (int i = 0; i < 42; i++) {
      final day = i - startOffset + 1;

      if (day <= 0) {
        dates.add(
          DateTime(
            widget.selectedDate.year,
            widget.selectedDate.month - 1,
            prevMonthLast.day + day,
          ),
        );
      } else if (day > lastDay.day) {
        dates.add(
          DateTime(
            widget.selectedDate.year,
            widget.selectedDate.month + 1,
            day - lastDay.day,
          ),
        );
      } else {
        dates.add(
          DateTime(
            widget.selectedDate.year,
            widget.selectedDate.month,
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
              7, (index) => Expanded(
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
                  6, (row) => TableRow(
                  children: List.generate(
                    7, (col) {
                    final date = dates[row * 7 + col];

                    final isCurrentMonth =
                        date.month == widget.selectedDate.month;

                    final isSelected =
                        date.year == widget.selectedDate.year &&
                            date.month == widget.selectedDate.month &&
                            date.day == widget.selectedDate.day;

                    final workers = widget.schedules[_dateKey(date)] ?? [];

                    final hasShortage = workers.any((shift) => shift.shortage);

                    return GestureDetector(
                      onTap: () async {

                        widget.onDateChanged(date);

                        await showModalBottomSheet(
                          context: context,
                          isScrollControlled: true,
                          backgroundColor: Colors.transparent,
                          builder: (_) => RMonthAllScheduleBottomSheet(
                            date: date,
                            workers: workers,
                            schedules: widget.schedules,
                          ),
                        );

                        setState(() {});
                      },
                      child: Container(
                        height: cellHeight,
                        padding: const EdgeInsets.only(
                          top: 8, left: 4, right: 4,
                        ),
                        decoration: BoxDecoration(
                          color: hasShortage
                              ? const Color(0x33FF2115)
                              : isSelected
                              ? const Color(0xFFF2F8FF)
                              : Colors.white,

                          border: hasShortage
                              ? Border.all(
                            color: const Color(0xFFFF2115),
                            width: 1,
                          )
                              : Border(
                            top: BorderSide(
                              color: const Color(0xFFE9E9EE),
                              width: row == 0 ? 0 : 1,
                            ),
                          ),
                        ),
                        child: Column(
                          children: [
                            Text(
                              "${date.day}",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: isSelected
                                    ? const Color(0xFF1976FF)
                                    : isCurrentMonth
                                    ? Colors.black
                                    : const Color(0xFFC8C8D2),),
                            ),

                            const SizedBox(height: 4,),

                            if (isCurrentMonth)
                              Expanded(
                                child: _WorkerScheduleArea(
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
  final List<RScheduleShift> workers;

  const _WorkerScheduleArea({
    required this.workers,
  });

  @override
  Widget build(BuildContext context) {
    if (workers.isEmpty) {
      return const SizedBox();
    }

    final allWorkers = <MapEntry<RScheduleWorker, String>>[];

    for (final shift in workers) {
      for (final worker in shift.workers) {
        allWorkers.add(
          MapEntry(worker, shift.role),
        );
      }
    }

    final visibleWorkers =
    allWorkers.length >= 5
        ? allWorkers.take(3).toList()
        : allWorkers;

    final remainCount =
    allWorkers.length >= 5
        ? allWorkers.length - 3
        : 0;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (final item in visibleWorkers)
          Padding(
            padding: const EdgeInsets.only(bottom: 1),
            child: _WorkerChip(
              worker: item.key,
              role: item.value,
            ),
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
  final RScheduleWorker worker;
  final String role;

  const _WorkerChip({
    required this.worker,
    required this.role,
  });

  Color get backgroundColor {
    switch (role) {
      case "오픈":
        return const Color(0xFFE6F3FF);

      case "미들":
        return const Color(0xFFEEEBFF);

      case "마감":
        return const Color(0xFFDCFED8);

      default:
        return const Color(0xFFF2F2F5);
    }
  }

  Color get textColor {
    switch (role) {
      case "오픈":
        return const Color(0xFF0063BF);

      case "미들":
        return const Color(0xFF7D67FD);

      case "마감":
        return const Color(0xFF007360);

      default:
        return Colors.black87;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 18,
      padding: const EdgeInsets.symmetric(
        horizontal: 6,
        vertical: 1,
      ),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(8),
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