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

// import 'ShiftCount.dart';
//
// class ScheduleScenario {
//   final int candidateNo; // 추가: 서버에 confirmed 요청 시 필요
//   final String title; // 시안 1, 시안 2, ...
//
//   final List<ShiftCount> open;
//   final List<ShiftCount> middle;
//   final List<ShiftCount> close;
//
//   const ScheduleScenario({
//     required this.candidateNo,
//     required this.title,
//     required this.open,
//     required this.middle,
//     required this.close,
//   });
// }