import 'package:chack_chack/employer/home/autoschedule/RSelectAutoSchedulePage.dart';
import 'package:flutter/material.dart';

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

    Future.delayed(const Duration(seconds: 3), () {
      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => RSelectAutoSchedulePage(
            // RSelectAutoSchedulePage가 받는 파라미터에 맞게 전달하세요.
            // 예시:
            // workPlaceId: widget.workPlaceId,
            // weekScheduleId: widget.weekScheduleId,
            // scheduleGenerationRunId: widget.scheduleGenerationRunId,
            // schedulePreviewId: widget.schedulePreviewId,
            // candidateCount: widget.candidateCount,
          ),
        ),
      );
    });
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