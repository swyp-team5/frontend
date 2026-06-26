import 'package:chack_chack/employer/schedule/widgets/BreakTimeBottomSheet.dart';
import 'package:chack_chack/employer/schedule/widgets/CalendarBottomSheet.dart';
import 'package:chack_chack/employer/schedule/widgets/RegisterScheduleBottomSheet.dart';
import 'package:chack_chack/employer/schedule/widgets/WorkerBottomSheet.dart';
import 'package:chack_chack/employer/schedule/widgets/WorkingTImeInputBottomSheet.dart';
import 'package:flutter/material.dart';

import 'widgets/RCompleteButton.dart';
import 'widgets/RDropdownField.dart';
import 'widgets/RInputBox.dart';
import 'widgets/RTimeField.dart';

class RAddSchedulePage extends StatefulWidget {
  const RAddSchedulePage({super.key});

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

  List<String> selectedWorkers = [];

  bool get canSubmit {
    return workNameController.text.isNotEmpty &&
        selectedWorkers.isNotEmpty &&
        selectedDates.isNotEmpty;
  }

  TimeOfDay _toTimeOfDay(String time) {
    final parts = time.split(":");

    return TimeOfDay(
      hour: int.parse(parts[0]),
      minute: int.parse(parts[1]),
    );
  }

  final List<String> workers = ["모수연", "박춘식", "윤서준", "이다빈",];


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
                              workers: workers,
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
                                    : selectedWorkers.join(", "),
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
            text: "추가 완료",
            enabled: canSubmit,
            onPressed: canSubmit
                ? () async {

              final result =
              await RegisterScheduleBottomSheet.show(context);

              if (result == true) {

                /// TODO : API 호출

                Navigator.pop(context);
              }

            }
                : null,
          ),
        ),
      ),
    );
  }
}