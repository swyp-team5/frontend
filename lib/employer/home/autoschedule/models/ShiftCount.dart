class ShiftCount {
  /// 사장님이 필요로 하는 인원
  final int required;

  /// 실제 배치 가능한 인원
  final int available;

  const ShiftCount({
    required this.required,
    required this.available,
  });

  /// 부족 여부
  bool get shortage => available < required;

  /// 부족 인원
  int get shortageCount => required - available;
}