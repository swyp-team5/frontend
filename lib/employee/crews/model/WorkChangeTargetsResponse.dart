class WorkChangeTargetsResponse {
  final int workPlaceId;
  final String fromDate;
  final String toDate;
  final List<WorkChangeDay> days;

  WorkChangeTargetsResponse({
    required this.workPlaceId,
    required this.fromDate,
    required this.toDate,
    required this.days,
  });

  factory WorkChangeTargetsResponse.fromJson(Map<String, dynamic> json) {
    return WorkChangeTargetsResponse(
      workPlaceId: json["workPlaceId"],
      fromDate: json["fromDate"],
      toDate: json["toDate"],
      days: (json["days"] as List)
          .map((e) => WorkChangeDay.fromJson(e))
          .toList(),
    );
  }
}

class WorkChangeDay {
  final DateTime workDate;
  final String dayName;
  final List<WorkChangeTimeDetail> timeDetails;

  WorkChangeDay({
    required this.workDate,
    required this.dayName,
    required this.timeDetails,
  });

  factory WorkChangeDay.fromJson(Map<String, dynamic> json) {
    return WorkChangeDay(
      workDate: DateTime.parse(json["workDate"]),
      dayName: json["dayName"],
      timeDetails: (json["timeDetails"] as List)
          .map((e) => WorkChangeTimeDetail.fromJson(e))
          .toList(),
    );
  }
}

class WorkChangeTimeDetail {
  final int timeDetailId;
  final String timeName;
  final int workPartNo;
  final String startTime;
  final String closeTime;
  final int restTime;
  final List<WorkChangeWorker> workers;

  WorkChangeTimeDetail({
    required this.timeDetailId,
    required this.timeName,
    required this.workPartNo,
    required this.startTime,
    required this.closeTime,
    required this.restTime,
    required this.workers,
  });

  factory WorkChangeTimeDetail.fromJson(Map<String, dynamic> json) {
    return WorkChangeTimeDetail(
      timeDetailId: json["timeDetailId"],
      timeName: json["timeName"],
      workPartNo: json["workPartNo"],
      startTime: json["startTime"],
      closeTime: json["closeTime"],
      restTime: json["restTime"],
      workers: (json["workers"] as List)
          .map((e) => WorkChangeWorker.fromJson(e))
          .toList(),
    );
  }
}

class WorkChangeWorker {
  final int assignmentId;
  final int memberId;
  final String name;
  final String? profileImageUrl;

  WorkChangeWorker({
    required this.assignmentId,
    required this.memberId,
    required this.name,
    this.profileImageUrl,
  });

  factory WorkChangeWorker.fromJson(Map<String, dynamic> json) {
    return WorkChangeWorker(
      assignmentId: json["assignmentId"],
      memberId: json["memberId"],
      name: json["name"],
      profileImageUrl: json["profileImageUrl"],
    );
  }
}