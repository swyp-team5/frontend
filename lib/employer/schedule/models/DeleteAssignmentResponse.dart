// models/DeleteAssignmentResponse.dart
class DeleteAssignmentResponse {
  final int confirmedWeekScheduleId;
  final int timeDetailId;
  final int deletedAssignmentCount;
  final String status;

  DeleteAssignmentResponse({
    required this.confirmedWeekScheduleId,
    required this.timeDetailId,
    required this.deletedAssignmentCount,
    required this.status,
  });

  factory DeleteAssignmentResponse.fromJson(Map<String, dynamic> json) {
    return DeleteAssignmentResponse(
      confirmedWeekScheduleId: json['confirmedWeekScheduleId'] as int,
      timeDetailId: json['timeDetailId'] as int,
      deletedAssignmentCount: json['deletedAssignmentCount'] as int,
      status: json['status'] as String,
    );
  }
}