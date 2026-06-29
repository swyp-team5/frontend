import 'package:flutter/material.dart';
import '../Month/RMonthAllSchedulePage.dart';

class RWeekScheduleCard extends StatelessWidget {
  final List<RScheduleShift> shifts;

  const RWeekScheduleCard({
    super.key,
    required this.shifts,
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
    if (shifts.isEmpty) {
      return const SizedBox();
    }

    final first = shifts.first;

    final role = first.role;

    final hasShortage = shifts.any((e) => e.shortage);

    final shortageCount =
    shifts.fold<int>(0, (sum, e) => sum + e.shortageCount);

    final names = shifts
        .expand((e) => e.workers)
        .map((e) => e.name)
        .join("\n");

    return Container(
      width: double.infinity,
      height: double.infinity,
      color: hasShortage
          ? const Color(0xFFFF4646)
          : _backgroundColor(role),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [

            /// 근무자 이름
            Text(
              names,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: hasShortage
                    ? Colors.white
                    : _textColor(role),
              ),
            ),

            /// 부족 인원 표시
            if (hasShortage) ...[
              const SizedBox(height: 10),

              const Text(
                "인원",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                ),
              ),

              Text(
                "${shortageCount}명 부족",
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 11,
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}