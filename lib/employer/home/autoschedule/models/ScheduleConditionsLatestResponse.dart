class ScheduleConditionsLatestResponse {
  final int weekScheduleId;
  final int workPlaceId;
  final String weekScheduleName;
  final String? nextWeekScheduleName;
  final String dueDate;
  final List<ScheduleConditionGroup> groups;

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
      weekScheduleId: json['weekScheduleId'] as int,
      workPlaceId: json['workPlaceId'] as int,
      weekScheduleName: json['weekScheduleName'] ?? '',
      nextWeekScheduleName: json['nextWeekScheduleName'],
      dueDate: json['dueDate'] ?? '',
      groups: (json['groups'] as List? ?? [])
          .map((e) => ScheduleConditionGroup.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  /// timeDetailId -> workerCount(필요 인원) 매핑
  Map<int, int> buildWorkerCountMap() {
    final map = <int, int>{};
    for (final group in groups) {
      for (final detail in group.timeDetails) {
        map[detail.timeDetailId] = detail.workerCount;
      }
    }
    return map;
  }
}

class ScheduleConditionGroup {
  final int groupingId;
  final List<String> dayNames;
  final String workPlaceOpenTime;
  final String workPlaceCloseTime;
  final int minPersonalWorkCount;
  final int maxPersonalWorkCount;
  final List<ScheduleConditionTimeDetail> timeDetails;

  ScheduleConditionGroup({
    required this.groupingId,
    required this.dayNames,
    required this.workPlaceOpenTime,
    required this.workPlaceCloseTime,
    required this.minPersonalWorkCount,
    required this.maxPersonalWorkCount,
    required this.timeDetails,
  });

  factory ScheduleConditionGroup.fromJson(Map<String, dynamic> json) {
    return ScheduleConditionGroup(
      groupingId: json['groupingId'] as int,
      dayNames: List<String>.from(json['dayNames'] ?? []),
      workPlaceOpenTime: json['workPlaceOpenTime'] ?? '',
      workPlaceCloseTime: json['workPlaceCloseTime'] ?? '',
      minPersonalWorkCount: json['minPersonalWorkCount'] ?? 0,
      maxPersonalWorkCount: json['maxPersonalWorkCount'] ?? 0,
      timeDetails: (json['timeDetails'] as List? ?? [])
          .map((e) => ScheduleConditionTimeDetail.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

class ScheduleConditionTimeDetail {
  final int timeDetailId;
  final int workPartNo;
  final String timeName;
  final int workerCount;
  final String startTime;
  final String closeTime;
  final int restMinutes;

  ScheduleConditionTimeDetail({
    required this.timeDetailId,
    required this.workPartNo,
    required this.timeName,
    required this.workerCount,
    required this.startTime,
    required this.closeTime,
    required this.restMinutes,
  });

  factory ScheduleConditionTimeDetail.fromJson(Map<String, dynamic> json) {
    return ScheduleConditionTimeDetail(
      timeDetailId: json['timeDetailId'] as int,
      workPartNo: json['workPartNo'] ?? 0,
      timeName: json['timeName'] ?? '',
      workerCount: json['workerCount'] ?? 0,
      startTime: json['startTime'] ?? '',
      closeTime: json['closeTime'] ?? '',
      restMinutes: json['restMinutes'] ?? 0,
    );
  }
}