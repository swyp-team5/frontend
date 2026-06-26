import 'package:flutter/material.dart';

class EWeekScheduleCard extends StatelessWidget {
  final List<dynamic> workers;
  final bool isAllView;

  const EWeekScheduleCard({
    super.key,
    required this.workers,
    required this.isAllView,
  });

  Color _backgroundColor() {
    return isAllView
        ? const Color(0xFFEDE7FF) // 전체보기
        : const Color(0xFFE6F3FF); // 개인보기
  }

  Color _textColor() {
    return isAllView
        ? const Color(0xFF6B4EFF)
        : const Color(0xFF1976FF);
  }

  @override
  Widget build(BuildContext context) {
    if (workers.isEmpty) {
      return const SizedBox();
    }

    final sorted = [...workers]
      ..sort((a, b) => a.startTime.compareTo(b.startTime));

    final first = sorted.first;

    final last = sorted.reduce(
          (a, b) =>
      a.endTime.compareTo(b.endTime) > 0 ? a : b,
    );

    final names = sorted
        .map((e) => e.name.toString())
        .join("\n");

    return Container(
      width: double.infinity,
      height: double.infinity,
      color: _backgroundColor(),
      alignment: Alignment.center,
      padding: const EdgeInsets.symmetric(
        horizontal: 4,
        vertical: 4,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Text(
          //   "${first.startTime}\n~ ${last.endTime}",
          //   textAlign: TextAlign.center,
          //   style: TextStyle(
          //     fontSize: 9,
          //     fontWeight: FontWeight.w700,
          //     color: _textColor(),
          //   ),
          // ),
          // const SizedBox(height: 6),
          Expanded(
            child: Center(
              child: Text(
                names,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: _textColor(),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}