import 'package:flutter/material.dart';

import 'RMonthAllScheduleBottomSheet.dart';

class RScheduleWorker {
  final int memberId;
  final String name;

  const RScheduleWorker({
    required this.memberId,
    required this.name,
  });
}

int breakTimeLabelToMinutes(String label) {
  switch (label) {
    case "없음":
      return 0;
    case "30분":
      return 30;
    case "1시간":
      return 60;
    case "1시간 30분":
      return 90;
    default:
      return 0;
  }
}

class RScheduleShift {
  final int timeDetailId;
  final int workPartNo;
  String startTime;
  String endTime;
  String timeName;
  String breakTime;
  final int required;  // 필요한 인원
  final List<RScheduleWorker> workers;  // 실제 근무 가능한 직원
  final int colorIndex;

  RScheduleShift({
    required this.timeDetailId,
    required this.workPartNo,
    required this.startTime,
    required this.endTime,
    required this.timeName,
    this.breakTime = "없음",
    required this.required,
    required this.workers,
    required this.colorIndex,
  });

  int get assigned => workers.length;

  bool get shortage => assigned < required;

  int get shortageCount => required - assigned;
}

class RMonthAllSchedulePage extends StatefulWidget {
  final DateTime selectedDate;
  final ValueChanged<DateTime> onDateChanged;
  final Map<String, List<RScheduleShift>> schedules;  // API 응답
  final int workPlaceId;

  const RMonthAllSchedulePage({
    super.key,
    required this.selectedDate,
    required this.onDateChanged,
    required this.schedules,
    required this.workPlaceId,
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
                            workPlaceId: widget.workPlaceId,
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
                        // ⚠️ overflow 방지: 셀 높이가 좁아도 넘치지 않도록 ClipRect로 감쌈
                        child: ClipRect(
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

/// 날짜 셀 안에 표시되는 근무자 칩 영역.
///
/// ⚠️ overflow 수정 포인트:
/// 기존에는 근무자 수가 5명 이상이면 무조건 3개만 보여주도록 고정되어 있었는데,
/// 셀 높이(cellHeight)가 화면 크기에 따라 작아지면 칩 3개 + "+N" 텍스트가
/// 실제 남은 공간(Expanded로 전달된 tight height)보다 커져서
/// "RenderFlex overflowed" 에러가 발생했다.
///
/// 그래서 LayoutBuilder로 실제 사용 가능한 높이를 측정한 뒤,
/// 그 공간에 들어갈 수 있는 만큼만 칩을 동적으로 계산해서 그린다.
class _WorkerScheduleArea extends StatelessWidget {
  final List<RScheduleShift> workers;

  const _WorkerScheduleArea({
    required this.workers,
  });

  // _WorkerChip의 height(18) + Padding bottom(1)
  static const double _chipSlotHeight = 18 + 1;
  // "+N" 텍스트 한 줄이 차지하는 대략적인 높이
  static const double _remainTextHeight = 14;

  @override
  Widget build(BuildContext context) {
    if (workers.isEmpty) {
      return const SizedBox();
    }

    // role 대신 colorIndex를 같이 들고 다님
    final allWorkers = <(RScheduleWorker, int)>[];

    for (final shift in workers) {
      for (final worker in shift.workers) {
        allWorkers.add((worker, shift.colorIndex));
      }
    }

    if (allWorkers.isEmpty) {
      return const SizedBox();
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        // constraints.maxHeight가 무한(infinity)일 가능성은 낮지만
        // 방어적으로 처리 (Expanded 안에서는 항상 유한값이 내려옴)
        final availableHeight = constraints.hasBoundedHeight
            ? constraints.maxHeight
            : allWorkers.length * _chipSlotHeight;

        // 사용 가능한 공간에 들어갈 수 있는 최대 칩 개수 계산
        int maxChipsFit = (availableHeight / _chipSlotHeight).floor();
        if (maxChipsFit < 0) maxChipsFit = 0;

        int visibleCount;
        int remainCount;

        if (allWorkers.length <= maxChipsFit) {
          // 전부 다 보여줄 수 있는 경우
          visibleCount = allWorkers.length;
          remainCount = 0;
        } else {
          // 다 못 보여주는 경우, "+N" 텍스트를 넣을 자리를 확보하기 위해
          // 마지막 한 칸을 남겨둔다.
          visibleCount = (maxChipsFit - 1).clamp(0, allWorkers.length);
          remainCount = allWorkers.length - visibleCount;

          // "+N" 텍스트조차 넣을 공간이 없을 만큼 셀이 작다면
          // 최소 1개는 보여주도록 보정 (완전히 빈 셀 방지)
          if (visibleCount == 0 && maxChipsFit > 0) {
            visibleCount = 1;
            remainCount = allWorkers.length - visibleCount;
          }
        }

        final visibleWorkers = allWorkers.take(visibleCount).toList();

        return ClipRect(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (final item in visibleWorkers)
                Padding(
                  padding: const EdgeInsets.only(bottom: 1),
                  child: _WorkerChip(
                    worker: item.$1,
                    colorIndex: item.$2, // role -> colorIndex
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
          ),
        );
      },
    );
  }
}

class _WorkerChip extends StatelessWidget {
  final RScheduleWorker worker;
  final int colorIndex; // role -> colorIndex

  const _WorkerChip({
    required this.worker,
    required this.colorIndex,
  });

  static const List<Color> _bgColors = [
    Color(0xFFE6F3FF),
    Color(0xFFEEEBFF),
    Color(0xFFDCFED8),
  ];
  static const List<Color> _textColors = [
    Color(0xFF0063BF),
    Color(0xFF7D67FD),
    Color(0xFF007360),
  ];

  Color get backgroundColor =>
      colorIndex < _bgColors.length
          ? _bgColors[colorIndex]
          : const Color(0xFFF2F2F5);

  Color get textColor =>
      colorIndex < _textColors.length
          ? _textColors[colorIndex]
          : Colors.black87;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 18,
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
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