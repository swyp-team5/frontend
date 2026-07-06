class SchedulePreviewResponse {
  final int scheduleGenerationRunId;
  final int schedulePreviewId;
  final int workPlaceId;
  final int weekScheduleId;
  final int candidateCount;
  final List<PreviewCandidate> candidates;

  SchedulePreviewResponse({
    required this.scheduleGenerationRunId,
    required this.schedulePreviewId,
    required this.workPlaceId,
    required this.weekScheduleId,
    required this.candidateCount,
    required this.candidates,
  });

  factory SchedulePreviewResponse.fromJson(Map<String, dynamic> json) {
    final previewData = json['previewData'] as Map<String, dynamic>;

    return SchedulePreviewResponse(
      scheduleGenerationRunId: json['scheduleGenerationRunId'] as int,
      schedulePreviewId: json['schedulePreviewId'] as int,
      workPlaceId: json['workPlaceId'] as int,
      weekScheduleId: json['weekScheduleId'] as int,
      candidateCount: previewData['candidateCount'] as int,
      candidates: (previewData['candidates'] as List)
          .map((e) => PreviewCandidate.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

class PreviewCandidate {
  final int candidateNo;
  final int score;
  final List<PreviewDay> days;

  PreviewCandidate({
    required this.candidateNo,
    required this.score,
    required this.days,
  });

  factory PreviewCandidate.fromJson(Map<String, dynamic> json) {
    return PreviewCandidate(
      candidateNo: json['candidateNo'] as int,
      score: json['score'] as int,
      days: (json['days'] as List)
          .map((e) => PreviewDay.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

class PreviewDay {
  final int dayId;
  final List<PreviewTimeDetail> timeDetails;

  PreviewDay({
    required this.dayId,
    required this.timeDetails,
  });

  factory PreviewDay.fromJson(Map<String, dynamic> json) {
    return PreviewDay(
      dayId: json['dayId'] as int,
      timeDetails: (json['timeDetails'] as List)
          .map((e) => PreviewTimeDetail.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

class PreviewTimeDetail {
  final int timeDetailId;
  final List<int> workerMemberIds;

  PreviewTimeDetail({
    required this.timeDetailId,
    required this.workerMemberIds,
  });

  factory PreviewTimeDetail.fromJson(Map<String, dynamic> json) {
    return PreviewTimeDetail(
      timeDetailId: json['timeDetailId'] as int,
      workerMemberIds: List<int>.from(json['workerMemberIds'] ?? []),
    );
  }
}