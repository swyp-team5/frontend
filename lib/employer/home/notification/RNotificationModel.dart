class NoticeImage {
  final int noticeImageId;
  final String originalFileName;
  final String storedFileName;
  final String objectKey;
  final String imageUrl;
  final String contentType;
  final int fileSize;
  final int displayOrder;

  NoticeImage({
    required this.noticeImageId,
    required this.originalFileName,
    required this.storedFileName,
    required this.objectKey,
    required this.imageUrl,
    required this.contentType,
    required this.fileSize,
    required this.displayOrder,
  });

  factory NoticeImage.fromJson(Map<String, dynamic> json) {
    return NoticeImage(
      noticeImageId: json['noticeImageId'] ?? 0,
      originalFileName: json['originalFileName'] ?? '',
      storedFileName: json['storedFileName'] ?? '',
      objectKey: json['objectKey'] ?? '',
      imageUrl: json['imageUrl'] ?? '',
      contentType: json['contentType'] ?? '',
      fileSize: json['fileSize'] ?? 0,
      displayOrder: json['displayOrder'] ?? 0,
    );
  }
}

class NoticeReaction {
  final String reactionType;
  final int count;

  NoticeReaction({required this.reactionType, required this.count});

  factory NoticeReaction.fromJson(Map<String, dynamic> json) {
    return NoticeReaction(
      reactionType: json['reactionType'] ?? '',
      count: json['count'] ?? 0,
    );
  }
}

/// 이모지 표시용 매핑 (필요에 맞게 조정 가능)
const Map<String, String> reactionEmojiMap = {
  "HEART": "❤️",
  "CHECK": "✅",
  "NEUTRAL": "😐",
  "SMILE": "😊",
  "KISS": "😘",
  "PROUD": "👍",
};

class NoticeModel {
  final int noticeId;
  final int workPlaceId;
  final int writerMemberId;
  final String writerMemberName;
  final String? writerProfileImageUrl;
  final String title;
  final String content;
  final bool representative;
  final String status;
  final List<NoticeImage> images;
  final String? myReactionType;
  final List<NoticeReaction> reactions;
  final String createdAt;
  final String updatedAt;

  NoticeModel({
    required this.noticeId,
    required this.workPlaceId,
    required this.writerMemberId,
    required this.writerMemberName,
    this.writerProfileImageUrl,
    required this.title,
    required this.content,
    required this.representative,
    required this.status,
    required this.images,
    required this.myReactionType,
    required this.reactions,
    required this.createdAt,
    required this.updatedAt,
  });

  factory NoticeModel.fromJson(Map<String, dynamic> json) {
    return NoticeModel(
      noticeId: json['noticeId'] ?? 0,
      workPlaceId: json['workPlaceId'] ?? 0,
      writerMemberId: json['writerMemberId'] ?? 0,
      writerMemberName: json['writerMemberName'] ?? '',
      writerProfileImageUrl: json['writerProfileImageUrl'],
      title: json['title'] ?? '',
      content: json['content'] ?? '',
      representative: json['representative'] ?? false,
      status: json['status'] ?? '',
      images: (json['images'] as List? ?? [])
          .map((e) => NoticeImage.fromJson(e))
          .toList(),
      myReactionType: json['myReactionType'],
      reactions: (json['reactions'] as List? ?? [])
          .map((e) => NoticeReaction.fromJson(e))
          .toList(),
      createdAt: json['createdAt'] ?? '',
      updatedAt: json['updatedAt'] ?? '',
    );
  }

  String get writer => writerMemberName;

  /// "2026-06-14T03:00:00" → "2026.06.14"
  String get date {
    if (createdAt.length < 10) return createdAt;
    return createdAt.substring(0, 10).replaceAll('-', '.');
  }

  /// 대표 이미지 1장의 URL
  String? get imageUrl => images.isNotEmpty ? images.first.imageUrl : null;

  /// count > 0인 리액션만 {이모지: count}로 변환
  Map<String, int> get reactionCounts {
    final Map<String, int> map = {};
    for (final r in reactions) {
      if (r.count > 0) {
        final emoji = reactionEmojiMap[r.reactionType] ?? r.reactionType;
        map[emoji] = r.count;
      }
    }
    return map;
  }
}

class NoticePageResponse {
  final List<NoticeModel> content;
  final int page;
  final int size;
  final int totalElements;
  final int totalPages;

  NoticePageResponse({
    required this.content,
    required this.page,
    required this.size,
    required this.totalElements,
    required this.totalPages,
  });

  factory NoticePageResponse.fromJson(Map<String, dynamic> json) {
    return NoticePageResponse(
      content: (json['content'] as List? ?? [])
          .map((e) => NoticeModel.fromJson(e))
          .toList(),
      page: json['page'] ?? 0,
      size: json['size'] ?? 20,
      totalElements: json['totalElements'] ?? 0,
      totalPages: json['totalPages'] ?? 0,
    );
  }
}