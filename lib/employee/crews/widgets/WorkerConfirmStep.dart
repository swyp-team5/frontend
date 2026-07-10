import 'package:flutter/material.dart';

import 'package:chack_chack/employee/crews/model/MyWorkSchedule.dart';
import 'package:chack_chack/employee/crews/widgets/WorkerInfoCard.dart';

/// 근무자 선택(WorkerSelect) 확인 이후 나오는 근무정보 확인 화면.
/// 교대 신청일 때만 거쳐가고, 대타는 이 화면을 건너뛴다.
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
        WorkerInfoCard(workerName: workerName, schedule: schedule),
        const Spacer(),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
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