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

    // 겹치는 시간대를 합쳐서 그릴 때는 가장 나중에 추가된 근무(리스트의
    // 마지막 항목)의 색을 써서, 새로 추가된 근무가 겹쳐 있는 구간을
    // 시각적으로 구분할 수 있게 한다.
    final shift = workers.last;

    // 겹치는 시간대를 합쳐서 하나의 박스로 그릴 때, 같은 근무자가 여러 근무에
    // 동시에 배정돼 있으면 이름이 중복 표시되지 않도록 이름으로 걸러낸다.
    // (ScheduleWorker에는 memberId가 없어 이름으로 구분한다.)
    final seenNames = <String>{};
    final names = workers
        .expand((s) => s.workers)
        .where((w) => seenNames.add(w.name))
        .map((e) => e.name)
        .join("\n");

    final hasShortage = workers.any((s) => s.shortage);
    final shortageCount =
    workers.fold<int>(0, (sum, s) => sum + s.shortageCount);

    return Container(
      width: double.infinity,
      height: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 4),
      decoration: BoxDecoration(
        color: hasShortage
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
                color: hasShortage
                    ? Colors.white
                    : _textColor(shift.role),
              ),
            ),
            if (hasShortage) ...[
              const SizedBox(height: 6),
              Text(
                "인원\n$shortageCount명 부족",
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