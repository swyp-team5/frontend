import 'package:chack_chack/employer/home/autoschedule/RSelectAutoSchedulePage.dart';
import 'package:flutter/material.dart';
import '../../employer/home/autoschedule/api/SchedulePreviewApi.dart';
import '../../employer/home/autoschedule/models/SchedulePreviewResponse.dart';

class RAutoSchedulingPage extends StatefulWidget {
  /// 후보가 없는 경우(noCandidates: true)에는 필요 없으므로 nullable
  final int? scheduleGenerationRunId;
  final int? schedulePreviewId;

  final int workPlaceId;
  final int weekScheduleId;
  final int candidateCount;

  /// true면 API 조회 없이 빈 preview로 바로 다음 화면으로 이동
  final bool noCandidates;

  const RAutoSchedulingPage({
    super.key,
    this.scheduleGenerationRunId,
    this.schedulePreviewId,
    required this.workPlaceId,
    required this.weekScheduleId,
    this.candidateCount = 0,
    this.noCandidates = false,
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
    // ✅ 후보가 없는 경우: 서버 조회 없이 빈 preview로 바로 이동
    if (widget.noCandidates) {
      debugPrint("=== [RAutoSchedulingPage] 후보 없음 — 빈 preview로 이동 ===");

      await Future.delayed(const Duration(seconds: 2));

      if (!mounted) return;

      final emptyPreview = SchedulePreviewResponse(
        scheduleGenerationRunId: widget.scheduleGenerationRunId ?? 0,
        schedulePreviewId: widget.schedulePreviewId ?? 0,
        workPlaceId: widget.workPlaceId,
        weekScheduleId: widget.weekScheduleId,
        candidateCount: 0,
        candidates: const [],
      );

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => RSelectAutoSchedulePage(preview: emptyPreview),
        ),
      );
      return;
    }

    debugPrint("=== [RAutoSchedulingPage] preview 조회 시작 ===");
    debugPrint(
        "workPlaceId=${widget.workPlaceId}, weekScheduleId=${widget.weekScheduleId}, runId=${widget.scheduleGenerationRunId}");

    try {
      final results = await Future.wait([
        SchedulePreviewApi.getPreview(
          workPlaceId: widget.workPlaceId,
          weekScheduleId: widget.weekScheduleId,
          runId: widget.scheduleGenerationRunId!,
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

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => RSelectAutoSchedulePage(preview: preview),
        ),
      );
    } catch (e) {
      debugPrint("🔴 [RAutoSchedulingPage] preview 조회 실패: $e");

      if (!mounted) return;

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