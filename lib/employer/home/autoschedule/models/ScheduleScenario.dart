import 'ShiftCount.dart';

class ShiftRowData {
  /// 타임 이름 (예: "오픈", "미들", "마감", "오전근무" 등 — 매장마다 다름)
  final String title;

  /// 항상 7개 (월~일)
  final List<ShiftCount> counts;

  const ShiftRowData({
    required this.title,
    required this.counts,
  });
}

class ScheduleScenario {
  final int candidateNo; // 서버에 confirmed 요청 시 필요
  final String title; // "시안 1", "시안 2" ...

  /// 타임 종류만큼의 행 (가변 개수)
  final List<ShiftRowData> rows;

  const ScheduleScenario({
    required this.candidateNo,
    required this.title,
    required this.rows,
  });
}