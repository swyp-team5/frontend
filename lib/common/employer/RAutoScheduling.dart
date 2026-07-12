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
  // ⚠️ 임시 조치: 서버의 스케줄 생성이 비동기(백그라운드)로 처리되는 것으로
  //    보이는데, 완료 여부를 알려주는 status 값의 스펙을 아직 몰라서
  //    status 기반 폴링을 못 만드는 상태다.
  //    대신 getPreview()를 candidates가 채워질 때까지 짧은 간격으로
  //    재시도한다. 백엔드에서 status 값 / 별도 상태 조회 API 스펙을
  //    확인해주면, 아래 폴링 로직을 status 기반으로 교체해야 한다.
  static const int _maxPollAttempts = 6;
  static const Duration _pollInterval = Duration(seconds: 2);

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

    debugPrint("=== [RAutoSchedulingPage] preview 조회 시작 (폴링) ===");
    debugPrint(
        "workPlaceId=${widget.workPlaceId}, weekScheduleId=${widget.weekScheduleId}, runId=${widget.scheduleGenerationRunId}");

    try {
      SchedulePreviewResponse? preview;

      for (int attempt = 1; attempt <= _maxPollAttempts; attempt++) {
        debugPrint("🔁 [RAutoSchedulingPage] preview 조회 시도 $attempt/$_maxPollAttempts");

        final fetched = await SchedulePreviewApi.getPreview(
          workPlaceId: widget.workPlaceId,
          weekScheduleId: widget.weekScheduleId,
          runId: widget.scheduleGenerationRunId!,
        );

        debugPrint(
            "🔁 [RAutoSchedulingPage] 시도 $attempt 결과 — candidateCount=${fetched.candidateCount}, candidates=${fetched.candidates.length}개");

        if (fetched.candidates.isNotEmpty) {
          // 후보가 채워졌으면 바로 사용
          preview = fetched;
          break;
        }

        // 아직 후보가 비어있음 → 마지막 시도가 아니면 대기 후 재시도
        preview = fetched; // 마지막으로 받은 값은 계속 보관 (전부 실패 시 이걸로 이동)

        if (attempt < _maxPollAttempts) {
          await Future.delayed(_pollInterval);
        }
      }

      if (!mounted) {
        debugPrint("⚠️ [RAutoSchedulingPage] 위젯이 이미 dispose됨 — 이동 취소");
        return;
      }

      debugPrint(
          "🟢 [RAutoSchedulingPage] 폴링 종료 — 최종 candidateCount=${preview!.candidateCount}");

      if (preview.candidates.isEmpty) {
        debugPrint(
            "🟠 [RAutoSchedulingPage] 최대 재시도 후에도 후보가 비어있음 — 백엔드 확인 필요");
      }

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => RSelectAutoSchedulePage(preview: preview!),
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