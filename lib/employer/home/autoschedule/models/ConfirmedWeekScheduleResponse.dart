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
      confirmedWeekScheduleId: json['confirmedWeekScheduleId'] ?? 0,
      workPlaceId: json['workPlaceId'] ?? 0,
      weekScheduleId: json['weekScheduleId'] ?? 0,
      selectedCandidateNo: json['selectedCandidateNo'] ?? 0,
      assignmentCount: json['assignmentCount'] ?? 0,
      status: json['status'] ?? '',
    );
  }
}