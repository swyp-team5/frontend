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

    // 겹치는 시간대를 합쳐서 그릴 때는 가장 나중에 추가된 근무(리스트의
    // 마지막 항목)의 색을 써서, 새로 추가된 근무가 겹쳐 있는 구간을
    // 시각적으로 구분할 수 있게 한다.
    final colorIndex = shifts.last.colorIndex; // ⭐ role 대신 colorIndex

    final hasShortage = shifts.any((e) => e.shortage);

    final shortageCount =
    shifts.fold<int>(0, (sum, e) => sum + e.shortageCount);

    // 겹치는 시간대를 합쳐서 하나의 박스로 그릴 때, 같은 근무자가 여러 근무에
    // 동시에 배정돼 있으면 이름이 중복 표시되지 않도록 memberId로 걸러낸다.
    final seenMemberIds = <int>{};
    final names = shifts
        .expand((e) => e.workers)
        .where((w) => seenMemberIds.add(w.memberId))
        .map((e) => e.name)
        .join("\n/\n");

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