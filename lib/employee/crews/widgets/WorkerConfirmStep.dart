import 'package:chack_chack/employee/crews/widgets/WorkerInfoCard.dart';
import 'package:flutter/material.dart';

import '../EApplicationFormPage.dart';
import '../model/MyWorkSchedule.dart';

/// 근무자 선택 이후 근무 정보를 보여주고
/// "근무자 확정" 버튼을 눌러 확정하는 단계 화면
///
/// 기존 EApplicationFormPage 내부의 `_buildWorkerInfo()` 메서드를
/// 별도 위젯으로 분리했습니다.
class WorkerConfirmStep extends StatelessWidget {
  final String? workerName;
  final MyWorkSchedule? schedule;
  final VoidCallback onConfirm;

  const WorkerConfirmStep({
    super.key,
    required this.workerName,
    required this.schedule,
    required this.onConfirm,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 40),

        WorkerInfoCard(
          workerName: workerName,
          schedule: schedule,
        ),

        const Spacer(),

        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 14,
            vertical: 16,
          ),
          child: SizedBox(
            width: double.infinity,
            height: 54,
            child: ElevatedButton(
              onPressed: onConfirm,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0084FF),
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                "근무자 확정",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}