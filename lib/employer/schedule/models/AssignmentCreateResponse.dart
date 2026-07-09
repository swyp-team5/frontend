class AssignmentCreateResponse {
  final int confirmedWeekScheduleId;
  final int workPlaceId;
  final int weekScheduleId;
  final int dayId;
  final int timeDetailId;

  final String workDate;
  final int workPartNo;
  final String timeName;
  final String startTime;
  final String closeTime;
  final int restTime;

  final List<int> workerMemberIds;
  final int assignmentCount;

  AssignmentCreateResponse({
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

  factory AssignmentCreateResponse.fromJson(Map<String, dynamic> json) {
    return AssignmentCreateResponse(
      confirmedWeekScheduleId: json["confirmedWeekScheduleId"],
      workPlaceId: json["workPlaceId"],
      weekScheduleId: json["weekScheduleId"],
      dayId: json["dayId"],
      timeDetailId: json["timeDetailId"],
      workDate: json["workDate"],
      workPartNo: json["workPartNo"],
      timeName: json["timeName"],
      startTime: json["startTime"],
      closeTime: json["closeTime"],
      restTime: json["restTime"],
      workerMemberIds:
      List<int>.from(json["workerMemberIds"] ?? []),
      assignmentCount: json["assignmentCount"],
    );
  }
}