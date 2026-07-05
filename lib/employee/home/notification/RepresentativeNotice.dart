class RepresentativeNotice {
  final int noticeId;
  final String title;
  final String content;
  final String writerMemberName;
  final DateTime createdAt;

  RepresentativeNotice({
    required this.noticeId,
    required this.title,
    required this.content,
    required this.writerMemberName,
    required this.createdAt,
  });

  factory RepresentativeNotice.fromJson(Map<String, dynamic> json) {
    return RepresentativeNotice(
      noticeId: json['noticeId'] as int,
      title: json['title'] as String? ?? '',
      content: json['content'] as String? ?? '',
      writerMemberName: json['writerMemberName'] as String? ?? '',
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }
}