const employeeScheduleFallbackMessage = '근무표를 불러오지 못했어요. 잠시 후 다시 시도해주세요.';

class EmployeeScheduleException implements Exception {
  final String message;

  const EmployeeScheduleException(this.message);

  @override
  String toString() => message;
}

String employeeScheduleErrorMessage(Object error) {
  if (error is EmployeeScheduleException) {
    return _stripExceptionPrefix(error.message);
  }
  return employeeScheduleFallbackMessage;
}

/// 원본 예외 문자열이 EmployeeScheduleException.message에 그대로 들어온 경우
/// (예: EmployeeScheduleException(e.toString()))
/// 화면에 "Exception: "이 노출되지 않도록 접두어만 제거한다.
String _stripExceptionPrefix(String raw) {
  return raw.replaceFirst(RegExp(r'^(Exception|Error):\s*'), '');
}