import 'package:chack_chack/employer/schedule/widgets/BreakTimeBottomSheet.dart';
import 'package:chack_chack/employer/schedule/widgets/CalendarBottomSheet.dart';
import 'package:chack_chack/employer/schedule/widgets/RegisterScheduleBottomSheet.dart';
import 'package:chack_chack/employer/schedule/widgets/WorkerBottomSheet.dart';
import 'package:chack_chack/employer/schedule/widgets/WorkingTImeInputBottomSheet.dart';
import 'package:flutter/material.dart';

import 'api/AssignmentApi.dart';
import 'api/ConfirmedSchedulesApi.dart';
import 'api/WorkersApi.dart';
import 'models/AssignmentCreateRequest.dart';
import 'models/WorkersResponse.dart';
import 'widgets/RCompleteButton.dart';
import 'widgets/RDropdownField.dart';
import 'widgets/RInputBox.dart';
import 'widgets/RTimeField.dart';
import 'models/schedule_model.dart';

class RAddSchedulePage extends StatefulWidget {
  final int workPlaceId;
  final int confirmedWeekScheduleId;

  const RAddSchedulePage({
    super.key,
    required this.workPlaceId,
    required this.confirmedWeekScheduleId,
  });

  @override
  State<RAddSchedulePage> createState() => _RAddSchedulePageState();
}

class _RAddSchedulePageState extends State<RAddSchedulePage> {

  final TextEditingController workNameController =
  TextEditingController();

  String startTime = "00:00";
  String endTime = "00:00";

  String breakTime = "없음";

  List<DateTime> selectedDates = [];
  List<WorkerItem> selectedWorkers = [];

  bool _isSubmitting = false;


  bool get canSubmit {
    return workNameController.text.isNotEmpty &&
        selectedWorkers.isNotEmpty &&
        selectedDates.isNotEmpty &&
        !_isSubmitting;
  }

  TimeOfDay _toTimeOfDay(String time) {
    final parts = time.split(":");

    return TimeOfDay(
      hour: int.parse(parts[0]),
      minute: int.parse(parts[1]),
    );
  }

  /// "없음" -> 0, "30분" -> 30, "1시간" -> 60 처럼
  /// 화면에 표시되는 휴게시간 문자열에서 분(minute) 단위 숫자만 추출.
  int _parseBreakTimeToMinutes(String value) {
    if (value == "없음" || value.trim().isEmpty) return 0;

    final hourMatch = RegExp(r'(\d+)\s*시간').firstMatch(value);
    final minuteMatch = RegExp(r'(\d+)\s*분').firstMatch(value);

    final hours = hourMatch != null ? int.parse(hourMatch.group(1)!) : 0;
    final minutes = minuteMatch != null ? int.parse(minuteMatch.group(1)!) : 0;

    if (hours == 0 && minutes == 0) {
      // 위 패턴에 안 걸리면 숫자만 그대로 파싱 시도
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

  /// 선택한 날짜(date)의 기존 확정 근무표를 조회해서
  /// 같은 timeName이 이미 있으면 그 workPartNo를 재사용하고,
  /// 없으면 새로운 workPartNo(기존 최댓값 + 1)를 부여한다.
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
        // 해당 날짜에 등록된 타임이 없으면 1번부터 시작
        return 1;
      }

      final timeDetails = matchedDays.first.timeDetails;

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
      // 조회 실패 시 기본값(1)으로 폴백
      return 1;
    }
  }

  List<WorkerItem> workers = [];

  Future<void> _loadWorkers() async {
    try {
      final result = await WorkersApi.getWorkers(
        workPlaceId: widget.workPlaceId,
      );

      debugPrint("받아온 근무자 수 : ${result.workers.length}");

      for (final worker in result.workers) {
        debugPrint(worker.memberName);
      }

      if (!mounted) return;

      setState(() {
        workers = result.workers;
      });

      debugPrint("state workers : ${workers.length}");
    } catch (e) {
      debugPrint("근무자 조회 실패");
      debugPrint(e.toString());
    }
  }

  Future<void> _submitSchedule() async {
    setState(() {
      _isSubmitting = true;
    });

    try {
      final memberIds = selectedWorkers.map((w) => w.memberId).toList();
      final restTime = _parseBreakTimeToMinutes(breakTime);

      // AssignmentCreateRequest는 날짜 하나당 요청 하나이므로,
      // 선택된 날짜 수만큼 순차적으로 등록.
      for (final date in selectedDates) {
        final workPartNo = await _resolveWorkPartNo(
          date: date,
          timeName: workNameController.text,
        );

        await AssignmentApi.create(
          workPlaceId: widget.workPlaceId,
          confirmedWeekScheduleId: widget.confirmedWeekScheduleId,
          request: AssignmentCreateRequest(
            workDate: _formatDate(date),
            workPartNo: workPartNo, // 동적으로 조회한 값 사용
            timeName: workNameController.text,
            startTime: startTime,
            closeTime: endTime,
            restTime: restTime,
            workerMemberIds: memberIds,
          ),
        );
      }

      if (!mounted) return;

      Navigator.pop(
        context,
        ScheduleModel(
          workName: workNameController.text,
          startTime: startTime,
          endTime: endTime,
          breakTime: breakTime,
          dates: selectedDates,
          workers: List<WorkerItem>.from(selectedWorkers),
        ),
      );
    } catch (e) {
      debugPrint("근무 등록 실패 : $e");

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
  void initState() {
    super.initState();

    _loadWorkers();
  }

  @override
  void dispose() {
    workNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: Colors.white,

      body: SafeArea(
        child: Column(
          children: [
            /// ==========================
            /// 상단 헤더
            /// ==========================
            Padding(
              padding: const EdgeInsets.fromLTRB(30, 30, 20, 0),
              child: SizedBox(
                height: 30,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    /// 가운데 제목
                    const Center(
                      child: Text(
                        "새 근무 추가",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),

                    /// 왼쪽 뒤로가기
                    Align(
                      alignment: Alignment.centerLeft,
                      child: InkWell(
                        onTap: () => Navigator.pop(context),
                        child: const Icon(
                          Icons.arrow_back_ios_new,
                          size: 22,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            /// ==========================
            /// 내용
            /// ==========================
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 32),

                    /// 근무명
                    const Text(
                      "근무명",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),

                    const SizedBox(height: 12),

                    RInputBox(
                      controller: workNameController,
                      hintText: "입력하기",
                      onChanged: (_) => setState(() {}),
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
                          child: RTimeField(
                            title: "출근 시간",
                            time: startTime,
                            onTap: () async {
                              final result =
                              await WorkingTimeInputBottomSheet.show(
                                context,
                                initialOpenTime: _toTimeOfDay(startTime),
                                initialCloseTime: _toTimeOfDay(endTime),
                              );

                              if (result != null) {
                                setState(() {
                                  startTime =
                                  "${result.openTime.hour.toString().padLeft(2, '0')}:${result.openTime.minute.toString().padLeft(2, '0')}";

                                  endTime =
                                  "${result.closeTime.hour.toString().padLeft(2, '0')}:${result.closeTime.minute.toString().padLeft(2, '0')}";
                                });
                              }

                              if (result != null) {
                                setState(() {
                                  startTime =
                                  "${result.openTime.hour.toString().padLeft(2, '0')}:${result.openTime.minute.toString().padLeft(2, '0')}";
                                });
                              }
                            },
                          ),
                        ),

                        const SizedBox(width: 12),

                        Expanded(
                          child: RTimeField(
                            title: "퇴근 시간",
                            time: endTime,
                            onTap: () async {
                              final result =
                              await WorkingTimeInputBottomSheet.show(
                                context,
                                initialOpenTime: _toTimeOfDay(startTime),
                                initialCloseTime: _toTimeOfDay(endTime),
                              );

                              if (result != null) {
                                setState(() {
                                  startTime =
                                  "${result.openTime.hour.toString().padLeft(2, '0')}:${result.openTime.minute.toString().padLeft(2, '0')}";

                                  endTime =
                                  "${result.closeTime.hour.toString().padLeft(2, '0')}:${result.closeTime.minute.toString().padLeft(2, '0')}";
                                });
                              }

                              if (result != null) {
                                setState(() {
                                  endTime =
                                  "${result.closeTime.hour.toString().padLeft(2, '0')}:${result.closeTime.minute.toString().padLeft(2, '0')}";
                                });
                              }
                            },
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 28),

                    /// 휴게시간
                    const Text(
                      "휴게 시간",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),

                    const SizedBox(height: 12),

                    RDropdownField(
                      value: breakTime,
                      hintText: "휴게 시간 선택",
                      onTap: () async {
                        final result = await BreakTimeBottomSheet.show(
                          context,
                          initialValue: breakTime,
                        );

                        if (result != null) {
                          setState(() {
                            breakTime = result;
                          });
                        }
                      },
                    ),

                    const SizedBox(height: 28),

                    /// 근무 날짜
                    const Text(
                      "근무 날짜",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),

                    const SizedBox(height: 12),

                    RDropdownField(
                      value: selectedDates.isEmpty
                          ? ""
                          : selectedDates.map((e) => "${e.month}/${e.day}").join(", "),
                      hintText: "근무 날짜 선택하기",
                      onTap: () async {
                        final result = await CalendarBottomSheet.show(
                          context,
                          initialDates: selectedDates,
                        );

                        if (result != null) {
                          setState(() {
                            selectedDates = result;
                          });
                        }
                      },
                    ),

                    const SizedBox(height: 28),

                    /// 근무자
                    Row(
                      children: [
                        const Text(
                          "근무자",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),

                        const Spacer(),

                        GestureDetector(
                          onTap: () async {

                            final result = await WorkerBottomSheet.show(
                              context,
                              workPlaceId: widget.workPlaceId,
                              initialSelected: selectedWorkers,
                            );

                            if (result != null) {
                              setState(() {
                                selectedWorkers = result;
                              });
                            }

                          },
                          child: Row(
                            children: [
                              Text(
                                selectedWorkers.isEmpty
                                    ? "근무자 선택하기"
                                    : selectedWorkers.map((e)=>e.memberName).join(", "),
                                style: const TextStyle(
                                  fontSize: 16,
                                  color: Color(0xFF7A7A7A),
                                ),
                              ),

                              const SizedBox(width: 4),

                              const Icon(
                                Icons.chevron_right,
                                color: Color(0xFF7A7A7A),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    const Spacer(),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),

      /// ==========================
      /// 하단 버튼
      /// ==========================
      bottomNavigationBar: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
          child: RCompleteButton(
            text: _isSubmitting ? "등록 중..." : "추가 완료",
            enabled: canSubmit,
            onPressed: canSubmit
                ? () async {
              final ok =
              await RegisterScheduleBottomSheet.show(context);

              if (ok == true) {
                await _submitSchedule();
              }
            }
                : null,
          ),
        ),
      ),
    );
  }
}