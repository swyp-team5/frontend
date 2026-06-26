import 'package:flutter/material.dart';

class EWeekScheduleCard extends StatelessWidget {
  final List<dynamic> workers;
  final bool isAllView;

  const EWeekScheduleCard({
    super.key,
    required this.workers,
    required this.isAllView,
  });

  /// 개인보기 색상
  Color _myBackgroundColor(role) {
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

  Color _myTextColor(role) {
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

  /// 역할별 색상 (전체보기)
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

    final sorted = [...workers]
      ..sort((a, b) => a.startTime.compareTo(b.startTime));

    final first = sorted.first;

    final role = first.role;

    final last = sorted.reduce(
          (a, b) => a.endTime.compareTo(b.endTime) > 0 ? a : b,
    );

    final names = sorted.map((e) => e.name).join("\n");

    return Container(
      width: double.infinity,
      height: double.infinity,
      margin: EdgeInsets.zero,
      padding: EdgeInsets.zero,
      decoration: BoxDecoration(
        color: isAllView
            ? _backgroundColor(role) // 역할별
            : _myBackgroundColor(role),   // 개인보기
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // 필요하면 시간 표시
          /*
          Text(
            "${first.startTime}\n~ ${last.endTime}",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 9,
              fontWeight: FontWeight.w700,
              color: isAllView
                  ? _textColor(role)
                  : _myTextColor(),
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
                  fontWeight: FontWeight.w600,
                  color: isAllView
                      ? _textColor(role)
                      : _myTextColor(role),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}