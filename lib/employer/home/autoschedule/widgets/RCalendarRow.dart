import 'package:flutter/material.dart';
import '../models/ScheduleScenario.dart';
import 'RShiftRow.dart';

class RCalendarRow extends StatelessWidget {
  final ScheduleScenario scenario;
  final VoidCallback? onTap;

  const RCalendarRow({
    super.key,
    required this.scenario,
    this.onTap,
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


    return Material(
      color: Colors.white,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          color: Colors.white,
          padding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 8,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 50,
                    height: 28,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: const Color(0xFF1687F8),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      scenario.title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),

                  ...List.generate(7, (index) {
                    final day = weekDays[index];

                    return Expanded(
                      child: Center(
                        child: Text(
                          "${day.day}",
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w400,
                            color: Colors.black,
                          ),
                        ),
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
        ),
      ),
    );
  }
}