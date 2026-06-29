import 'package:flutter/material.dart';
import '../Month/MySchedule/EMonthMyScheduleBottomSheet.dart';

class EWeekScheduleCard extends StatelessWidget {
  final List<MySchedule> workers;

  const EWeekScheduleCard({
    super.key,
    required this.workers,
  });

  Color _myBackgroundColor(String role) {
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

  Color _myTextColor(String role) {
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
    if (workers.isEmpty) return const SizedBox();

    final sorted = [...workers]
      ..sort((a, b) => a.startTime.compareTo(b.startTime));

    final first = sorted.first;

    final names = sorted.map((e) => e.name).join("\n");

    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: BoxDecoration(
        color: _myBackgroundColor(first.role),
      ),
      child: Center(
        child: Text(
          names,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: _myTextColor(first.role),
          ),
        ),
      ),
    );
  }
}