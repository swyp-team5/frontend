class ScheduleGenerationRunResponse {
  final int scheduleGenerationRunId;
  final int schedulePreviewId;
  final int workPlaceId;
  final int weekScheduleId;
  final int candidateCount;
  final String status;

  ScheduleGenerationRunResponse({
    required this.scheduleGenerationRunId,
    required this.schedulePreviewId,
    required this.workPlaceId,
    required this.weekScheduleId,
    required this.candidateCount,
    required this.status,
  });

  factory ScheduleGenerationRunResponse.fromJson(Map<String, dynamic> json) {
    return ScheduleGenerationRunResponse(
      scheduleGenerationRunId: json['scheduleGenerationRunId'] ?? 0,
      schedulePreviewId: json['schedulePreviewId'] ?? 0,
      workPlaceId: json['workPlaceId'] ?? 0,
      weekScheduleId: json['weekScheduleId'] ?? 0,
      candidateCount: json['candidateCount'] ?? 0,
      status: json['status'] ?? '',
    );
  }
}