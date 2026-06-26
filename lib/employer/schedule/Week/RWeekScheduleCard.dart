import 'package:flutter/material.dart';
import '../Month/RMonthAllSchedulePage.dart';


class RWeekScheduleCard extends StatelessWidget {
  final List<RScheduleWorker> workers;

  const RWeekScheduleCard({
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
        return const Color(0xFFDDF8E8);

      default:
        return const Color(0xFFF3F3F3);
    }
  }

  Color _textColor(String role) {
    switch (role) {
      case "오픈":
        return const Color(0xFF0084FF);

      case "미들":
        return const Color(0xFF7D67FD);

      case "마감":
        return const Color(0xFF00A86B);

      default:
        return Colors.black87;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (workers.isEmpty) {
      return const SizedBox();
    }

    /// 가장 빠른 시작시간
    workers.sort((a, b) => a.startTime.compareTo(b.startTime));

    final first = workers.first;

    final last = workers.reduce(
          (a, b) =>
      a.endTime.compareTo(b.endTime) > 0 ? a : b,
    );

    final names = workers.map((e) => e.name).join("\n");

    return Container(
      width: double.infinity,
      height: double.infinity,
      margin: EdgeInsets.zero,
      padding: EdgeInsets.zero,
      decoration: BoxDecoration(
        color: _backgroundColor(first.role),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // 시간을 표시하고 싶으면 주석 해제
            /*
        Text(
          "${first.startTime}\n~\n${last.endTime}",
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 9,
            fontWeight: FontWeight.w600,
            color: _textColor(first.role),
          ),
        ),

        const SizedBox(height: 6),
        */

            Expanded(
              child: Center(
                child: Text(
                  names,
                  textAlign: TextAlign.center,
                  maxLines: 10,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 11,
                    //height: 1.2,
                    fontWeight: FontWeight.w500,
                    color: _textColor(first.role),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}