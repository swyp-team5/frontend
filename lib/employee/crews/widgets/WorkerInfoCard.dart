import 'package:flutter/material.dart';
import '../EApplicationFormPage.dart';
import '../model/MyWorkSchedule.dart'; // MyWorkSchedule가 있는 파일 경로로 수정

class WorkerInfoCard extends StatelessWidget {
  final String? workerName;
  final MyWorkSchedule? schedule;

  const WorkerInfoCard({
    super.key,
    required this.workerName,
    required this.schedule,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: const Color(0xFFF2F2F2),
          borderRadius: BorderRadius.circular(18),
        ),
        child: schedule == null
            ? Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "${workerName ?? ""}님의 근무 정보",
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              "날짜를 선택해주세요.",
              style: TextStyle(
                color: Color(0xff8F8F8F),
                fontSize: 14,
              ),
            ),
          ],
        )
            : Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "${workerName ?? ""}님의 근무 정보",
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
              ),
            ),

            const SizedBox(height: 20),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "날짜",
                  style: TextStyle(
                    color: Color(0xff8F8F8F),
                    fontSize: 15,
                  ),
                ),
                Text(
                  "${schedule!.date.year}년 "
                      "${schedule!.date.month}월 "
                      "${schedule!.date.day}일",
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 14),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "근무시간",
                  style: TextStyle(
                    color: Color(0xff8F8F8F),
                    fontSize: 15,
                  ),
                ),
                Text(
                  "${schedule!.startTime} - ${schedule!.endTime}",
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}