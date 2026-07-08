import 'package:flutter/material.dart';
import '../Month/RMonthAllSchedulePage.dart';

class RWeekScheduleCard extends StatelessWidget {
  final List<RScheduleShift> shifts;

  const RWeekScheduleCard({
    super.key,
    required this.shifts,
  });

  // 순서 기반 색상 팔레트 (다른 화면들과 동일한 규칙)
  static const List<Color> _bgColors = [
    Color(0xFFE6F3FF),
    Color(0xFFEEEBFF),
    Color(0xFFDCFED8),
  ];
  static const List<Color> _textColors = [
    Color(0xFF0063BF),
    Color(0xFF7D67FD),
    Color(0xFF007360),
  ];

  Color _bgColor(int index) =>
      index < _bgColors.length ? _bgColors[index] : Colors.grey.shade200;

  Color _txtColor(int index) =>
      index < _textColors.length ? _textColors[index] : Colors.black87;

  @override
  Widget build(BuildContext context) {
    if (shifts.isEmpty) {
      return const SizedBox();
    }

    final colorIndex = shifts.first.colorIndex; // ⭐ role 대신 colorIndex

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
          : _bgColor(colorIndex),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              names,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: hasShortage
                    ? Colors.white
                    : _txtColor(colorIndex),
              ),
            ),
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
                "$shortageCount명 부족",
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