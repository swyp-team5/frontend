import 'package:flutter/material.dart';

import '../../../common/employer/RAutoScheduleComplete.dart';
import 'api/ConfirmedWeekScheduleApi.dart';
import 'models/SchedulePreviewResponse.dart';
import 'models/ScheduleScenario.dart';

class RAutoScheduleDetailPage extends StatefulWidget {
  final ScheduleScenario scenario;
  final SchedulePreviewResponse preview;

  const RAutoScheduleDetailPage({
    super.key,
    required this.scenario,
    required this.preview,
  });

  @override
  State<RAutoScheduleDetailPage> createState() =>
      _RAutoScheduleDetailPageState();
}

class _RAutoScheduleDetailPageState extends State<RAutoScheduleDetailPage> {
  static const double hourHeight = 50;

  bool _isConfirming = false;

  // 순서 기반 색상 팔레트 (RShiftRow의 colorIndex와 동일한 규칙)
  static const List<Color> _bgColors = [
    Color(0xffDCEEFF),
    Color(0xffE7E0FF),
    Color(0xffDDF8D7),
  ];
  static const List<Color> _textColors = [
    Color(0xff2D5BD1),
    Color(0xff6A5BEA),
    Color(0xff2AA85A),
  ];

  Color _bgColor(int index) =>
      index < _bgColors.length ? _bgColors[index] : Colors.grey.shade200;

  Color _txtColor(int index) =>
      index < _textColors.length ? _textColors[index] : Colors.black;

  /// "09:30" -> 9.5 (그리드 위치 계산용, 분 단위까지 반영)
  double _toHourDecimal(String time) {
    final parts = time.split(":");
    return int.parse(parts[0]) + int.parse(parts[1]) / 60.0;
  }

  // 선택하기 버튼 핸들러
  Future<void> _onConfirm() async {
    setState(() => _isConfirming = true);

    try {
      final result = await ConfirmedWeekScheduleApi.confirm(
        workPlaceId: widget.preview.workPlaceId,
        weekScheduleId: widget.preview.weekScheduleId,
        scheduleGenerationRunId: widget.preview.scheduleGenerationRunId,
        schedulePreviewId: widget.preview.schedulePreviewId,
        selectedCandidateNo: widget.scenario.candidateNo,
      );

      // 성공 로그
      debugPrint("🟢 [RAutoScheduleDetailPage] 스케줄 확정 성공: "
          "confirmedWeekScheduleId=${result.confirmedWeekScheduleId}, "
          "workPlaceId=${result.workPlaceId}, "
          "weekScheduleId=${result.weekScheduleId}, "
          "selectedCandidateNo=${result.selectedCandidateNo}, "
          "assignmentCount=${result.assignmentCount}, "
          "status=${result.status}");

      if (!mounted) return;

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => const RAutoScheduleComplete(),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("스케줄 확정에 실패했어요\n$e")),
      );
    } finally {
      if (mounted) setState(() => _isConfirming = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();

    final nextMonday = DateTime(
      now.year,
      now.month,
      now.day,
    ).add(Duration(days: 8 - now.weekday));

    final weekDays = List.generate(
      7,
          (index) => nextMonday.add(Duration(days: index)),
    );

    final nextSunday = weekDays.last;

    return Scaffold(
      backgroundColor: Colors.white,

      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: SizedBox(
            height: 50,
            child: ElevatedButton(
              // 로딩 중에는 중복 호출 방지
              onPressed: _isConfirming ? null : _onConfirm,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0084FF),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: _isConfirming
                  ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              )
                  : const Text(
                "선택하기",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                  fontSize: 16,
                ),
              ),
            ),
          ),
        ),
      ),

      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 30, 20, 0),
              child: SizedBox(
                height: 32,
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
                        "근무 상세",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            Text(
              "${nextMonday.month}월 ${nextMonday.day}일 - "
                  "${nextSunday.month}월 ${nextSunday.day}일",
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 20,
              ),
            ),

            const SizedBox(height: 20),

            Container(
              height: 70,
              decoration: const BoxDecoration(
                border: Border(
                  top: BorderSide(color: Color(0xffE5E5E5)),
                  bottom: BorderSide(color: Color(0xffE5E5E5)),
                ),
              ),
              child: Row(
                children: [
                  const SizedBox(width: 34),
                  ...List.generate(7, (index) {
                    const week = ["월", "화", "수", "목", "금", "토", "일"];

                    final isOff = widget.scenario.rows
                        .every((row) => row.counts[index].isOff);

                    return Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            week[index],
                            style: TextStyle(
                              color: isOff
                                  ? const Color(0xFF999999)
                                  : Colors.black,
                              fontSize: 12,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            "${weekDays[index].day}",
                            style: TextStyle(
                              color: isOff
                                  ? const Color(0xFF999999)
                                  : Colors.black,
                              fontWeight: FontWeight.w600,
                              fontSize: 18,
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                ],
              ),
            ),

            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final dayWidth = (constraints.maxWidth - 34) / 7;

                  return SingleChildScrollView(
                    child: SizedBox(
                      height: hourHeight * 15,
                      child: Stack(
                        children: [
                          Row(
                            children: [
                              SizedBox(
                                width: 34,
                                child: Column(
                                  children: List.generate(15, (index) {
                                    final hour = index + 9;
                                    return Container(
                                      height: hourHeight,
                                      alignment: Alignment.topCenter,
                                      decoration: const BoxDecoration(
                                        border: Border(
                                          bottom: BorderSide(
                                            color: Color(0xffECECEC),
                                          ),
                                        ),
                                      ),
                                      child: Text(
                                        "$hour",
                                        style: const TextStyle(fontSize: 10),
                                      ),
                                    );
                                  }),
                                ),
                              ),
                              Expanded(
                                child: Row(
                                  children: List.generate(
                                    7,
                                        (_) => Expanded(
                                      child: Column(
                                        children: List.generate(
                                          15,
                                              (_) => Container(
                                            height: hourHeight,
                                            decoration: BoxDecoration(
                                              border: Border(
                                                right: BorderSide(
                                                  color: Colors.grey.shade300,
                                                ),
                                                bottom: BorderSide(
                                                  color: Colors.grey.shade300,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          for (int rowIndex = 0;
                          rowIndex < widget.scenario.rows.length;
                          rowIndex++)
                            ..._buildShiftBlocks(
                              widget.scenario.rows[rowIndex],
                              rowIndex,
                              dayWidth,
                            ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _shift({
    required Color color,
    required int day,
    required double start,
    required double end,
    required String text,
    required double dayWidth,
    required Color textColor,
  }) {
    return Positioned(
      left: 34 + day * dayWidth,
      top: (start - 9) * hourHeight,
      child: Container(
        width: dayWidth,
        height: (end - start) * hourHeight,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: color,
        ),
        child: Text(
          text,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 10,
            color: textColor,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  List<Widget> _buildShiftBlocks(
      ShiftRowData row,
      int rowIndex,
      double dayWidth,
      ) {
    return List.generate(row.counts.length, (day) {
      final shift = row.counts[day];

      if (shift.isOff || shift.startTime == null || shift.closeTime == null) {
        return const SizedBox.shrink();
      }

      final start = _toHourDecimal(shift.startTime!);
      final end = _toHourDecimal(shift.closeTime!);

      return _shift(
        day: day,
        start: start,
        end: end,
        dayWidth: dayWidth,
        color: shift.shortage ? Colors.redAccent : _bgColor(rowIndex),
        text: shift.shortage
            ? "${shift.workers.join('\n')}\n(${shift.shortageCount}명 부족)"
            : shift.workers.join('\n/\n'),
        textColor: shift.shortage ? Colors.white : _txtColor(rowIndex),
      );
    });
  }
}