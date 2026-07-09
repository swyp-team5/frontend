import 'package:chack_chack/employer/schedule/Month/RWorkingDetailEditPage.dart';
import 'package:flutter/material.dart';

import '../models/WorkersResponse.dart';
import '../widgets/RDeleteWorkingBottomSheet.dart';
import 'RMonthAllSchedulePage.dart';

class RMonthAllScheduleBottomSheet extends StatefulWidget {
  final DateTime date;
  final List<RScheduleShift> workers;
  final Map<String, List<RScheduleShift>> schedules;
  final int workPlaceId;
  final int? confirmedWeekScheduleId;


  const RMonthAllScheduleBottomSheet({
    super.key,
    required this.date,
    required this.workers,
    required this.schedules,
    required this.workPlaceId,
    required this.confirmedWeekScheduleId,
  });

  @override
  State<RMonthAllScheduleBottomSheet> createState() =>
      _RMonthAllScheduleBottomSheetState();
}

class _RMonthAllScheduleBottomSheetState
    extends State<RMonthAllScheduleBottomSheet> {

  String get weekDay {
    const days = ["월","화","수","목","금","토","일"];
    return days[widget.date.weekday - 1];
  }

  String get weekOfMonth {
    final firstDay = DateTime(widget.date.year, widget.date.month, 1);

    final weekNumber =
        ((widget.date.day + firstDay.weekday - 2) ~/ 7) + 1;

    const weekTexts = [
      "",
      "첫째",
      "둘째",
      "셋째",
      "넷째",
      "다섯째",
      "여섯째"
    ];

    return weekTexts[weekNumber];
  }

  String dateKey(DateTime date) {
    return "${date.year.toString().padLeft(4, '0')}-"
        "${date.month.toString().padLeft(2, '0')}-"
        "${date.day.toString().padLeft(2, '0')}";
  }


  @override
  Widget build(BuildContext context) {
    final groups = widget.workers;

    return Container(
      height: widget.workers.isEmpty ? 250 : 450,
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
            width: 48,
            height: 5,
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
                  "${widget.date.month}월 ${widget.date.day}일 $weekDay요일",
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
            padding: const EdgeInsets.symmetric(vertical: 14),
            decoration: const BoxDecoration(
              border: Border(
                top: BorderSide(
                  color: Color(0xFFE9E9EE),
                ),
              ),
            ),
            child: Center(
              child: Text(
                "${widget.date.year}년 ${widget.date.month}월 ${weekOfMonth}주 $weekDay요일",
                style: const TextStyle(
                  fontSize: 14,
                  color: Color(0xFF505050),
                ),
              ),
            ),
          ),

          Expanded(
            child: widget.workers.isEmpty
                ? const Center(
              child: Text(
                "등록된 근무가 없어요",
                style: TextStyle(
                  fontSize: 16,
                  color: Color(0xFF999999),
                ),
              ),
            )
                : ListView.separated(
              padding: const EdgeInsets.all(20),
              itemCount: groups.length,
              separatorBuilder: (_, __) =>
              const SizedBox(height: 20),
              itemBuilder: (_, index) {
                final shift = groups[index];

                return Row(
                  crossAxisAlignment:
                  CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 5,
                      height: 58,
                      decoration: BoxDecoration(
                        color: _workerColor(shift),
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
                            "${shift.timeName} ${shift.startTime} - ${shift.endTime}",
                            style: const TextStyle(
                              fontSize: 14,
                              color: Color(0xFF767676),
                            ),
                          ),
                          const SizedBox(height: 6),
                          RichText(
                            text: TextSpan(
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: Colors.black,
                              ),
                              children: [
                                TextSpan(
                                  text: shift.workers
                                      .map((e) => e.name)
                                      .join(" · "),
                                ),

                                if (shift.shortage)
                                  TextSpan(
                                    text: " · 근무자 부족 ${shift.shortageCount}명",
                                    style: const TextStyle(
                                      color: Color(0xFF767676),
                                      fontSize: 15,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    IconButton(
                      icon: const Icon(
                        Icons.chevron_right,
                        size: 24,
                        color: Color(0xFF1C1C1E),
                      ),
                      onPressed: () async {
                        final result = await Navigator.push<WorkingEditResult>(
                          context,
                          MaterialPageRoute(
                            builder: (_) => RWorkingDetailEditPage(
                              role: shift.timeName,
                              startTime: shift.startTime,
                              endTime: shift.endTime,
                              breakTime: shift.breakTime,
                              date: widget.date,
                              workPlaceId: widget.workPlaceId,
                              confirmedWeekScheduleId: widget.confirmedWeekScheduleId!,
                              timeDetailId: shift.timeDetailId,
                              workPartNo: shift.workPartNo,
                              workers: shift.workers
                                  .map(
                                    (e) => WorkerItem(
                                  memberId: e.memberId,
                                  memberName: e.name,
                                  submitted: true,
                                ),
                              )
                                  .toList(),
                            ),
                          ),
                        );

                        if (result != null) {
                          setState(() {
                            final oldKey = dateKey(widget.date);
                            final newKey = dateKey(result.date);

                            widget.schedules[oldKey]?.remove(shift);

                            if (widget.schedules[oldKey]?.isEmpty ?? false) {
                              widget.schedules.remove(oldKey);
                            }

                            widget.schedules.putIfAbsent(newKey, () => []);

                            final updatedShift = RScheduleShift(
                              timeDetailId: shift.timeDetailId,
                              workPartNo: shift.workPartNo,
                              timeName: result.role,
                              startTime: result.startTime,
                              endTime: result.endTime,
                              breakTime: result.breakTime,
                              colorIndex: shift.colorIndex,
                              required: shift.required,
                              workers: result.workers
                                  .map(
                                    (e) => RScheduleWorker(
                                  memberId: e.memberId,
                                  name: e.memberName,
                                ),
                              )
                                  .toList(),
                            );

                            widget.schedules[newKey]!.add(updatedShift);
                          });
                        }
                      },
                    ),
                  ],
                );
              },
            ),
          ),

          if (widget.workers.isNotEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(
                  20, 0, 20, 20),
              child: SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: () {
                    showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      backgroundColor: Colors.transparent,
                      builder: (_) {
                        return RDeleteWorkingBottomSheet(
                          works: groups.map((shift) {
                            return DeleteWorkItem(
                              role: shift.timeName,
                              startTime: shift.startTime,
                              endTime: shift.endTime,
                              workers: shift.workers
                                  .map((e) => e.name)
                                  .toList(),
                            );
                          }).toList(),

                          onDelete: (selected) {
                            setState(() {
                              for (final index in selected.reversed) {
                                final shift = groups[index];

                                widget.schedules[dateKey(widget.date)]
                                    ?.remove(shift);
                              }
                            });

                            Navigator.pop(context);
                            Navigator.pop(context);
                          },
                        );
                      },
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                    const Color(0xFF1976FF),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius:
                      BorderRadius.circular(12),
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

  /// colorIndex(0~3)에 대응하는 색상 팔레트.
  /// ⚠️ RMainSchedulePage의 _colorIndexForTimeName()에서 배정하는 순서/개수(_colorCount)와
  /// 반드시 일치해야 합니다.
  static const List<Color> _shiftColors = [
    Color(0xFFBFE1FF), // 0
    Color(0xFFD8D1FE), // 1
    Color(0xFFACFBC1), // 2
    Color(0xFFBDBDBD), // 3
  ];

  Color _workerColor(RScheduleShift shift) {
    // 부족하면 빨간색이 최우선
    if (shift.shortage) {
      return const Color(0xFFFF5D5D);
    }

    // "오픈"/"미들"/"마감" 같은 role 문자열 매칭 대신,
    // 상위(RMainSchedulePage)에서 timeName 기준으로 동적 배정한
    // colorIndex를 사용합니다. role은 이제 API의 timeName(자유 텍스트)이라
    // 문자열 switch로는 매칭이 안 되기 때문입니다.
    final index = shift.colorIndex % _shiftColors.length;
    return _shiftColors[index];
  }
}