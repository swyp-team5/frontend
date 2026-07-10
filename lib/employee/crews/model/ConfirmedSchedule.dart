/// GET /api/me/confirmed-schedules 응답의 schedules 배열 원소 하나
class ConfirmedSchedule {
  final int workPlaceId;
  final String workPlaceName;
  final DateTime workDate;
  final String dayName;
  final int timeDetailId;
  final String timeName;
  final int workPartNo;
  final int assignmentId;

  /// 서버는 "09:00:00" 형태(HH:mm:ss)로 내려줌
  final String startTime;
  final String closeTime;
  final int restTime;

  ConfirmedSchedule({
    required this.workPlaceId,
    required this.workPlaceName,
    required this.workDate,
    required this.dayName,
    required this.timeDetailId,
    required this.timeName,
    required this.workPartNo,
    required this.startTime,
    required this.closeTime,
    required this.restTime,
    required this.assignmentId,
  });

  factory ConfirmedSchedule.fromJson(Map<String, dynamic> json) {
    return ConfirmedSchedule(
      workPlaceId: json['workPlaceId'] as int,
      workPlaceName: json['workPlaceName'] as String,
      workDate: DateTime.parse(json['workDate'] as String),
      dayName: json['dayName'] as String,
      timeDetailId: json['timeDetailId'] as int,
      timeName: json['timeName'] as String,
      workPartNo: json['workPartNo'] as int,
      startTime: json['startTime'] as String,
      closeTime: json['closeTime'] as String,
      restTime: json['restTime'] as int,
      assignmentId: json['assignmentId'] as int,
    );
  }

  /// "09:00:00" -> "09:00" (화면 표시용)
  String get startTimeShort =>
      startTime.length >= 5 ? startTime.substring(0, 5) : startTime;

  String get closeTimeShort =>
      closeTime.length >= 5 ? closeTime.substring(0, 5) : closeTime;
}

/// GET /api/me/confirmed-schedules 전체 응답
class ConfirmedScheduleResponse {
  final DateTime from;
  final DateTime to;
  final List<ConfirmedSchedule> schedules;

  ConfirmedScheduleResponse({
    required this.from,
    required this.to,
    required this.schedules,
  });

  factory ConfirmedScheduleResponse.fromJson(Map<String, dynamic> json) {
    return ConfirmedScheduleResponse(
      from: DateTime.parse(json['from'] as String),
      to: DateTime.parse(json['to'] as String),
      schedules: (json['schedules'] as List<dynamic>? ?? [])
          .map((e) => ConfirmedSchedule.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}