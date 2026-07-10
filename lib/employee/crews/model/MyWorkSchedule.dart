/// 근무 일정 데이터 모델
///
/// 내 근무, 근무자1, 근무자2 등 모든 근무 일정을 표현하는 데 사용됩니다.
class MyWorkSchedule {
  final String name;
  final DateTime date;
  final String role;
  final String startTime;
  final String endTime;

  const MyWorkSchedule({
    required this.name,
    required this.date,
    required this.role,
    required this.startTime,
    required this.endTime,
  });
}