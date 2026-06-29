import 'package:flutter/material.dart';
import '../Month/AllSchedule/EMonthAllSchedulePage.dart';

class EWeekAllScheduleCard extends StatelessWidget {
  final List<ScheduleShift> workers;

  const EWeekAllScheduleCard({
    super.key,
    required this.workers,
  });

  Color _backgroundColor(String role) {
    switch (role) {
      case "오픈":
        return const Color(0xFFE6F3FF);
      case "미들":
        return const Color(0xFFEEEBFF);
      case "마감":
        return const Color(0xFFDCFED8);
      default:
        return Colors.grey.shade200;
    }
  }

  Color _textColor(String role) {
    switch (role) {
      case "오픈":
        return const Color(0xFF0063BF);
      case "미들":
        return const Color(0xFF7D67FD);
      case "마감":
        return const Color(0xFF007360);
      default:
        return Colors.black87;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (workers.isEmpty) {
      return const SizedBox();
    }

    final shift = workers.first;

    final names = shift.workers
        .map((e) => e.name)
        .join("\n");

    return Container(
      width: double.infinity,
      height: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 4),
      decoration: BoxDecoration(
        color: shift.shortage
            ? const Color(0xFFFF4646)
            : _backgroundColor(shift.role),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              names,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: shift.shortage
                    ? Colors.white
                    : _textColor(shift.role),
              ),
            ),
            if (shift.shortage) ...[
              const SizedBox(height: 6),
              Text(
                "인원\n${shift.shortageCount}명 부족",
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  height: 1.2,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}