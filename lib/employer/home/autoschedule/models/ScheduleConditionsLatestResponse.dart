class ScheduleConditionsLatestResponse {
  final int weekScheduleId;
  final int workPlaceId;
  final String weekScheduleName;
  final String? nextWeekScheduleName;
  final String dueDate;
  final List<ScheduleGroup> groups;

  ScheduleConditionsLatestResponse({
    required this.weekScheduleId,
    required this.workPlaceId,
    required this.weekScheduleName,
    this.nextWeekScheduleName,
    required this.dueDate,
    required this.groups,
  });

  factory ScheduleConditionsLatestResponse.fromJson(Map<String, dynamic> json) {
    return ScheduleConditionsLatestResponse(
      weekScheduleId: json['weekScheduleId'],
      workPlaceId: json['workPlaceId'],
      weekScheduleName: json['weekScheduleName'],
      nextWeekScheduleName: json['nextWeekScheduleName'],
      dueDate: json['dueDate'],
      groups: (json['groups'] as List)
          .map((g) => ScheduleGroup.fromJson(g))
          .toList(),
    );
  }
}

class ScheduleGroup {
  final int? groupingId; // nullable로 변경
  final List<String> dayNames;
  final String workPlaceOpenTime;
  final String workPlaceCloseTime;
  final int minPersonalWorkCount;
  final int maxPersonalWorkCount;
  final List<OwnerTimeDetail> timeDetails;

  ScheduleGroup({
    required this.groupingId,
    required this.dayNames,
    required this.workPlaceOpenTime,
    required this.workPlaceCloseTime,
    required this.minPersonalWorkCount,
    required this.maxPersonalWorkCount,
    required this.timeDetails,
  });

  factory ScheduleGroup.fromJson(Map<String, dynamic> json) {
    return ScheduleGroup(
      groupingId: json['groupingId'] as int?,
      dayNames: List<String>.from(json['dayNames'] ?? []),
      workPlaceOpenTime: json['workPlaceOpenTime'] ?? '',
      workPlaceCloseTime: json['workPlaceCloseTime'] ?? '',
      minPersonalWorkCount: json['minPersonalWorkCount'] ?? 0,
      maxPersonalWorkCount: json['maxPersonalWorkCount'] ?? 0,
      timeDetails: (json['timeDetails'] as List? ?? [])
          .map((td) => OwnerTimeDetail.fromJson(td))
          .toList(),
    );
  }
}

class OwnerTimeDetail {
  final int timeDetailId;
  final int workPartNo;
  final String timeName;
  final int workerCount;
  final String startTime;
  final String closeTime;
  final int restMinutes;

  OwnerTimeDetail({
    required this.timeDetailId,
    required this.workPartNo,
    required this.timeName,
    required this.workerCount,
    required this.startTime,
    required this.closeTime,
    required this.restMinutes,
  });

  factory OwnerTimeDetail.fromJson(Map<String, dynamic> json) {
    return OwnerTimeDetail(
      timeDetailId: json['timeDetailId'] ?? 0,
      workPartNo: json['workPartNo'] ?? 0,
      timeName: json['timeName'] ?? '',
      workerCount: json['workerCount'] ?? 0,
      startTime: json['startTime'] ?? '',
      closeTime: json['closeTime'] ?? '',
      restMinutes: json['restMinutes'] ?? 0,
    );
  }
}