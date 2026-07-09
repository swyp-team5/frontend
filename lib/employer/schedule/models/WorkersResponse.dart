class WorkersResponse {
  final int workPlaceId;
  final int weekScheduleId;
  final List<WorkerItem> workers;

  WorkersResponse({
    required this.workPlaceId,
    required this.weekScheduleId,
    required this.workers,
  });

  factory WorkersResponse.fromJson(Map<String, dynamic> json) {
    return WorkersResponse(
      workPlaceId: json["workPlaceId"] as int,
      weekScheduleId: json["weekScheduleId"] as int,
      workers: (json["workers"] as List<dynamic>)
          .map((e) => WorkerItem.fromJson(e))
          .toList(),
    );
  }
}

class WorkerItem {
  final int memberId;
  final String memberName;
  final bool submitted;

  WorkerItem({
    required this.memberId,
    required this.memberName,
    required this.submitted,
  });

  factory WorkerItem.fromJson(Map<String, dynamic> json) {
    return WorkerItem(
      memberId: json["memberId"] as int,
      memberName: json["memberName"] as String,
      submitted: json["submitted"] as bool,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "memberId": memberId,
      "memberName": memberName,
      "submitted": submitted,
    };
  }
}