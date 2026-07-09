import 'ConfirmedSchedulesResponse.dart' show ConfirmedScheduleDay;

/// GET /api/work-places/{workPlaceId}/confirmed-schedules/weekly?weekStartDate={weekStartDate}
/// 응답 모델. days의 구조는 ConfirmedScheduleDay(=ConfirmedSchedulesResponse에서 쓰는 것)와 동일.
class ConfirmedWeeklyScheduleResponse {
  final int workPlaceId;
  final int weekScheduleId;
  final int confirmedWeekScheduleId;
  final String weekStartDate; // "yyyy-MM-dd"
  final String weekEndDate; // "yyyy-MM-dd"
  final List<ConfirmedScheduleDay> days;

  ConfirmedWeeklyScheduleResponse({
    required this.workPlaceId,
    required this.weekScheduleId,
    required this.confirmedWeekScheduleId,
    required this.weekStartDate,
    required this.weekEndDate,
    required this.days,
  });

  factory ConfirmedWeeklyScheduleResponse.fromJson(Map<String, dynamic> json) {
    return ConfirmedWeeklyScheduleResponse(
      workPlaceId: json['workPlaceId'] as int,
      weekScheduleId: json['weekScheduleId'] as int,
      confirmedWeekScheduleId: json['confirmedWeekScheduleId'] as int,
      weekStartDate: json['weekStartDate'] as String,
      weekEndDate: json['weekEndDate'] as String,
      days: (json['days'] as List<dynamic>? ?? [])
          .map((e) => ConfirmedScheduleDay.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}