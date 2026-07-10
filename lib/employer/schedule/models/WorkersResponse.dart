class WorkersResponse {
  final List<WorkerItem> workers;

  WorkersResponse({
    required this.workers,
  });

  factory WorkersResponse.fromJson(Map<String, dynamic> json) {
    final rawWorkers = json["crews"] as List<dynamic>? ?? [];

    return WorkersResponse(
      workers: rawWorkers
          .map((e) => WorkerItem.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

class WorkerItem {
  final int memberId;
  final String memberName;

  /// 이 엔드포인트(/crews) 응답에는 "제출 여부" 개념이 없습니다.
  /// 다른 화면(주간 스케줄 등)에서 재사용하기 위해 필드는 유지하되,
  /// 이 API 결과로 만들 때는 기본값 false 로 채워집니다.
  final bool submitted;

  WorkerItem({
    required this.memberId,
    required this.memberName,
    this.submitted = false,
  });

  factory WorkerItem.fromJson(Map<String, dynamic> json) {
    return WorkerItem(
      memberId: json["memberId"] as int,
      memberName: json["name"] as String,
      submitted: json["submitted"] as bool? ?? false,
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