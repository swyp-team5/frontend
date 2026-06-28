import 'ShiftCount.dart';

class ScheduleScenario {
  final String title; // 시안1, 시안2, ....

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