import 'package:flutter/material.dart';

import '../REditCalendarBottomSheet.dart';
import '../RScheduleEditPage.dart';
import '../api/AssignmentApi.dart';
import '../models/WorkersResponse.dart';
import '../models/class AssignmentUpdateRequest.dart';
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

  Future<void> _submitEdit() async {
    setState(() {
      _isSubmitting = true;
    });

    final request = AssignmentUpdateRequest(
      workDate: _formatDate(selectedDate),
      workPartNo: widget.workPartNo,
      timeName: selectedWorkType,
      startTime: selectedStartTime,
      closeTime: selectedEndTime,
      restTime: _parseBreakTimeToMinutes(selectedBreakTime),
      workerMemberIds: workers.map((w) => w.memberId).toList(),
    );

    // 디버그용 로그
    debugPrint(
      "PUT /api/work-places/${widget.workPlaceId}"
          "/confirmed-week-schedules/${widget.confirmedWeekScheduleId}"
          "/time-details/${widget.timeDetailId}/assignments",
    );
    debugPrint("body: ${request.toJson()}");

    try {
      final response = await AssignmentApi.update(
        workPlaceId: widget.workPlaceId,
        confirmedWeekScheduleId: widget.confirmedWeekScheduleId,
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
              onPressed: _isSubmitting ? null : _submitEdit,
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
                _isSubmitting ? "수정 중..." : "수정 완료",
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
                    const Text(
                      "근무 수정 날짜",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
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
                          setState(() {
                            selectedDate = result;
                          });
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