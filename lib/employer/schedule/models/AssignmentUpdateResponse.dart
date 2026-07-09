class AssignmentUpdateResponse {
  final int confirmedWeekScheduleId;
  final int workPlaceId;
  final int weekScheduleId;
  final int dayId;
  final int timeDetailId;
  final String workDate;
  final int workPartNo;
  final String timeName;
  final String startTime; // "HH:mm:ss"
  final String closeTime; // "HH:mm:ss"
  final int restTime;
  final List<int> workerMemberIds;
  final int assignmentCount;

  AssignmentUpdateResponse({
    required this.confirmedWeekScheduleId,
    required this.workPlaceId,
    required this.weekScheduleId,
    required this.dayId,
    required this.timeDetailId,
    required this.workDate,
    required this.workPartNo,
    required this.timeName,
    required this.startTime,
    required this.closeTime,
    required this.restTime,
    required this.workerMemberIds,
    required this.assignmentCount,
  });

  factory AssignmentUpdateResponse.fromJson(Map<String, dynamic> json) {
    return AssignmentUpdateResponse(
      confirmedWeekScheduleId: json['confirmedWeekScheduleId'] as int,
      workPlaceId: json['workPlaceId'] as int,
      weekScheduleId: json['weekScheduleId'] as int,
      dayId: json['dayId'] as int,
      timeDetailId: json['timeDetailId'] as int,
      workDate: json['workDate'] as String,
      workPartNo: json['workPartNo'] as int,
      timeName: json['timeName'] as String,
      startTime: json['startTime'] as String,
      closeTime: json['closeTime'] as String,
      restTime: json['restTime'] as int? ?? 0,
      workerMemberIds: (json['workerMemberIds'] as List<dynamic>? ?? [])
          .map((e) => e as int)
          .toList(),
      assignmentCount: json['assignmentCount'] as int? ?? 0,
    );
  }
}