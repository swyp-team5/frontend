class WeeklyWorkersResponse {
  final int workPlaceId;
  final String weekStartDate;
  final String weekEndDate;
  final List<WeeklyWorkerDay> days;

  WeeklyWorkersResponse({
    required this.workPlaceId,
    required this.weekStartDate,
    required this.weekEndDate,
    required this.days,
  });

  factory WeeklyWorkersResponse.fromJson(Map<String, dynamic> json) {
    return WeeklyWorkersResponse(
      workPlaceId: json["workPlaceId"],
      weekStartDate: json["weekStartDate"],
      weekEndDate: json["weekEndDate"],
      days: (json["days"] as List<dynamic>)
          .map((e) => WeeklyWorkerDay.fromJson(e))
          .toList(),
    );
  }
}

class WeeklyWorkerDay {
  final DateTime workDate;
  final String dayName;
  final List<WeeklyTimeDetail> timeDetails;

  WeeklyWorkerDay({
    required this.workDate,
    required this.dayName,
    required this.timeDetails,
  });

  factory WeeklyWorkerDay.fromJson(Map<String, dynamic> json) {
    return WeeklyWorkerDay(
      workDate: DateTime.parse(json["workDate"]),
      dayName: json["dayName"],
      timeDetails: (json["timeDetails"] as List<dynamic>)
          .map((e) => WeeklyTimeDetail.fromJson(e))
          .toList(),
    );
  }
}

class WeeklyTimeDetail {
  final int timeDetailId;
  final String timeName;
  final int workPartNo;
  final String startTime;
  final String closeTime;
  final int restTime;
  final List<WeeklyWorker> workers;

  WeeklyTimeDetail({
    required this.timeDetailId,
    required this.timeName,
    required this.workPartNo,
    required this.startTime,
    required this.closeTime,
    required this.restTime,
    required this.workers,
  });

  factory WeeklyTimeDetail.fromJson(Map<String, dynamic> json) {
    return WeeklyTimeDetail(
      timeDetailId: json["timeDetailId"],
      timeName: json["timeName"],
      workPartNo: json["workPartNo"],
      startTime: json["startTime"],
      closeTime: json["closeTime"],
      restTime: json["restTime"],
      workers: (json["workers"] as List<dynamic>)
          .map((e) => WeeklyWorker.fromJson(e))
          .toList(),
    );
  }
}

class WeeklyWorker {
  final int assignmentId;
  final int memberId;
  final String name;
  final String? profileImageUrl;

  WeeklyWorker({
    required this.assignmentId,
    required this.memberId,
    required this.name,
    this.profileImageUrl,
  });

  factory WeeklyWorker.fromJson(Map<String, dynamic> json) {
    return WeeklyWorker(
      assignmentId: json["assignmentId"],
      memberId: json["memberId"],
      name: json["name"],
      profileImageUrl: json["profileImageUrl"],
    );
  }
}