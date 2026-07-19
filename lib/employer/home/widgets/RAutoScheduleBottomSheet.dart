import 'package:chack_chack/common/employer/RAutoScheduling.dart';
import 'package:chack_chack/employer/home/autoschedule/RSelectAutoSchedulePage.dart';
import 'package:flutter/material.dart';

import '../api/SubmitStatusApi.dart';
import '../autoschedule/api/ScheduleGenerationRunApi.dart';
import '../autoschedule/api/SchedulePreviewApi.dart';

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
  bool _isRegenerating = false;

  /// 후보 없음(NoScheduleCandidateException) 발생 시 안내 다이얼로그를 띄우는 공통 함수
  Future<void> _showNoCandidateDialog(NoScheduleCandidateException e) async {
    if (!mounted) return;

    await showDialog<void>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: Colors.white,
        title: const Text(
          "스케줄 생성 불가",
          textAlign: TextAlign.center,
        ),
        content: Text(
          e.guidanceText,
          textAlign: TextAlign.center,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("확인"),
          ),
        ],
      ),
    );
    // 다이얼로그 확인 후에는 다음 화면으로 넘어가지 않고
    // 바텀시트에 그대로 머무름 (조건 수정 후 다시 시도할 수 있도록)
  }

  Future<void> _onNextTap() async {
    setState(() => _isGenerating = true);

    try {
      debugPrint("=== _onNextTap 시작 (생성) ===");

      // ⚠️ 예전에는 SharedPreferences에 runId/previewId를 캐싱해두고
      //    재사용했는데, 그러면 직원들이 그 이후에 새로 근무시간을
      //    제출해도 최초 생성 시점의 (심지어 후보 0건짜리) 결과를
      //    계속 보여주는 문제가 있었다.
      //    → 매번 최신 제출 데이터 기준으로 새로 생성 요청을 보낸다.
      //      (서버의 generate()가 변경 없으면 기존 run을 그대로
      //       반환하는 멱등 처리라면 여기서 매번 호출해도 비용 문제 없음)
      final result = await ScheduleGenerationRunApi.generate(
        workPlaceId: widget.workPlaceId,
        weekScheduleId: widget.weekScheduleId,
      );

      if (!mounted) return;

      Navigator.pop(context);

      await Navigator.of(context, rootNavigator: true).push(
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

      // 미리보기/생성 흐름을 마치고 홈으로 돌아왔을 때 호출
      widget.onNext?.call();
    } on NoScheduleCandidateException catch (e) {
      debugPrint("🟠 [_onNextTap] 후보 없음: ${e.guidanceText}");
      await _showNoCandidateDialog(e);
    } catch (e) {
      debugPrint("🔴 [_onNextTap] 실패: $e");

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))),
      );
    } finally {
      if (mounted) setState(() => _isGenerating = false);
    }
  }

  Future<void> _onRegenerateTap() async {
    setState(() => _isRegenerating = true);

    try {
      debugPrint("=== _onRegenerateTap 시작 (재생성) ===");

      final result = await ScheduleGenerationRunApi.regenerate(
        workPlaceId: widget.workPlaceId,
        weekScheduleId: widget.weekScheduleId,
      );

      if (!mounted) return;

      Navigator.pop(context);

      await Navigator.of(context, rootNavigator: true).push(
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

      widget.onNext?.call();
    } on NoScheduleCandidateException catch (e) {
      debugPrint("🟠 [_onRegenerateTap] 후보 없음: ${e.guidanceText}");
      await _showNoCandidateDialog(e);
    } catch (e) {
      debugPrint("🔴 [_onRegenerateTap] 실패: $e");

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))),
      );
    } finally {
      if (mounted) setState(() => _isRegenerating = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isBusy = _isGenerating || _isRegenerating;

    return Container(
      height: 340,
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
                onPressed: isBusy ? null : _onNextTap,
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

          const SizedBox(height: 12),

          /// 스케줄 재생성 버튼
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: SizedBox(
              width: double.infinity,
              height: 56,
              child: OutlinedButton(
                onPressed: isBusy ? null : _onRegenerateTap,
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Color(0xFF0084FF)),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: _isRegenerating
                    ? const SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(
                    color: Color(0xFF0084FF),
                    strokeWidth: 2,
                  ),
                )
                    : const Text(
                  "스케줄 재생성",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF0084FF),
                  ),
                ),
              ),
            ),
          ),

          TextButton(
            onPressed: isBusy ? null : () => Navigator.pop(context),
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