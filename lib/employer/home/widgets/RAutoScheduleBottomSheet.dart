import 'package:chack_chack/common/employer/RAutoScheduling.dart';
import 'package:flutter/material.dart';

import '../autoschedule/api/ScheduleGenerationRunApi.dart';

class RAutoScheduleBottomSheet extends StatefulWidget {
  final int workPlaceId;
  final int weekScheduleId;
  final VoidCallback? onNext;

  const RAutoScheduleBottomSheet({
    super.key,
    required this.workPlaceId,
    required this.weekScheduleId,
    this.onNext,
  });

  @override
  State<RAutoScheduleBottomSheet> createState() =>
      _RAutoScheduleBottomSheetState();
}

class _RAutoScheduleBottomSheetState extends State<RAutoScheduleBottomSheet> {
  bool _isGenerating = false;

  Future<void> _onNextTap() async {
    setState(() => _isGenerating = true);

    debugPrint("=== _onNextTap 시작 ===");
    debugPrint(
        "workPlaceId: ${widget.workPlaceId}, weekScheduleId: ${widget.weekScheduleId}");

    try {
      final result = await ScheduleGenerationRunApi.generate(
        workPlaceId: widget.workPlaceId,
        weekScheduleId: widget.weekScheduleId,
      );

      debugPrint(
          "🟢 [_onNextTap] POST 성공! runId=${result.scheduleGenerationRunId}, previewId=${result.schedulePreviewId}, candidateCount=${result.candidateCount}, status=${result.status}");

      if (!mounted) return;

      widget.onNext?.call();

      // 바텀시트를 먼저 닫고, 그 결과를 페이지 이동에 사용
      Navigator.pop(context);

      Navigator.of(context, rootNavigator: true).push(
        MaterialPageRoute(
          builder: (_) => RAutoSchedulingPage(
            scheduleGenerationRunId: result.scheduleGenerationRunId,
            schedulePreviewId: result.schedulePreviewId,
            workPlaceId: result.workPlaceId,
            weekScheduleId: result.weekScheduleId,
            candidateCount: result.candidateCount,
          ),
        ),
      );
    } catch (e) {
      debugPrint("🔴 [_onNextTap] POST 실패: $e");

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    } finally {
      if (mounted) setState(() => _isGenerating = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 280,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(28),
        ),
      ),
      child: Column(
        children: [
          const SizedBox(height: 10),

          Container(
            width: 46,
            height: 5,
            decoration: BoxDecoration(
              color: const Color(0xFFE2E2E2),
              borderRadius: BorderRadius.circular(999),
            ),
          ),

          const SizedBox(height: 28),

          const Text(
            "자동 스케줄 유의",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),

          const SizedBox(height: 18),

          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 36),
            child: Text(
              "직원들이 제출한 날짜 및 시간을 반영해서\n가능한 스케줄을 취합해 자동으로 생성해요",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                height: 1.5,
                color: Color(0xFF767676),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),

          const Spacer(),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: _isGenerating ? null : _onNextTap,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0084FF),
                  disabledBackgroundColor: const Color(0xFFA9D0FB),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: _isGenerating
                    ? const SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2,
                  ),
                )
                    : const Text(
                  "다음",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),

          TextButton(
            onPressed: _isGenerating ? null : () => Navigator.pop(context),
            child: const Text(
              "취소",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),

          const SizedBox(height: 20),
        ],
      ),
    );
  }
}