class AssignmentUpdateRequest {
  final String workDate;
  final int workPartNo;
  final String timeName;
  final String startTime;
  final String closeTime;
  final int restTime;
  final List<int> workerMemberIds;

  AssignmentUpdateRequest({
    required this.workDate,
    required this.workPartNo,
    required this.timeName,
    required this.startTime,
    required this.closeTime,
    required this.restTime,
    required this.workerMemberIds,
  });

  Map<String, dynamic> toJson() {
    return {
      "workDate": workDate,
      "workPartNo": workPartNo,
      "timeName": timeName,
      "startTime": startTime,
      "closeTime": closeTime,
      "restTime": restTime,
      "workerMemberIds": workerMemberIds,
    };
  }
}