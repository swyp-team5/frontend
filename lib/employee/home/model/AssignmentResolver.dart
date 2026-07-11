import '../../crews/api/WorkChangeTargetsApi.dart';
import '../../crews/model/WorkChangeTargetsResponse.dart';

/// work-change-targets 응답에서 assignmentId 하나에 해당하는
/// 근무 날짜/시간/작업자 이름을 뽑아낸 결과
class ResolvedAssignment {
  final DateTime workDate;
  final String dayName;
  final String timeName;
  final String startTime; // "09:00"
  final String closeTime; // "18:00"
  final int memberId;
  final String workerName;

  ResolvedAssignment({
    required this.workDate,
    required this.dayName,
    required this.timeName,
    required this.startTime,
    required this.closeTime,
    required this.memberId,
    required this.workerName,
  });

  String get dateLabel => "${workDate.month}월 ${workDate.day}일";
  String get timeLabel => "$startTime - $closeTime";
}

class AssignmentResolver {
  /// [workPlaceId]의 [fromDate]~[toDate] 기간 근무자 목록을 조회한 뒤,
  /// assignmentId -> ResolvedAssignment 맵으로 변환합니다.
  static Future<Map<int, ResolvedAssignment>> buildAssignmentMap({
    required int workPlaceId,
    required String fromDate, // "yyyy-MM-dd"
    required String toDate, // "yyyy-MM-dd"
  }) async {
    final WorkChangeTargetsResponse response =
    await WorkChangeTargetsApi.fetchWorkers(
      workPlaceId: workPlaceId,
      fromDate: fromDate,
      toDate: toDate,
    );

    final map = <int, ResolvedAssignment>{};

    for (final day in response.days) {
      for (final timeDetail in day.timeDetails) {
        for (final worker in timeDetail.workers) {
          map[worker.assignmentId] = ResolvedAssignment(
            workDate: day.workDate,
            dayName: day.dayName,
            timeName: timeDetail.timeName,
            startTime: _shorten(timeDetail.startTime),
            closeTime: _shorten(timeDetail.closeTime),
            memberId: worker.memberId,
            workerName: worker.name,
          );
        }
      }
    }

    return map;
  }

  static String _shorten(String hhmmss) {
    return hhmmss.length >= 5 ? hhmmss.substring(0, 5) : hhmmss;
  }

  /// createdAt 기준 기본 조회 범위를 만들어줍니다.
  ///
  /// 서버 정책: "교대/대타 대상 근무는 오늘 이후의 확정 근무만 조회할 수 있습니다."
  /// 즉 fromDate는 절대 오늘 이전으로 내려갈 수 없다. createdAt이 오늘보다
  /// 과거여도(예: 어제 생성된 요청을 오늘 조회) fromDate는 오늘로 고정한다.
  static (String fromDate, String toDate) defaultRangeAround(
      DateTime pivot, {
        int daysAfter = 60,
      }) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final pivotDate = DateTime(pivot.year, pivot.month, pivot.day);

    final from = pivotDate.isBefore(today) ? today : pivotDate;
    final to = from.add(Duration(days: daysAfter));
    return (_formatDate(from), _formatDate(to));
  }

  static String _formatDate(DateTime d) {
    final y = d.year.toString().padLeft(4, '0');
    final m = d.month.toString().padLeft(2, '0');
    final day = d.day.toString().padLeft(2, '0');
    return "$y-$m-$day";
  }
}