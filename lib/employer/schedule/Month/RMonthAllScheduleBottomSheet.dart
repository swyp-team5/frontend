import 'package:chack_chack/employer/schedule/Month/RWorkingDetailEditPage.dart';
import 'package:flutter/material.dart';

import '../api/ConfirmedSchedulesApi.dart';
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

  DateTime _mondayOf(DateTime date) {
    return DateTime(date.year, date.month, date.day)
        .subtract(Duration(days: date.weekday - 1));
  }

  /// widget.confirmedWeekScheduleId는 캘린더에서 "현재 선택된 날짜"가 속한
  /// 한 주에 대해서만 조회된 값이라, 월간 뷰에 보이는 다른 주의 shift를 수정할 때
  /// 그대로 쓰면 서버에서 정합성 오류(500)가 날 수 있다.
  /// 그래서 수정하려는 shift의 실제 workDate가 속한 주의 confirmedWeekScheduleId를
  /// 별도로 다시 조회한다.
  ///
  /// NOTE: 서버 응답에서 confirmedWeekScheduleId가 비어있고 weekScheduleId만
  /// 채워지는 경우가 있어, confirmedWeekScheduleId가 null이면 weekScheduleId로
  /// 폴백한다. (백엔드 스펙 확인 후 필요 없다면 이 폴백은 제거해도 됩니다.)
  Future<int?> _resolveConfirmedWeekScheduleIdForShift(DateTime shiftDate) async {
    try {
      final weekly = await ConfirmedSchedulesApi.getConfirmedWeeklySchedule(
        workPlaceId: widget.workPlaceId,
        weekStartDate: _mondayOf(shiftDate),
      );

      debugPrint(
        "[_resolveConfirmedWeekScheduleIdForShift] "
            "confirmedWeekScheduleId=${weekly.confirmedWeekScheduleId}, "
            "weekScheduleId=${weekly.weekScheduleId}",
      );

      return weekly.confirmedWeekScheduleId ?? weekly.weekScheduleId;
    } catch (e) {
      debugPrint("[_resolveConfirmedWeekScheduleIdForShift] 조회 실패: $e");
      return null;
    }
  }

  /// 화면 상단에 배너 형태로 안내 메시지를 띄운다.
  /// SnackBar 대신 MaterialBanner를 사용 (RMainSchedulePage와 동일한 스타일).
  /// 3초 후 자동으로 닫힌다.
  void _showBanner(String message) {
    if (!mounted) return;

    final messenger = ScaffoldMessenger.of(context);

    messenger.clearMaterialBanners();
    messenger.showMaterialBanner(
      MaterialBanner(
        backgroundColor: const Color(0xFFFFF4E5),
        contentTextStyle: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: Color(0xFF9A6700),
        ),
        leading: const Icon(Icons.info_outline, color: Color(0xFFB07500)),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => messenger.hideCurrentMaterialBanner(),
            child: const Text("확인"),
          ),
        ],
      ),
    );

    Future.delayed(const Duration(seconds: 3), () {
      messenger.hideCurrentMaterialBanner();
    });
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
                        // widget.confirmedWeekScheduleId는 다른 주에서 조회된 값일 수 있으므로,
                        // 이 shift(widget.date)가 실제로 속한 주의 값을 다시 조회한다.
                        final resolvedConfirmedWeekScheduleId =
                        await _resolveConfirmedWeekScheduleIdForShift(widget.date);

                        if (resolvedConfirmedWeekScheduleId == null) {
                          _showBanner("근무표 정보를 불러오지 못했어요. 잠시 후 다시 시도해주세요");
                          return;
                        }

                        if (!mounted) return;

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
                              confirmedWeekScheduleId: resolvedConfirmedWeekScheduleId,
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
                  onPressed: () async {
                    final resolvedConfirmedWeekScheduleId =
                    await _resolveConfirmedWeekScheduleIdForShift(widget.date);

                    if (resolvedConfirmedWeekScheduleId == null) {
                      _showBanner("근무표 정보를 불러오지 못했어요. 잠시 후 다시 시도해주세요");
                      return;
                    }

                    if (!mounted) return;

                    showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      backgroundColor: Colors.transparent,
                      builder: (_) {
                        return RDeleteWorkingBottomSheet(
                          workPlaceId: widget.workPlaceId,
                          confirmedWeekScheduleId: resolvedConfirmedWeekScheduleId,
                          works: groups.map((shift) {
                            return DeleteWorkItem(
                              role: shift.timeName,
                              startTime: shift.startTime,
                              endTime: shift.endTime,
                              timeDetailId: shift.timeDetailId,
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