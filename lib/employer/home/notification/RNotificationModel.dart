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

// 공감 이모지는 유니코드가 아니라 Figma에서 그린 커스텀 SVG 일러스트라서
// 문자열 대신 에셋 경로로 매핑한다.
const Map<String, String> reactionAssetMap = {
  "HEART": "assets/images/reactions/heart.svg",
  "CHECK": "assets/images/reactions/check.svg",
  "NEUTRAL": "assets/images/reactions/neutral.svg",
  "SMILE": "assets/images/reactions/smile.svg",
  "KISS": "assets/images/reactions/kiss.svg",
  "PROUD": "assets/images/reactions/proud.svg",
};

// 공감 선택/변경/취소(PUT) API 응답 — noticeId, myReactionType, reactions만 내려온다.
class NoticeReactionResult {
  final int noticeId;
  final String? myReactionType;
  final List<NoticeReaction> reactions;

  NoticeReactionResult({
    required this.noticeId,
    required this.myReactionType,
    required this.reactions,
  });

  factory NoticeReactionResult.fromJson(Map<String, dynamic> json) {
    return NoticeReactionResult(
      noticeId: json['noticeId'] ?? 0,
      myReactionType: json['myReactionType'],
      reactions: (json['reactions'] as List? ?? [])
          .map((e) => NoticeReaction.fromJson(e))
          .toList(),
    );
  }
}

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

  // 공감 API 응답(noticeId, myReactionType, reactions)으로 이 두 필드만 갱신할 때 쓴다.
  // myReactionType은 취소 시 null이 되는 게 정상 상태라서, 다른 필드와 달리 ?? 로 기존 값을
  // 유지하지 않고 넘어온 값을 그대로 반영한다 — 그래서 호출부는 항상 명시적으로 넘겨야 한다.
  NoticeModel copyWith({
    String? myReactionType,
    List<NoticeReaction>? reactions,
  }) {
    return NoticeModel(
      noticeId: noticeId,
      workPlaceId: workPlaceId,
      writerMemberId: writerMemberId,
      writerMemberName: writerMemberName,
      writerProfileImageUrl: writerProfileImageUrl,
      title: title,
      content: content,
      representative: representative,
      status: status,
      images: images,
      myReactionType: myReactionType,
      reactions: reactions ?? this.reactions,
      createdAt: createdAt,
      updatedAt: updatedAt,
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

  /// count > 0인 리액션만 (렌더링은 위젯에서 reactionAssetMap으로 처리)
  List<NoticeReaction> get activeReactions =>
      reactions.where((r) => r.count > 0).toList();
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