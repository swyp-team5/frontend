class CalendarActivateResponse {
  final int weekScheduleId;
  final int workPlaceId;
  final String weekScheduleName;
  final String dueDate;
  final List<AvailableDate> availableDates;

  CalendarActivateResponse({
    required this.weekScheduleId,
    required this.workPlaceId,
    required this.weekScheduleName,
    required this.dueDate,
    required this.availableDates,
  });

  factory CalendarActivateResponse.fromJson(Map<String, dynamic> json) {
    return CalendarActivateResponse(
      weekScheduleId: json['weekScheduleId'] ?? 0,
      workPlaceId: json['workPlaceId'] ?? 0,
      weekScheduleName: json['weekScheduleName'] ?? '',
      dueDate: json['dueDate'] ?? '',
      availableDates: (json['availableDates'] as List? ?? [])
          .map((e) => AvailableDate.fromJson(e))
          .toList(),
    );
  }

  /// "2026-06-08" 형태로 특정 날짜의 정보 찾기
  AvailableDate? findByDate(DateTime day) {
    final key =
        "${day.year.toString().padLeft(4, '0')}-${day.month.toString().padLeft(2, '0')}-${day.day.toString().padLeft(2, '0')}";
    for (final d in availableDates) {
      if (d.date == key) return d;
    }
    return null;
  }

  DateTime? get firstDate =>
      availableDates.isNotEmpty ? DateTime.parse(availableDates.first.date) : null;

  DateTime? get lastDate =>
      availableDates.isNotEmpty ? DateTime.parse(availableDates.last.date) : null;
}

class AvailableDate {
  final String date;
  final String dayName;
  final bool holidayStatus;
  final bool selectLimitStatus;

  AvailableDate({
    required this.date,
    required this.dayName,
    required this.holidayStatus,
    required this.selectLimitStatus,
  });

  factory AvailableDate.fromJson(Map<String, dynamic> json) {
    return AvailableDate(
      date: json['date'] ?? '',
      dayName: json['dayName'] ?? '',
      holidayStatus: json['holidayStatus'] ?? false,
      selectLimitStatus: json['selectLimitStatus'] ?? false,
    );
  }
}