// 알림함(Alarm) 단건 응답 모델
// - "공지사항(Notice)" 도메인(RNotificationModel.dart의 NoticeModel)과는 다른 개념이라
//   이름이 겹치지 않도록 Alarm으로 구분해서 명명했다.
// - data는 FCM data payload를 그대로 담는 자유 형식 Map (예: {"noticeId": "1"}).
// - title은 서버가 내려주는 카테고리성 문구("공지 알림" 등)로, 화면에서 그대로 라벨처럼 쓴다.
class AlarmItem {
  final int notificationId;
  final String notificationType;
  final String pushPolicy;
  final String title;
  final String body;
  final Map<String, dynamic>? data;
  final bool read;
  final String? readAt;
  final String createdAt;

  AlarmItem({
    required this.notificationId,
    required this.notificationType,
    required this.pushPolicy,
    required this.title,
    required this.body,
    this.data,
    required this.read,
    this.readAt,
    required this.createdAt,
  });

  factory AlarmItem.fromJson(Map<String, dynamic> json) {
    return AlarmItem(
      notificationId: json['notificationId'] ?? 0,
      notificationType: json['notificationType'] ?? '',
      pushPolicy: json['pushPolicy'] ?? '',
      title: json['title'] ?? '',
      body: json['body'] ?? '',
      data: json['data'] is Map
          ? Map<String, dynamic>.from(json['data'])
          : null,
      read: json['read'] ?? false,
      readAt: json['readAt'],
      createdAt: json['createdAt'] ?? '',
    );
  }

  /// 목업처럼 "1시간 전" 형태의 상대 시간으로 변환
  String get relativeTime {
    final createdDate = DateTime.tryParse(createdAt);
    if (createdDate == null) return createdAt;

    final diff = DateTime.now().difference(createdDate);

    if (diff.inMinutes < 1) return "방금 전";
    if (diff.inMinutes < 60) return "${diff.inMinutes}분 전";
    if (diff.inHours < 24) return "${diff.inHours}시간 전";
    if (diff.inDays < 7) return "${diff.inDays}일 전";

    return "${createdDate.year}.${createdDate.month.toString().padLeft(2, '0')}.${createdDate.day.toString().padLeft(2, '0')}";
  }
}

// 알림함 커서 기반 페이지네이션 응답
// - 공지사항의 NoticePageResponse는 page/totalPages 방식이지만
//   알림함은 cursorId 방식이라 구조가 달라서 별도 클래스로 분리했다.
class AlarmPageResponse {
  final List<AlarmItem> content;
  final int? nextCursorId;
  final bool hasNext;

  AlarmPageResponse({
    required this.content,
    this.nextCursorId,
    required this.hasNext,
  });

  factory AlarmPageResponse.fromJson(Map<String, dynamic> json) {
    return AlarmPageResponse(
      content: (json['content'] as List? ?? [])
          .map((e) => AlarmItem.fromJson(e as Map<String, dynamic>))
          .toList(),
      nextCursorId: json['nextCursorId'],
      hasNext: json['hasNext'] ?? false,
    );
  }
}