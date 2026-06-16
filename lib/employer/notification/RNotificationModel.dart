class RNotificationModel {
  final String title;
  final String content;
  final String writer;
  final String date;
  final List<String> reactions;

  RNotificationModel({
    required this.title,
    required this.content,
    required this.writer,
    required this.date,
    this.reactions = const [],
  });

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'content': content,
      'writer': writer,
      'date': date,
      'reactions': reactions,
    };
  }

  factory RNotificationModel.fromJson(
      Map<String, dynamic> json) {
    return RNotificationModel(
      title: json['title'],
      content: json['content'],
      writer: json['writer'],
      date: json['date'],
      reactions:
      List<String>.from(json['reactions'] ?? []),
    );
  }

  RNotificationModel copyWith({
    String? title,
    String? content,
    String? writer,
    String? date,
    List<String>? reactions,
  }) {
    return RNotificationModel(
      title: title ?? this.title,
      content: content ?? this.content,
      writer: writer ?? this.writer,
      date: date ?? this.date,
      reactions: reactions ?? this.reactions,
    );
  }
}