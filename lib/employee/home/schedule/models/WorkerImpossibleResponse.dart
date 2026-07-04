/// POST /api/work-places/{workPlaceId}/worker-select 요청 body
class WorkerImpossibleRequest {
  final int weekScheduleId;
  final List<int> timeDetails;

  WorkerImpossibleRequest({
    required this.weekScheduleId,
    required this.timeDetails,
  });

  Map<String, dynamic> toJson() => {
    "weekScheduleId": weekScheduleId,
    "timeDetails": timeDetails,
  };
}

/// 응답의 timeDetails 배열 각 항목
class WorkerImpossibleTimeDetail {
  final int timeDetailId;
  final String dayName;
  final String date;
  final int workPartNo;
  final String timeName;

  WorkerImpossibleTimeDetail({
    required this.timeDetailId,
    required this.dayName,
    required this.date,
    required this.workPartNo,
    required this.timeName,
  });

  factory WorkerImpossibleTimeDetail.fromJson(Map<String, dynamic> json) {
    return WorkerImpossibleTimeDetail(
      timeDetailId: json['timeDetailId'] ?? 0,
      dayName: json['dayName'] ?? '',
      date: json['date'] ?? '',
      workPartNo: json['workPartNo'] ?? 0,
      timeName: json['timeName'] ?? '',
    );
  }
}

/// POST /api/work-places/{workPlaceId}/worker-select 성공 응답 (201 Created)
/// 선택한 타임이 없는 경우(휴무 없음 체크) timeDetails: [] 로 응답
class WorkerImpossibleResponse {
  final int workPlaceId;
  final int memberId;
  final List<WorkerImpossibleTimeDetail> timeDetails;

  WorkerImpossibleResponse({
    required this.workPlaceId,
    required this.memberId,
    required this.timeDetails,
  });

  factory WorkerImpossibleResponse.fromJson(Map<String, dynamic> json) {
    return WorkerImpossibleResponse(
      workPlaceId: json['workPlaceId'] ?? 0,
      memberId: json['memberId'] ?? 0,
      timeDetails: (json['timeDetails'] as List? ?? [])
          .map((e) => WorkerImpossibleTimeDetail.fromJson(e))
          .toList(),
    );
  }
}