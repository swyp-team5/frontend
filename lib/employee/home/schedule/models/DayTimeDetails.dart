class DayTimeDetailsResponse {
  final int weekScheduleId;
  final String date; // "yyyy-MM-dd"
  final String dayName; // "MONDAY" 등
  final List<DayTimeDetail> timeDetails;

  DayTimeDetailsResponse({
    required this.weekScheduleId,
    required this.date,
    required this.dayName,
    required this.timeDetails,
  });

  factory DayTimeDetailsResponse.fromJson(Map<String, dynamic> json) {
    return DayTimeDetailsResponse(
      weekScheduleId: json['weekScheduleId'] as int,
      date: json['date'] as String,
      dayName: json['dayName'] as String,
      timeDetails: (json['timeDetails'] as List)
          .map((e) => DayTimeDetail.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

class DayTimeDetail {
  final int timeDetailId;
  final String timeName;
  final String startTime; // "09:00"
  final String closeTime; // "13:00"
  final int workerCount;

  DayTimeDetail({
    required this.timeDetailId,
    required this.timeName,
    required this.startTime,
    required this.closeTime,
    required this.workerCount,
  });

  factory DayTimeDetail.fromJson(Map<String, dynamic> json) {
    return DayTimeDetail(
      timeDetailId: json['timeDetailId'] as int,
      timeName: json['timeName'] as String,
      startTime: json['startTime'] as String,
      closeTime: json['closeTime'] as String,
      workerCount: json['workerCount'] as int,
    );
  }

  /// "09:00:00" → "09:00" 처럼 초 단위를 잘라서 "HH:mm" 형태만 남김
  static String _trim(String time) {
    return time.length >= 5 ? time.substring(0, 5) : time;
  }

  /// "09:00 - 12:00" 형태로 표시
  String get displayTime => "${_trim(startTime)} - ${_trim(closeTime)}";
}