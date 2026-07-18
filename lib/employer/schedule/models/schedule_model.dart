import 'WorkersResponse.dart';
import 'AssignmentCreateResponse.dart';

class ScheduleModel {
  final String workName;
  final String startTime;
  final String endTime;
  final String breakTime;
  final List<DateTime> dates;
  final List<WorkerItem> workers;

  /// 서버가 실제로 생성한 근무 파트 정보 (날짜별로 여러 건일 수 있음).
  /// 재조회(GET) 없이 이 결과를 그대로 기존 목록에 추가하기 위해 보관한다.
  final List<AssignmentCreateResponse> createdAssignments;

  const ScheduleModel({
    required this.workName,
    required this.startTime,
    required this.endTime,
    required this.breakTime,
    required this.dates,
    required this.workers,
    required this.createdAssignments,
  });
}