class SubmitStatusResponse {
  final int workPlaceId;
  final int weekScheduleId;
  final List<WorkerSubmitStatus> workers;

  SubmitStatusResponse({
    required this.workPlaceId,
    required this.weekScheduleId,
    required this.workers,
  });

  factory SubmitStatusResponse.fromJson(Map<String, dynamic> json) {
    return SubmitStatusResponse(
      workPlaceId: json['workPlaceId'] ?? 0,
      weekScheduleId: json['weekScheduleId'] ?? 0,
      workers: (json['workers'] as List? ?? [])
          .map((e) => WorkerSubmitStatus.fromJson(e))
          .toList(),
    );
  }

  int get submittedCount => workers.where((w) => w.submitted).length;

  int get notSubmittedCount => workers.where((w) => !w.submitted).length;

  List<WorkerSubmitStatus> get submittedWorkers =>
      workers.where((w) => w.submitted).toList();

  List<WorkerSubmitStatus> get notSubmittedWorkers =>
      workers.where((w) => !w.submitted).toList();
}

class WorkerSubmitStatus {
  final int memberId;
  final String memberName;
  final bool submitted;

  WorkerSubmitStatus({
    required this.memberId,
    required this.memberName,
    required this.submitted,
  });

  factory WorkerSubmitStatus.fromJson(Map<String, dynamic> json) {
    return WorkerSubmitStatus(
      memberId: json['memberId'] ?? 0,
      memberName: json['memberName'] ?? '',
      submitted: json['submitted'] ?? false,
    );
  }
}