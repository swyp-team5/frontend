import 'ShiftType.dart';

class ShiftTime {
  final int start;
  final int end;

  const ShiftTime({
    required this.start,
    required this.end,
  });
}

ShiftTime getShiftTime(ShiftType type) {
  switch (type) {
    case ShiftType.open:
      return const ShiftTime(start: 9, end: 12);

    case ShiftType.middle:
      return const ShiftTime(start: 12, end: 16);

    case ShiftType.close:
      return const ShiftTime(start: 16, end: 20);
  }
}