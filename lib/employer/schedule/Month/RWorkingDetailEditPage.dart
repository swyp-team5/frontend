import 'package:flutter/material.dart';

import '../REditCalendarBottomSheet.dart';
import '../RScheduleEditPage.dart';
import '../api/AssignmentApi.dart';
import '../api/ConfirmedSchedulesApi.dart';
import '../models/WorkersResponse.dart';
import '../models/AssignmentUpdateRequest.dart';
import '../widgets/WorkerBottomSheet.dart';
import '../widgets/WorkingTImeInputBottomSheet.dart';

/// 수정 결과 전달용 모델
class WorkingEditResult {
  final String role;
  final String startTime;
  final String endTime;
  final String breakTime;
  final DateTime date;
  final List<WorkerItem> workers;

  const WorkingEditResult({
    required this.role,
    required this.startTime,
    required this.endTime,
    required this.breakTime,
    required this.date,
    required this.workers,
  });
}

class RWorkingDetailEditPage extends StatefulWidget {
  final String role;
  final String startTime;
  final String endTime;
  final List<WorkerItem> workers;
  final String breakTime;
  final DateTime date;
  final int workPlaceId;

  /// PUT /confirmed-week-schedules/{confirmedWeekScheduleId}/time-details/{timeDetailId}/assignments 에 필요한 값
  /// ⚠️ 이 값은 widget.date(진입 시점 날짜) 기준으로 넘어온 값입니다.
  /// 페이지 안에서 날짜를 다른 주로 바꾸면 더 이상 유효하지 않을 수 있어서,
  /// 제출 직전에 selectedDate 기준으로 다시 조회합니다.
  final int confirmedWeekScheduleId;
  final int timeDetailId;
  final int workPartNo;

  const RWorkingDetailEditPage({
    super.key,
    required this.role,
    required this.startTime,
    required this.endTime,
    required this.workers,
    required this.breakTime,
    required this.date,
    required this.workPlaceId,
    required this.confirmedWeekScheduleId,
    required this.timeDetailId,
    required this.workPartNo,
  });

  @override
  State<RWorkingDetailEditPage> createState() =>
      _RWorkingDetailEditPageState();
}

class _RWorkingDetailEditPageState extends State<RWorkingDetailEditPage> {
  late String selectedWorkType;

  late String selectedStartTime;
  late String selectedEndTime;

  late String selectedBreakTime;

  late DateTime selectedDate;

  late List<WorkerItem> workers;

  bool _isSubmitting = false;

  /// selectedDate가 속한 주의 진짜 confirmedWeekScheduleId.
  /// 처음엔 widget.confirmedWeekScheduleId(=widget.date 기준 값)로 초기화하고,
  /// selectedDate가 바뀔 때마다 다시 조회해서 갱신한다.
  int? _confirmedWeekScheduleIdForSelectedDate;
  bool _isResolvingWeekSchedule = false;

  final List<String> workTypes = ["오픈", "미들", "마감",];

  final List<String> breakTimes = ["없음", "30분", "1시간", "1시간 30분",];

  @override
  void initState() {
    super.initState();

    selectedWorkType = widget.role;

    selectedStartTime = widget.startTime;
    selectedEndTime = widget.endTime;

    selectedBreakTime = widget.breakTime;

    workers = List.from(widget.workers);

    selectedDate = widget.date;

    _confirmedWeekScheduleIdForSelectedDate = widget.confirmedWeekScheduleId;
  }

  TimeOfDay _toTimeOfDay(String time) {
    final parts = time.split(":");

    return TimeOfDay(
      hour: int.parse(parts[0]),
      minute: int.parse(parts[1]),
    );
  }

  /// "없음" -> 0, "30분" -> 30, "1시간" -> 60, "1시간 30분" -> 90
  int _parseBreakTimeToMinutes(String value) {
    if (value == "없음" || value.trim().isEmpty) return 0;

    final hourMatch = RegExp(r'(\d+)\s*시간').firstMatch(value);
    final minuteMatch = RegExp(r'(\d+)\s*분').firstMatch(value);

    final hours = hourMatch != null ? int.parse(hourMatch.group(1)!) : 0;
    final minutes = minuteMatch != null ? int.parse(minuteMatch.group(1)!) : 0;

    if (hours == 0 && minutes == 0) {
      final numeric = RegExp(r'\d+').firstMatch(value);
      return numeric != null ? int.parse(numeric.group(0)!) : 0;
    }

    return hours * 60 + minutes;
  }

  String _formatDate(DateTime date) {
    return "${date.year.toString().padLeft(4, '0')}-"
        "${date.month.toString().padLeft(2, '0')}-"
        "${date.day.toString().padLeft(2, '0')}";
  }

  DateTime _mondayOf(DateTime date) {
    return DateTime(date.year, date.month, date.day)
        .subtract(Duration(days: date.weekday - 1));
  }

  /// selectedDate가 속한 주의 confirmedWeekScheduleId를 다시 조회한다.
  /// (weekScheduleId도 함께 확인해서 null이면 로그를 남긴다.)
  Future<int?> _resolveConfirmedWeekScheduleId(DateTime date) async {
    try {
      final weekly = await ConfirmedSchedulesApi.getConfirmedWeeklySchedule(
        workPlaceId: widget.workPlaceId,
        weekStartDate: _mondayOf(date),
      );

      debugPrint(
        "[_resolveConfirmedWeekScheduleId] date=$date -> "
            "confirmedWeekScheduleId=${weekly.confirmedWeekScheduleId}, "
            "weekScheduleId=${weekly.weekScheduleId}",
      );

      if (weekly.confirmedWeekScheduleId == null ||
          weekly.weekScheduleId == null) {
        debugPrint(
          "[_resolveConfirmedWeekScheduleId] ⚠️ 이 날짜가 속한 주는 아직 "
              "확정된 근무표가 없습니다 (confirmedWeekScheduleId 또는 "
              "weekScheduleId가 null).",
        );
        return null;
      }

      return weekly.confirmedWeekScheduleId;
    } catch (e) {
      debugPrint("[_resolveConfirmedWeekScheduleId] 조회 실패: $e");
      return null;
    }
  }

  /// 선택한 날짜(date)의 기존 확정 근무표를 조회해서
  /// 같은 timeName이 이미 있으면 그 workPartNo를 재사용하고,
  /// 없으면 새로운 workPartNo(기존 최댓값 + 1)를 부여한다.
  /// 단, 지금 수정 중인 항목(widget.timeDetailId) 자신은 비교 대상에서 제외한다.
  Future<int> _resolveWorkPartNo({
    required DateTime date,
    required String timeName,
  }) async {
    try {
      final response = await ConfirmedSchedulesApi.getConfirmedSchedules(
        workPlaceId: widget.workPlaceId,
        from: date,
        to: date,
      );

      final targetDate = _formatDate(date);

      final matchedDays =
      response.days.where((d) => d.workDate == targetDate).toList();

      if (matchedDays.isEmpty || matchedDays.first.timeDetails.isEmpty) {
        return 1;
      }

      // 자기 자신(widget.timeDetailId)은 제외하고 비교
      final timeDetails = matchedDays.first.timeDetails
          .where((t) => t.timeDetailId != widget.timeDetailId)
          .toList();

      if (timeDetails.isEmpty) {
        return 1;
      }

      // 같은 timeName이 이미 있으면 그 workPartNo 재사용
      final existing =
      timeDetails.where((t) => t.timeName == timeName).toList();

      if (existing.isNotEmpty) {
        return existing.first.workPartNo;
      }

      // 없으면 기존 workPartNo 중 최댓값 + 1
      final maxPartNo = timeDetails
          .map((t) => t.workPartNo)
          .reduce((a, b) => a > b ? a : b);

      return maxPartNo + 1;
    } catch (e) {
      debugPrint("[_resolveWorkPartNo] 조회 실패: $e");
      // 조회 실패 시 기존에 전달받은 workPartNo로 폴백
      return widget.workPartNo;
    }
  }

  Future<void> _showSelectSheet({
    required String title,
    required List<String> items,
    required ValueChanged<String> onSelected,
  }) async {
    final result = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(24),
        ),
      ),
      builder: (_) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 12),

              Container(
                width: 48,
                height: 5,
                decoration: BoxDecoration(
                  color: const Color(0xFFE0E0E0),
                  borderRadius: BorderRadius.circular(999),
                ),
              ),

              const SizedBox(height: 20),

              Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),

              const SizedBox(height: 20),

              ...items.map(
                    (item) => ListTile(
                  title: Center(
                    child: Text(
                      item,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  onTap: () {
                    Navigator.pop(context, item);
                  },
                ),
              ),

              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );

    if (result != null) {
      onSelected(result);
    }
  }

  Future<void> _pickTime() async {
    final result = await WorkingTimeInputBottomSheet.show(
      context,
      initialOpenTime: _toTimeOfDay(selectedStartTime),
      initialCloseTime: _toTimeOfDay(selectedEndTime),
    );

    if (result != null) {
      setState(() {
        selectedStartTime =
        "${result.openTime.hour.toString().padLeft(2, '0')}:${result.openTime.minute.toString().padLeft(2, '0')}";
        selectedEndTime =
        "${result.closeTime.hour.toString().padLeft(2, '0')}:${result.closeTime.minute.toString().padLeft(2, '0')}";
      });
    }
  }

  Future<void> _onDateChanged(DateTime newDate) async {
    setState(() {
      selectedDate = newDate;
      _isResolvingWeekSchedule = true;
      _confirmedWeekScheduleIdForSelectedDate = null;
    });

    final resolved = await _resolveConfirmedWeekScheduleId(newDate);

    if (!mounted) return;

    setState(() {
      _confirmedWeekScheduleIdForSelectedDate = resolved;
      _isResolvingWeekSchedule = false;
    });

    if (resolved == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("선택한 날짜의 근무표 정보를 불러오지 못했어요. 다른 날짜를 선택해주세요"),
        ),
      );
    }
  }

  Future<void> _submitEdit() async {
    // 제출 직전, selectedDate 기준 confirmedWeekScheduleId를 최종적으로 다시 한 번 확인한다.
    // (날짜를 바꾼 적이 없어도, 페이지에 오래 머무는 동안 서버 상태가 바뀌었을 수 있으므로
    // 안전하게 다시 조회한다.)
    setState(() {
      _isSubmitting = true;
    });

    final resolvedConfirmedWeekScheduleId =
    await _resolveConfirmedWeekScheduleId(selectedDate);

    if (resolvedConfirmedWeekScheduleId == null) {
      if (!mounted) return;

      setState(() {
        _isSubmitting = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("선택한 날짜의 근무표 정보를 확인할 수 없어요. 날짜를 다시 선택해주세요"),
        ),
      );
      return;
    }

    setState(() {
      _confirmedWeekScheduleIdForSelectedDate = resolvedConfirmedWeekScheduleId;
    });

    final workPartNo = await _resolveWorkPartNo(
      date: selectedDate,
      timeName: selectedWorkType,
    );

    final request = AssignmentUpdateRequest(
      workDate: _formatDate(selectedDate),
      workPartNo: workPartNo,
      timeName: selectedWorkType,
      startTime: selectedStartTime,
      closeTime: selectedEndTime,
      restTime: _parseBreakTimeToMinutes(selectedBreakTime),
      workerMemberIds: workers.map((w) => w.memberId).toList(),
    );

    // 디버그용 로그
    debugPrint(
      "PUT /api/work-places/${widget.workPlaceId}"
          "/confirmed-week-schedules/$resolvedConfirmedWeekScheduleId"
          "/time-details/${widget.timeDetailId}/assignments",
    );
    debugPrint("body: ${request.toJson()}");

    try {
      final response = await AssignmentApi.update(
        workPlaceId: widget.workPlaceId,
        confirmedWeekScheduleId: resolvedConfirmedWeekScheduleId,
        timeDetailId: widget.timeDetailId,
        request: request,
      );

      if (!mounted) return;

      Navigator.pop(
        context,
        WorkingEditResult(
          role: response.timeName,
          startTime: response.startTime.length >= 5
              ? response.startTime.substring(0, 5)
              : response.startTime,
          endTime: response.closeTime.length >= 5
              ? response.closeTime.substring(0, 5)
              : response.closeTime,
          breakTime: selectedBreakTime,
          date: selectedDate,
          workers: workers,
        ),
      );
    } catch (e) {
      debugPrint("근무 수정 실패 : $e");

      if (!mounted) return;

      setState(() {
        _isSubmitting = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString().replaceFirst("Exception: ", ""))),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final canSubmit =
        !_isSubmitting && !_isResolvingWeekSchedule;

    return Scaffold(
      backgroundColor: Colors.white,

      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            20, 0, 20, 30,
          ),
          child: SizedBox(
            height: 52,
            child: ElevatedButton(
              onPressed: canSubmit ? _submitEdit : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1976FF),
                disabledBackgroundColor:
                const Color(0xFF1976FF).withOpacity(0.5),
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius:
                  BorderRadius.circular(12),
                ),
              ),
              child: Text(
                _isSubmitting
                    ? "수정 중..."
                    : (_isResolvingWeekSchedule ? "근무표 확인 중..." : "수정 완료"),
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ),
      ),

      body: SafeArea(
        child: Column(
          children: [
            /// Header
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 30,
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: const Icon(
                        Icons.arrow_back_ios_new,
                        size: 22,
                      ),
                    ),
                  ),

                  const Center(
                    child: Text(
                      "근무 상세 수정",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                padding:
                const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 20,
                ),
                child: Column(
                  crossAxisAlignment:
                  CrossAxisAlignment.start,
                  children: [
                    /// 근무 타임
                    const Text("근무 타임",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),

                    const SizedBox(height: 12),

                    _DropdownBox(
                      value: selectedWorkType,
                      onTap: () {
                        _showSelectSheet(
                          title: "근무 타임 선택",
                          items: workTypes,
                          onSelected: (value) {
                            setState(() {
                              selectedWorkType = value;
                            });
                          },
                        );
                      },
                    ),

                    const SizedBox(height: 28),

                    /// 근무 시간
                    const Text(
                      "근무 시간",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),

                    const SizedBox(height: 12),

                    Row(
                      children: [
                        Expanded(
                          child: _TimeField(
                            label: "출근 시간",
                            value: selectedStartTime,
                            onTap: _pickTime,
                          ),
                        ),

                        const SizedBox(width: 10),

                        Expanded(
                          child: _TimeField(
                            label: "퇴근 시간",
                            value: selectedEndTime,
                            onTap: _pickTime,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 28),

                    /// 휴게 시간
                    const Text(
                      "휴게 시간",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),

                    const SizedBox(height: 12),

                    _DropdownBox(
                      value: selectedBreakTime,
                      onTap: () {
                        _showSelectSheet(
                          title: "휴게 시간 선택",
                          items: breakTimes,
                          onSelected: (value) {
                            setState(() {
                              selectedBreakTime = value;
                            });
                          },
                        );
                      },
                    ),

                    const SizedBox(height: 28),

                    /// 근무 수정 날짜
                    Row(
                      children: [
                        const Text(
                          "근무 수정 날짜",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        if (_isResolvingWeekSchedule) ...[
                          const SizedBox(width: 8),
                          const SizedBox(
                            width: 14,
                            height: 14,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                        ],
                      ],
                    ),

                    const SizedBox(height: 12),

                    _DropdownBox(
                      value:
                      "${selectedDate.month.toString().padLeft(2, '0')}."
                          "${selectedDate.day.toString().padLeft(2, '0')}",
                      onTap: () async {
                        final result = await showModalBottomSheet<DateTime>(
                          context: context,
                          isScrollControlled: true,
                          backgroundColor: Colors.white,
                          builder: (_) => REditCalendarBottomSheet(
                            initialDate: selectedDate,
                          ),
                        );

                        if (result != null) {
                          await _onDateChanged(result);
                        }
                      },
                    ),

                    const SizedBox(height: 28),

                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const Text(
                          "근무자",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),

                        const Spacer(),

                        GestureDetector(
                          onTap: () async {
                            final result = await WorkerBottomSheet.show(
                              context,
                              workPlaceId: widget.workPlaceId,
                              initialSelected: workers,
                            );

                            if (result != null) {
                              setState(() {
                                workers = result;
                              });
                            }
                          },
                          child: Row(
                            children: [
                              Wrap(
                                spacing: 8,
                                children: workers.map((worker) {
                                  return Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 6,
                                    ),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFF7F7FB),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      worker.memberName,
                                      style: const TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w500,
                                        color: Color(0xFF00315F),
                                      ),
                                    ),
                                  );
                                }).toList(),
                              ),

                              const SizedBox(width: 8),

                              const Icon(
                                Icons.chevron_right,
                                size: 24,
                              ),
                            ],
                          ),
                        ),
                      ],
                    )
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// 드롭다운 형태 박스
class _DropdownBox extends StatelessWidget {
  final String value;
  final VoidCallback onTap;

  const _DropdownBox({
    required this.value,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius:
      BorderRadius.circular(12),
      child: Container(
        height: 56,
        padding:
        const EdgeInsets.symmetric(
          horizontal: 16,
        ),
        decoration: BoxDecoration(
          border: Border.all(
            color: const Color(0xFFD7DCE5),
          ),
          borderRadius:
          BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Text(
              value,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),

            const Spacer(),

            const Icon(
              Icons.keyboard_arrow_down,
            ),
          ],
        ),
      ),
    );
  }
}

/// 시간 입력 박스 (탭하면 시간 선택 바텀시트 오픈)
class _TimeField extends StatelessWidget {
  final String label;
  final String value;
  final VoidCallback onTap;

  const _TimeField({
    required this.label,
    required this.value,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment:
      CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: Color(0xFF767676),
          ),
        ),

        const SizedBox(height: 8),

        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            height: 56,
            padding:
            const EdgeInsets.symmetric(
              horizontal: 16,
            ),
            decoration: BoxDecoration(
              color: const Color(0xFFF1F1F5),
              borderRadius:
              BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 16,
                    color: Color(0xFF333333),
                  ),
                ),

                const Spacer(),

                const Icon(
                  Icons.access_time_outlined,
                  color: Color(0xFF9DA3AF),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}