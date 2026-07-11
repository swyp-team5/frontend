class ConfirmedSchedulesResponse {
  final int workPlaceId;
  final String from;
  final String to;
  final List<ConfirmedScheduleDay> days;

  ConfirmedSchedulesResponse({
    required this.workPlaceId,
    required this.from,
    required this.to,
    required this.days,
  });

  factory ConfirmedSchedulesResponse.fromJson(Map<String, dynamic> json) {
    return ConfirmedSchedulesResponse(
      workPlaceId: json['workPlaceId'] as int,
      from: json['from'] as String,
      to: json['to'] as String,
      days: (json['days'] as List<dynamic>? ?? [])
          .map((e) => ConfirmedScheduleDay.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

class ConfirmedScheduleDay {
  final String workDate; // "yyyy-MM-dd"
  final String dayName;
  final List<ConfirmedTimeDetail> timeDetails;

  ConfirmedScheduleDay({
    required this.workDate,
    required this.dayName,
    required this.timeDetails,
  });

  factory ConfirmedScheduleDay.fromJson(Map<String, dynamic> json) {
    return ConfirmedScheduleDay(
      workDate: json['workDate'] as String,
      dayName: json['dayName'] as String,
      timeDetails: (json['timeDetails'] as List<dynamic>? ?? [])
          .map((e) => ConfirmedTimeDetail.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

class ConfirmedTimeDetail {
  final int timeDetailId;
  final String timeName; // 오픈 / 미들 / 마감
  final int workPartNo;
  final String startTime; // "HH:mm:ss"
  final String closeTime; // "HH:mm:ss"
  final int restTime;
  final List<ConfirmedWorker> workers;

  ConfirmedTimeDetail({
    required this.timeDetailId,
    required this.timeName,
    required this.workPartNo,
    required this.startTime,
    required this.closeTime,
    required this.restTime,
    required this.workers,
  });

  factory ConfirmedTimeDetail.fromJson(Map<String, dynamic> json) {
    return ConfirmedTimeDetail(
      timeDetailId: json['timeDetailId'] as int,
      timeName: json['timeName'] as String,
      workPartNo: json['workPartNo'] as int,
      startTime: json['startTime'] as String,
      closeTime: json['closeTime'] as String,
      restTime: json['restTime'] as int? ?? 0,
      workers: (json['workers'] as List<dynamic>? ?? [])
          .map((e) => ConfirmedWorker.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

class ConfirmedWorker {
  final int assignmentId;
  final int memberId;
  final String name;
  final String? profileImageUrl;

  ConfirmedWorker({
    required this.assignmentId,
    required this.memberId,
    required this.name,
    this.profileImageUrl,
  });

  factory ConfirmedWorker.fromJson(Map<String, dynamic> json) {
    return ConfirmedWorker(
      assignmentId: json['assignmentId'] as int,
      memberId: json['memberId'] as int,
      name: json['name'] as String,
      profileImageUrl: json['profileImageUrl'] as String?,
    );
  }
}