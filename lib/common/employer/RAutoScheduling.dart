import 'package:chack_chack/employer/home/autoschedule/RSelectAutoSchedulePage.dart';
import 'package:flutter/material.dart';
import '../../employer/home/autoschedule/api/SchedulePreviewApi.dart';
import '../../employer/home/autoschedule/models/SchedulePreviewResponse.dart';

class RAutoSchedulingPage extends StatefulWidget {
  final int scheduleGenerationRunId;
  final int schedulePreviewId;
  final int workPlaceId;
  final int weekScheduleId;
  final int candidateCount;

  const RAutoSchedulingPage({
    super.key,
    required this.scheduleGenerationRunId,
    required this.schedulePreviewId,
    required this.workPlaceId,
    required this.weekScheduleId,
    required this.candidateCount,
  });

  @override
  State<RAutoSchedulingPage> createState() => _RAutoSchedulingPageState();
}

class _RAutoSchedulingPageState extends State<RAutoSchedulingPage> {
  @override
  void initState() {
    super.initState();
    _loadPreviewAndNavigate();
  }

  Future<void> _loadPreviewAndNavigate() async {
    debugPrint("=== [RAutoSchedulingPage] preview 조회 시작 ===");
    debugPrint(
        "workPlaceId=${widget.workPlaceId}, weekScheduleId=${widget.weekScheduleId}, runId=${widget.scheduleGenerationRunId}");

    try {
      final results = await Future.wait([
        SchedulePreviewApi.getPreview(
          workPlaceId: widget.workPlaceId,
          weekScheduleId: widget.weekScheduleId,
          runId: widget.scheduleGenerationRunId,
        ),
        Future.delayed(const Duration(seconds: 2)),
      ]);

      if (!mounted) {
        debugPrint("⚠️ [RAutoSchedulingPage] 위젯이 이미 dispose됨 — 이동 취소");
        return;
      }

      final preview = results[0] as SchedulePreviewResponse;

      debugPrint(
          "🟢 [RAutoSchedulingPage] preview 조회 성공 — candidateCount=${preview.candidateCount}");
      debugPrint("🟢 [RAutoSchedulingPage] RSelectAutoSchedulePage로 이동");

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => RSelectAutoSchedulePage(
            preview: preview,
          ),
        ),
      );
    } catch (e) {
      debugPrint("🔴 [RAutoSchedulingPage] preview 조회 실패: $e");

      if (!mounted) return;

      // 실패 시 처리: 스낵바 안내 후 이전 화면으로 복귀
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))),
      );

      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  "assets/images/automatic_schedule_creation.png",
                  width: 200,
                  height: 200,
                  fit: BoxFit.contain,
                ),
                const Text(
                  "근무자들의 스케줄을 취합해",
                  style: TextStyle(
                    color: Color(0xFF0084FF),
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  "자동으로 스케줄을\n만들고 있어요",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 24,
                    height: 1.4,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}