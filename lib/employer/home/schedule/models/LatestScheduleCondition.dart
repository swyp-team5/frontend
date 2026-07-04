class LatestTimeDetail {
  final int timeDetailId;
  final int workPartNo;
  final String timeName;
  final int workerCount;
  final String startTime;
  final String closeTime;
  final int restMinutes;

  LatestTimeDetail({
    required this.timeDetailId,
    required this.workPartNo,
    required this.timeName,
    required this.workerCount,
    required this.startTime,
    required this.closeTime,
    required this.restMinutes,
  });

  factory LatestTimeDetail.fromJson(Map<String, dynamic> json) {
    return LatestTimeDetail(
      timeDetailId: json['timeDetailId'] ?? 0,
      workPartNo: json['workPartNo'] ?? 0,
      timeName: json['timeName'] ?? '',
      workerCount: json['workerCount'] ?? 0,
      startTime: json['startTime'] ?? '00:00:00',
      closeTime: json['closeTime'] ?? '00:00:00',
      restMinutes: json['restMinutes'] ?? 0,
    );
  }
}

class LatestScheduleGroup {
  final int groupingId;
  final List<String> dayNames;
  final String workPlaceOpenTime;
  final String workPlaceCloseTime;
  final int minPersonalWorkCount;
  final int maxPersonalWorkCount;
  final List<LatestTimeDetail> timeDetails;

  LatestScheduleGroup({
    required this.groupingId,
    required this.dayNames,
    required this.workPlaceOpenTime,
    required this.workPlaceCloseTime,
    required this.minPersonalWorkCount,
    required this.maxPersonalWorkCount,
    required this.timeDetails,
  });

  factory LatestScheduleGroup.fromJson(Map<String, dynamic> json) {
    return LatestScheduleGroup(
      groupingId: json['groupingId'] ?? 0,
      dayNames: List<String>.from(json['dayNames'] ?? []),
      workPlaceOpenTime: json['workPlaceOpenTime'] ?? '00:00:00',
      workPlaceCloseTime: json['workPlaceCloseTime'] ?? '00:00:00',
      minPersonalWorkCount: json['minPersonalWorkCount'] ?? 0,
      maxPersonalWorkCount: json['maxPersonalWorkCount'] ?? 0,
      timeDetails: (json['timeDetails'] as List? ?? [])
          .map((e) => LatestTimeDetail.fromJson(e))
          .toList(),
    );
  }
}

class LatestScheduleResponse {
  final int weekScheduleId;
  final int workPlaceId;
  final String weekScheduleName;
  final String nextWeekScheduleName;
  final String dueDate;
  final List<LatestScheduleGroup> groups;

  LatestScheduleResponse({
    required this.weekScheduleId,
    required this.workPlaceId,
    required this.weekScheduleName,
    required this.nextWeekScheduleName,
    required this.dueDate,
    required this.groups,
  });

  factory LatestScheduleResponse.fromJson(Map<String, dynamic> json) {
    return LatestScheduleResponse(
      weekScheduleId: json['weekScheduleId'] ?? 0,
      workPlaceId: json['workPlaceId'] ?? 0,
      weekScheduleName: json['weekScheduleName'] ?? '',
      nextWeekScheduleName: json['nextWeekScheduleName'] ?? '',
      dueDate: json['dueDate'] ?? '',
      groups: (json['groups'] as List? ?? [])
          .map((e) => LatestScheduleGroup.fromJson(e))
          .toList(),
    );
  }
}