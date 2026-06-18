class RNotificationModel {
  final String title;
  final String content;
  final String writer;
  final String date;
  final String? imagePath;
  final List<String> reactions;

  RNotificationModel({
    required this.title,
    required this.content,
    required this.writer,
    required this.date,
    this.imagePath,
    this.reactions = const [],
  });

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'content': content,
      'writer': writer,
      'date': date,
      'imagePath': imagePath,
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
      imagePath: json['imagePath'],
      reactions: List<String>.from(json['reactions'] ?? []),
    );
  }

  RNotificationModel copyWith({
    String? title,
    String? content,
    String? writer,
    String? date,
    String? imagePath,
    List<String>? reactions,
  }) {
    return RNotificationModel(
      title: title ?? this.title,
      content: content ?? this.content,
      writer: writer ?? this.writer,
      date: date ?? this.date,
      imagePath: imagePath ?? this.imagePath,
      reactions: reactions ?? this.reactions,
    );
  }
}