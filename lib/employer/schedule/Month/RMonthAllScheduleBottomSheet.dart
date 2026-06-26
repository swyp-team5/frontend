import 'package:chack_chack/employer/schedule/Month/RWorkingDetailEditPage.dart';
import 'package:flutter/material.dart';

import 'RMonthAllSchedulePage.dart';

class RMonthAllScheduleBottomSheet extends StatelessWidget {
  final DateTime date;
  final List<RScheduleWorker> workers;

  const RMonthAllScheduleBottomSheet({
    super.key,
    required this.date,
    required this.workers,
  });

  String get weekDay {
    const days = ["월", "화", "수", "목", "금", "토", "일",];

    return days[date.weekday - 1];
  }

  String get WeekOfMonth {
    final firstDay = DateTime(date.year, date.month, 1);

    // 해당 월의 첫 주에 포함된 날짜 수 고려
    final weekNumber =
        ((date.day + firstDay.weekday - 2) ~/ 7) + 1;

    const weekTexts = ["", "첫째", "둘째", "셋째", "넷째", "다섯째", "여섯째",];

    return weekTexts[weekNumber];
  }

  @override
  Widget build(BuildContext context) {
    final groupedSchedules = <String, List<RScheduleWorker>>{};

    for (final worker in workers) {
      final key =
          "${worker.role}_${worker.startTime}_${worker.endTime}";

      groupedSchedules.putIfAbsent(key, () => []);
      groupedSchedules[key]!.add(worker);
    }

    return Container(
      height: workers.isEmpty ? 250 : 450,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(24),
        ),
      ),
      child: Column(
        children: [
          const SizedBox(height: 10),

          Container(
            width: 48, height: 5,
            decoration: BoxDecoration(
              color: const Color(0xFFE0E0E0),
              borderRadius: BorderRadius.circular(999),
            ),
          ),

          const SizedBox(height: 24),

          Stack(
            children: [
              Center(
                child: Text(
                  "${date.month}월 ${date.day}일 $weekDay요일",
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),

              Positioned(
                right: 20,
                child: GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    width: 28,
                    height: 28,
                    decoration: const BoxDecoration(
                      color: Color(0xFFF2F2F7),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.close,
                      size: 18,
                      color: Color(0xFFA5A5AF),
                    ),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(
              vertical: 14,
            ),
            decoration: const BoxDecoration(
              border: Border(
                top: BorderSide(
                  color: Color(0xFFE9E9EE),
                ),
              ),
            ),
            child: Center(
              child: Text(
                "${date.year}년 ${date.month}월 $WeekOfMonth주 $weekDay요일",
                style: const TextStyle(
                  fontSize: 14,
                  color: Color(0xFF505050),
                ),
              ),
            ),
          ),

          Expanded(
            child: workers.isEmpty
                ? const Center(
              child: Text(
                "등록된 근무가 없어요",
                style: TextStyle(
                  fontSize: 16,
                  color: Color(0xFF999999),
                ),
              ),
            )
                : Builder(
              builder: (_) {
                final groups = groupedSchedules.entries.toList();

                return ListView.separated(
                  padding: const EdgeInsets.all(20),
                  itemCount: groups.length,
                  separatorBuilder: (_, __) =>
                  const SizedBox(height: 20),
                  itemBuilder: (_, index) {
                    final group = groups[index].value;
                    final first = group.first;

                    final names =
                    group.map((e) => e.name).join(" · ");

                    return Row(
                      crossAxisAlignment:
                      CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 5,
                          height: 58,
                          decoration: BoxDecoration(
                            color: _workerColor(first),
                            borderRadius:
                            BorderRadius.circular(999),
                          ),
                        ),

                        const SizedBox(width: 14),

                        Expanded(
                          child: Column(
                            crossAxisAlignment:
                            CrossAxisAlignment.start,
                            children: [
                              Text(
                                "${first.role} "
                                    "${first.startTime} - ${first.endTime}",
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Color(0xFF767676),
                                ),
                              ),

                              const SizedBox(height: 6),

                              Text(names,
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black,
                                ),
                              ),
                            ],
                          ),
                        ),


                        IconButton(
                          onPressed: () async {

                            final result = await Navigator.push<WorkingEditResult>(
                              context,
                              MaterialPageRoute(
                                builder: (_) => RWorkingDetailEditPage(
                                  role: first.role,
                                  startTime: first.startTime,
                                  endTime: first.endTime,
                                  breakTime: first.breakTime,
                                  workerNames: group
                                      .map((worker) => worker.name)
                                      .toList(),
                                ),
                              ),
                            );

                            if (result != null) {

                              for (final worker in group) {

                                worker.role = result.role;

                                worker.startTime = result.startTime;

                                worker.endTime = result.endTime;

                                worker.breakTime = result.breakTime;
                              }

                              (context as Element).markNeedsBuild();
                            }
                          },
                          icon: const Icon(
                            Icons.chevron_right,
                            size: 24,
                            color: Color(0xFF1C1C1E),
                          ),
                        ),
                      ],
                    );
                  },
                );
              },
            ),
          ),

          if (workers.isNotEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(
                20,
                0,
                20,
                20,
              ),
              child: SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: () {
                    // TODO: 근무 삭제 API
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1976FF),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    "근무 삭제",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Color _workerColor(RScheduleWorker worker) {
    switch (worker.role) {
      case "오픈":
        return const Color(0xFFE6F3FF);

      case "미들":
        return const Color(0xFFEEEBFF);

      case "마감":
        return const Color(0xFFDCFED8);

      default:
        return const Color(0xFFE6F3FF);
    }
  }
}