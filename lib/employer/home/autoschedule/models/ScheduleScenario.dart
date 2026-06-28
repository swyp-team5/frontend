import 'ShiftCount.dart';

class ScheduleScenario {
  final String title; // 시안 1, 시안 2, ...

  final List<ShiftCount> open;
  final List<ShiftCount> middle;
  final List<ShiftCount> close;

  const ScheduleScenario({
    required this.title,
    required this.open,
    required this.middle,
    required this.close,
  });
}