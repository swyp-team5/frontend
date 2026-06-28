class ShiftCount {
  final int count;
  final bool shortage;  // 부족

  const ShiftCount({
    required this.count,
    this.shortage = false,
  });
}