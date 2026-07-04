class DayTimeDetailsResponse {
  final int weekScheduleId;
  final String date;
  final String dayName;
  final List<DayTimeDetail> timeDetails;

  DayTimeDetailsResponse({
    required this.weekScheduleId,
    required this.date,
    required this.dayName,
    required this.timeDetails,
  });

  factory DayTimeDetailsResponse.fromJson(Map<String, dynamic> json) {
    return DayTimeDetailsResponse(
      weekScheduleId: json['weekScheduleId'] ?? 0,
      date: json['date'] ?? '',
      dayName: json['dayName'] ?? '',
      timeDetails: (json['timeDetails'] as List? ?? [])
          .map((e) => DayTimeDetail.fromJson(e))
          .toList(),
    );
  }
}

class DayTimeDetail {
  final int timeDetailId;
  final String timeName;
  final String startTime;
  final String closeTime;
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
      timeDetailId: json['timeDetailId'] ?? 0,
      timeName: json['timeName'] ?? '',
      startTime: json['startTime'] ?? '',
      closeTime: json['closeTime'] ?? '',
      workerCount: json['workerCount'] ?? 0,
    );
  }

  /// "09:00:00" → "09:00" 처럼 초 단위를 잘라서 "HH:mm" 형태만 남김
  static String _trim(String time) {
    return time.length >= 5 ? time.substring(0, 5) : time;
  }

  /// "09:00 - 12:00" 형태로 표시
  String get displayTime => "${_trim(startTime)} - ${_trim(closeTime)}";
}