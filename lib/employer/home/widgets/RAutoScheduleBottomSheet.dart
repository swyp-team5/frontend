import 'package:chack_chack/common/employer/RAutoScheduling.dart';
import 'package:chack_chack/employer/home/autoschedule/RSelectAutoSchedulePage.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

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

  /// workPlaceId + weekScheduleId 조합으로 저장 키 생성
  String get _runIdKey =>
      "scheduleGenerationRunId_${widget.workPlaceId}_${widget.weekScheduleId}";
  String get _previewIdKey =>
      "schedulePreviewId_${widget.workPlaceId}_${widget.weekScheduleId}";
  String get _candidateCountKey =>
      "candidateCount_${widget.workPlaceId}_${widget.weekScheduleId}";

  Future<void> _onNextTap() async {
    setState(() => _isGenerating = true);

    try {
      final prefs = await SharedPreferences.getInstance();

      final savedRunId = prefs.getInt(_runIdKey);
      final savedPreviewId = prefs.getInt(_previewIdKey);
      final savedCandidateCount = prefs.getInt(_candidateCountKey);

      debugPrint(
          "🔍 [_onNextTap] 저장값 확인 — runIdKey=$_runIdKey, savedRunId=$savedRunId, savedPreviewId=$savedPreviewId, savedCandidateCount=$savedCandidateCount");

      if (savedRunId != null &&
          savedPreviewId != null &&
          savedCandidateCount != null) {
        debugPrint(
            "🟡 [_onNextTap] 이미 생성된 결과 재사용 — runId=$savedRunId, previewId=$savedPreviewId");

        final preview = await SchedulePreviewApi.getPreview(
          workPlaceId: widget.workPlaceId,
          weekScheduleId: widget.weekScheduleId,
          runId: savedRunId,
        );

        if (!mounted) return;

        widget.onNext?.call();
        Navigator.pop(context);

        Navigator.of(context, rootNavigator: true).push(
          MaterialPageRoute(
            builder: (_) => RSelectAutoSchedulePage(preview: preview),
          ),
        );
        return;
      }

      debugPrint("=== _onNextTap 시작 (최초 생성) ===");

      final result = await ScheduleGenerationRunApi.generate(
        workPlaceId: widget.workPlaceId,
        weekScheduleId: widget.weekScheduleId,
      );

      await prefs.setInt(_runIdKey, result.scheduleGenerationRunId);
      await prefs.setInt(_previewIdKey, result.schedulePreviewId);
      await prefs.setInt(_candidateCountKey, result.candidateCount);

      if (!mounted) return;

      widget.onNext?.call();
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
    } on NoScheduleCandidateException catch (e) {
      debugPrint("🟠 [_onNextTap] 후보 없음 — 빈 결과로 다음 화면 이동: ${e.message}");

      if (!mounted) return;

      widget.onNext?.call();
      Navigator.pop(context);

      Navigator.of(context, rootNavigator: true).push(
        MaterialPageRoute(
          builder: (_) => RAutoSchedulingPage(
            workPlaceId: widget.workPlaceId,
            weekScheduleId: widget.weekScheduleId,
            noCandidates: true,
          ),
        ),
      );
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

      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_runIdKey, result.scheduleGenerationRunId);
      await prefs.setInt(_previewIdKey, result.schedulePreviewId);
      await prefs.setInt(_candidateCountKey, result.candidateCount);

      if (!mounted) return;

      widget.onNext?.call();
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
    } on NoScheduleCandidateException catch (e) {
      debugPrint("🟠 [_onRegenerateTap] 후보 없음 — 빈 결과로 다음 화면 이동: ${e.message}");

      if (!mounted) return;

      widget.onNext?.call();
      Navigator.pop(context);

      Navigator.of(context, rootNavigator: true).push(
        MaterialPageRoute(
          builder: (_) => RAutoSchedulingPage(
            workPlaceId: widget.workPlaceId,
            weekScheduleId: widget.weekScheduleId,
            noCandidates: true,
          ),
        ),
      );
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