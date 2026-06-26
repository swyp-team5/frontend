import 'package:flutter/material.dart';

class RWeekUtils {
  /// yyyy-MM-dd 문자열
  static String dateKey(DateTime date) {
    return "${date.year.toString().padLeft(4, '0')}-"
        "${date.month.toString().padLeft(2, '0')}-"
        "${date.day.toString().padLeft(2, '0')}";
  }

  /// 월요일 기준 시작일
  static DateTime getMonday(DateTime date) {
    return date.subtract(
      Duration(days: date.weekday - 1),
    );
  }

  /// 해당 주의 월~일
  static List<DateTime> getWeekDates(DateTime date) {
    final monday = getMonday(date);

    return List.generate(
      7,
          (index) => monday.add(
        Duration(days: index),
      ),
    );
  }

  /// 몇 주차인지 계산
  static int getWeekOfMonth(DateTime date) {
    final firstDay = DateTime(
      date.year,
      date.month,
      1,
    );

    final firstWeekStart = firstDay.subtract(
      Duration(days: firstDay.weekday - 1),
    );

    return (date
        .difference(firstWeekStart)
        .inDays ~/
        7) +
        1;
  }

  /// 상단 제목
  static String getWeekTitle(DateTime date) {
    return "${date.year}년 "
        "${date.month}월 "
        "${getWeekOfMonth(date)}주차";
  }

  /// 09:00 → 9
  static int hour(String time) {
    return int.parse(
      time.split(":")[0],
    );
  }

  /// 09:30 → 9.5
  static double hourDouble(String time) {
    final parts = time.split(":");

    final h = int.parse(parts[0]);
    final m = int.parse(parts[1]);

    return h + (m / 60);
  }

  /// 셀 높이(80px 기준)
  static double top(String startTime) {
    return hourDouble(startTime) * 80;
  }

  /// 카드 높이
  static double height(
      String startTime,
      String endTime,
      ) {
    return (hourDouble(endTime) -
        hourDouble(startTime)) *
        80;
  }

  /// 휴무 여부
  static bool isHoliday(
      DateTime date,
      Set<String> holidays,
      ) {
    return holidays.contains(
      dateKey(date),
    );
  }

  /// 오늘인지
  static bool isToday(DateTime date) {
    final now = DateTime.now();

    return now.year == date.year &&
        now.month == date.month &&
        now.day == date.day;
  }

  /// 선택된 날짜인지
  static bool isSelected(
      DateTime date,
      DateTime selected,
      ) {
    return date.year == selected.year &&
        date.month == selected.month &&
        date.day == selected.day;
  }
}