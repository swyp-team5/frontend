import 'package:flutter/material.dart';
import '../Month/MySchedule/EMonthMyScheduleBottomSheet.dart';

class EWeekScheduleCard extends StatelessWidget {
  final List<MySchedule> workers;

  const EWeekScheduleCard({
    super.key,
    required this.workers,
  });

  /// timeName마다 색을 동적으로 배정하기 위한 팔레트
  /// 색이 부족하면 순환(rotate)해서 재사용
  static const List<Color> _bgColors = [
    Color(0xFFE6F3FF),
    Color(0xFFEEEBFF),
    Color(0xFFDCFED8),
    Color(0xFFFFEFD6),
    Color(0xFFFFE1E6),
    Color(0xFFE1F7F5),
  ];

  static const List<Color> _textColors = [
    Color(0xFF0063BF),
    Color(0xFF7D67FD),
    Color(0xFF007360),
    Color(0xFFC77700),
    Color(0xFFC03A54),
    Color(0xFF00877D),
  ];

  /// timeName -> 색상 인덱스 캐시 (static이라 위젯이 새로 생성돼도 유지됨)
  static final Map<String, int> _timeNameColorMap = {};
  static int _nextColorIndex = 0;

  static int _colorIndexForTimeName(String timeName) {
    if (_timeNameColorMap.containsKey(timeName)) {
      return _timeNameColorMap[timeName]!;
    }

    final assigned = _nextColorIndex % _bgColors.length;
    _timeNameColorMap[timeName] = assigned;
    _nextColorIndex++;

    return assigned;
  }

  Color _myBackgroundColor(String timeName) =>
      _bgColors[_colorIndexForTimeName(timeName)];

  Color _myTextColor(String timeName) =>
      _textColors[_colorIndexForTimeName(timeName)];

  @override
  Widget build(BuildContext context) {
    if (workers.isEmpty) return const SizedBox();

    final sorted = [...workers]
      ..sort((a, b) => a.startTime.compareTo(b.startTime));

    final first = sorted.first;

    final names = sorted.map((e) => e.name).join("\n");

    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: BoxDecoration(
        color: _myBackgroundColor(first.timeName),
      ),
      child: Center(
        child: Text(
          names,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: _myTextColor(first.timeName),
          ),
        ),
      ),
    );
  }
}