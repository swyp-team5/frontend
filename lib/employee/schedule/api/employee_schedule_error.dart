const employeeScheduleFallbackMessage = '근무표를 불러오지 못했어요. 잠시 후 다시 시도해주세요.';

class EmployeeScheduleException implements Exception {
  final String message;

  const EmployeeScheduleException(this.message);

  @override
  String toString() => message;
}

String employeeScheduleErrorMessage(Object error) {
  if (error is EmployeeScheduleException) {
    return error.message;
  }
  return employeeScheduleFallbackMessage;
}
