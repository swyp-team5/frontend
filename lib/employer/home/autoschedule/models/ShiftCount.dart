class ShiftCount {
  /// 사장님이 필요로 하는 인원
  final int required;

  /// 근무 가능한 직원 이름
  final List<String> workers;

  /// 이 날짜에 이 타임(row) 자체가 없음 (휴무 슬롯)
  final bool isOff;

  /// 실제 근무 시간 (상세 화면 타임블록 위치 계산용)
  final String? startTime; // "09:00"
  final String? closeTime; // "13:00"

  const ShiftCount({
    required this.required,
    this.workers = const [],
    this.isOff = false,
    this.startTime,
    this.closeTime,
  });

  /// 실제 배치 가능한 인원
  int get available => workers.length;

  /// 부족 여부
  bool get shortage => !isOff && available < required;

  /// 부족 인원
  int get shortageCount => required - available;
}