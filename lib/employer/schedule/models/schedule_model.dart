class ScheduleModel {
  final String workName;
  final String startTime;
  final String endTime;
  final String breakTime;
  final List<DateTime> dates;
  final List<String> workers;

  const ScheduleModel({
    required this.workName,
    required this.startTime,
    required this.endTime,
    required this.breakTime,
    required this.dates,
    required this.workers,
  });
}