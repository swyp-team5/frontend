class TimeDetail {
  final int workPartNo;
  final String timeName;
  final int workerCount;
  final String startTime; // "HH:mm:ss"
  final String closeTime;
  final int restTime;

  TimeDetail({
    required this.workPartNo,
    required this.timeName,
    required this.workerCount,
    required this.startTime,
    required this.closeTime,
    required this.restTime,
  });

  Map<String, dynamic> toJson() => {
    "workPartNo": workPartNo,
    "timeName": timeName,
    "workerCount": workerCount,
    "startTime": startTime,
    "closeTime": closeTime,
    "restTime": restTime,
  };
}

class DayCondition {
  final String dayName;
  final String date;
  final int? groupingId;
  final int workChangeCount;
  final bool holidayStatus;
  final bool selectLimitStatus;
  final List<TimeDetail> timeDetails;

  DayCondition({
    required this.dayName,
    required this.date,
    required this.groupingId,
    required this.workChangeCount,
    required this.holidayStatus,
    required this.selectLimitStatus,
    required this.timeDetails,
  });

  Map<String, dynamic> toJson() => {
    "dayName": dayName,
    "date": date,
    "groupingId": groupingId,
    "workChangeCount": workChangeCount,
    "holidayStatus": holidayStatus,
    "selectLimitStatus": selectLimitStatus,
    "timeDetails": timeDetails.map((e) => e.toJson()).toList(),
  };
}

class ScheduleConditionRequest {
  final String workPlaceOpenTime;
  final String workPlaceCloseTime;
  final int minPersonalWorkCount;
  final int maxPersonalWorkCount;
  final String dueDate;
  final List<DayCondition> days;

  ScheduleConditionRequest({
    required this.workPlaceOpenTime,
    required this.workPlaceCloseTime,
    required this.minPersonalWorkCount,
    required this.maxPersonalWorkCount,
    required this.dueDate,
    required this.days,
  });

  Map<String, dynamic> toJson() => {
    "workPlaceOpenTime": workPlaceOpenTime,
    "workPlaceCloseTime": workPlaceCloseTime,
    "minPersonalWorkCount": minPersonalWorkCount,
    "maxPersonalWorkCount": maxPersonalWorkCount,
    "dueDate": dueDate,
    "days": days.map((e) => e.toJson()).toList(),
  };
}

class ScheduleConditionResponse {
  final int weekScheduleId;
  final int workPlaceId;
  final String weekScheduleName;
  final String dueDate;
  final String status;
  final DateTime createdAt;
  final DateTime updatedAt;

  ScheduleConditionResponse({
    required this.weekScheduleId,
    required this.workPlaceId,
    required this.weekScheduleName,
    required this.dueDate,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ScheduleConditionResponse.fromJson(Map<String, dynamic> json) {
    return ScheduleConditionResponse(
      weekScheduleId: json['weekScheduleId'],
      workPlaceId: json['workPlaceId'],
      weekScheduleName: json['weekScheduleName'],
      dueDate: json['dueDate'],
      status: json['status'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }
}