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

  const RAddSchedulePage({
    super.key,
    required this.workPlaceId,
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

  DateTime _mondayOf(DateTime date) {
    return DateTime(date.year, date.month, date.day)
        .subtract(Duration(days: date.weekday - 1));
  }

  /// 근무 날짜 선택 캘린더에서 활성화할 날짜 집합.
  /// 근무가 하루라도 있는 주는 그 주 전체(월~일)를 활성화한다 — 18-5 정책상
  /// "확정 스케줄의 week_schedule 하위 활성 day.date"이면 되고, 그 날짜에 실제
  /// 근무가 있었는지는 조건이 아니기 때문이다(아직 비어있는 날짜도 추가 대상).
  Set<String> _enabledDates = {};

  Future<void> _loadEnabledDates() async {
    final now = DateTime.now();
    final from = DateTime(now.year, now.month - 3, 1);

    // "오늘 기준 +N일"이 아니라 "다음 주 일요일"을 정확히 계산한다.
    // (오늘 요일에 따라 +N일 방식은 다음 주 일요일에 못 미치거나 다다음 주까지
    //  넘어가버리는 오차가 생김)
    final thisMonday = _mondayOf(now);
    final nextMonday = thisMonday.add(const Duration(days: 7));
    final to = nextMonday.add(const Duration(days: 6));

    try {
      final response = await ConfirmedSchedulesApi.getConfirmedSchedules(
        workPlaceId: widget.workPlaceId,
        from: from,
        to: to,
      );

      final mondays = response.days
          .map((d) => _mondayOf(DateTime.parse(d.workDate)))
          .toSet();

      final enabled = <String>{};
      for (final monday in mondays) {
        for (int i = 0; i < 7; i++) {
          enabled.add(_formatDate(monday.add(Duration(days: i))));
        }
      }

      if (!mounted) return;
      setState(() => _enabledDates = enabled);
    } catch (e) {
      debugPrint("[_loadEnabledDates] 조회 실패: $e");
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

      // 18-5 정책상 confirmedWeekScheduleId 하나당 그 주(week_schedule) 소속
      // 날짜만 등록할 수 있다. selectedDates가 여러 주에 걸칠 수 있으므로,
      // 주(월요일 기준)마다 confirmedWeekScheduleId를 한 번씩만 조회해서 재사용한다.
      final Map<DateTime, int?> weekIdCache = {};

      // AssignmentCreateRequest는 날짜 하나당 요청 하나이므로,
      // 선택된 날짜 수만큼 순차적으로 등록.
      // workPartNo는 서버에서 자동으로 계산해서 응답으로 내려주므로
      // 클라이언트에서 별도로 조회하지 않습니다.
      for (final date in selectedDates) {
        final monday = _mondayOf(date);

        if (!weekIdCache.containsKey(monday)) {
          final weekly = await ConfirmedSchedulesApi.getConfirmedWeeklySchedule(
            workPlaceId: widget.workPlaceId,
            weekStartDate: monday,
          );
          weekIdCache[monday] = weekly.confirmedWeekScheduleId;
        }

        final confirmedWeekScheduleId = weekIdCache[monday];

        if (confirmedWeekScheduleId == null) {
          throw Exception(
            "${_formatDate(date)}이(가) 속한 주는 확정된 스케줄이 없어요.",
          );
        }

        final response = await AssignmentApi.create(
          workPlaceId: widget.workPlaceId,
          confirmedWeekScheduleId: confirmedWeekScheduleId,
          request: AssignmentCreateRequest(
            workDate: _formatDate(date),
            timeName: workNameController.text,
            startTime: startTime,
            closeTime: endTime,
            restTime: restTime,
            workerMemberIds: memberIds,
          ),
        );

        debugPrint(
          "근무 등록 성공 : workDate=${response.workDate}, "
              "timeDetailId=${response.timeDetailId}, "
              "workPartNo=${response.workPartNo}, "
              "assignmentCount=${response.assignmentCount}",
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
    _loadEnabledDates();
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
                          enabledDates: _enabledDates,
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