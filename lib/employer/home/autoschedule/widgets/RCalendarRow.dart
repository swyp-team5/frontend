import 'package:flutter/material.dart';
import '../models/ScheduleScenario.dart';
import 'RShiftRow.dart';

class RCalendarRow extends StatelessWidget {
  final ScheduleScenario scenario;

  const RCalendarRow({
    super.key,
    required this.scenario,
  });

  @override
  Widget build(BuildContext context) {

    final now = DateTime.now();

    final nextMonday = DateTime(
      now.year, now.month, now.day,).add(Duration(days: 8 - now.weekday));

    final weekDays = List.generate(
      7,
          (index) => nextMonday.add(Duration(days: index)),
    );

    const weekText = ["월", "화", "수", "목", "금", "토", "일",];

    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(
        horizontal: 20,
        vertical: 16,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 5,
            ),
            decoration: BoxDecoration(
              color: const Color(0xFF1687F8),
              borderRadius: BorderRadius.circular(30),
            ),
            child: Text(
              scenario.title,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          const SizedBox(height: 16),

          Row(
            children: [
              const SizedBox(width: 52),

              ...List.generate(7, (index) {
                final day = weekDays[index];

                return Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        weekText[index],
                        style: const TextStyle(
                          fontSize: 13,
                          color: Color(0xFF8B8B8B),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      // const SizedBox(height: 4),
                      // Text(
                      //   "${day.month}/${day.day}",
                      //   style: const TextStyle(
                      //     fontSize: 15,
                      //     fontWeight: FontWeight.w600,
                      //   ),
                      // ),
                    ],
                  ),
                );
              }),
            ],
          ),

          const Divider(),

          RShiftRow(
            title: "오픈",
            counts: scenario.open,
          ),

          const Divider(),

          RShiftRow(
            title: "미들",
            counts: scenario.middle,
          ),

          const Divider(),

          RShiftRow(
            title: "마감",
            counts: scenario.close,
          ),
        ],
      ),
    );
  }
}