class ConfirmedWeekScheduleResponse {
  final int confirmedWeekScheduleId;
  final int workPlaceId;
  final int weekScheduleId;
  final int selectedCandidateNo;
  final int assignmentCount;
  final String status;

  ConfirmedWeekScheduleResponse({
    required this.confirmedWeekScheduleId,
    required this.workPlaceId,
    required this.weekScheduleId,
    required this.selectedCandidateNo,
    required this.assignmentCount,
    required this.status,
  });

  factory ConfirmedWeekScheduleResponse.fromJson(Map<String, dynamic> json) {
    return ConfirmedWeekScheduleResponse(
      confirmedWeekScheduleId: json['confirmedWeekScheduleId'] as int,
      workPlaceId: json['workPlaceId'] as int,
      weekScheduleId: json['weekScheduleId'] as int,
      selectedCandidateNo: json['selectedCandidateNo'] as int,
      assignmentCount: json['assignmentCount'] as int,
      status: json['status'] as String,
    );
  }
}