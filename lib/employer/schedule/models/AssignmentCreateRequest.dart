class AssignmentCreateRequest {
  final String workDate;
  final String timeName;
  final String startTime;
  final String closeTime;
  final int restTime;
  final List<int> workerMemberIds;

  AssignmentCreateRequest({
    required this.workDate,
    required this.timeName,
    required this.startTime,
    required this.closeTime,
    required this.restTime,
    required this.workerMemberIds,
  });

  Map<String, dynamic> toJson() {
    return {
      "workDate": workDate,
      "timeName": timeName,
      "startTime": startTime,
      "closeTime": closeTime,
      "restTime": restTime,
      "workerMemberIds": workerMemberIds,
    };
  }
}