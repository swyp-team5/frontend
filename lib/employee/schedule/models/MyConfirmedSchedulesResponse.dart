/// 근무자(E) 권한 전용 모델
/// GET /api/me/confirmed-schedules 응답
class MyConfirmedSchedulesResponse {
  final String from;
  final String to;
  final List<EConfirmedSchedule> schedules;

  MyConfirmedSchedulesResponse({
    required this.from,
    required this.to,
    required this.schedules,
  });

  factory MyConfirmedSchedulesResponse.fromJson(Map<String, dynamic> json) {
    return MyConfirmedSchedulesResponse(
      from: json['from'] as String,
      to: json['to'] as String,
      schedules: (json['schedules'] as List<dynamic>? ?? [])
          .map((e) => EConfirmedSchedule.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

/// schedules[] 안의 개별 근무 항목 (근무자 본인 기준, 평면 구조)
class EConfirmedSchedule {
  final int workPlaceId;
  final String workPlaceName;
  final String workDate;   // "2026-07-06"
  final String dayName;    // "MONDAY"
  final int timeDetailId;
  final String timeName;   // "오픈"
  final int workPartNo;
  final String startTime;  // "09:00:00"
  final String closeTime;  // "13:00:00"
  final int restTime;      // 분 단위, 0이면 없음

  EConfirmedSchedule({
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
  });

  factory EConfirmedSchedule.fromJson(Map<String, dynamic> json) {
    return EConfirmedSchedule(
      workPlaceId: json['workPlaceId'] as int,
      workPlaceName: json['workPlaceName'] as String,
      workDate: json['workDate'] as String,
      dayName: json['dayName'] as String,
      timeDetailId: json['timeDetailId'] as int,
      timeName: json['timeName'] as String,
      workPartNo: json['workPartNo'] as int,
      startTime: json['startTime'] as String,
      closeTime: json['closeTime'] as String,
      restTime: (json['restTime'] as num).toInt(),
    );
  }
}