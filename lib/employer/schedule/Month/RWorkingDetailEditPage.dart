import 'package:flutter/material.dart';

import '../REditCalendarBottomSheet.dart';
import '../RScheduleEditPage.dart';
import '../widgets/CalendarBottomSheet.dart';
import '../widgets/WorkerBottomSheet.dart';
import '../models/WorkersResponse.dart';

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

  const RWorkingDetailEditPage({
    super.key,
    required this.role,
    required this.startTime,
    required this.endTime,
    required this.workers,
    required this.breakTime,
    required this.date,
    required this.workPlaceId,
  });

  @override
  State<RWorkingDetailEditPage> createState() =>
      _RWorkingDetailEditPageState();
}

class _RWorkingDetailEditPageState extends State<RWorkingDetailEditPage> {
  late String selectedWorkType;

  late String selectedStartTime;
  late String selectedEndTime;

  String selectedBreakTime = "30분";

  late DateTime selectedDate;

  late List<WorkerItem> workers;

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
              onPressed: () {
                // TODO : 수정 완료 API
                Navigator.pop(
                  context,
                  WorkingEditResult(
                    role: selectedWorkType,
                    startTime: selectedStartTime,
                    endTime: selectedEndTime,
                    breakTime: selectedBreakTime,
                    date: selectedDate,
                    workers: workers,
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1976FF),
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius:
                  BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                "수정 완료",
                style: TextStyle(
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
                          ),
                        ),

                        const SizedBox(width: 10),

                        Expanded(
                          child: _TimeField(
                            label: "퇴근 시간",
                            value: selectedEndTime,
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

/// 시간 입력 박스
class _TimeField extends StatelessWidget {
  final String label;
  final String value;

  const _TimeField({
    required this.label,
    required this.value,
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

        Container(
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
                  color: Color(0xFF999999),
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
      ],
    );
  }
}