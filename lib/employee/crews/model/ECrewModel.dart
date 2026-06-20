class ECrewModel {
  final String role;
  final String name;
  final List<String> tags;
  final bool isMe;

  ECrewModel({
    required this.role,
    required this.name,
    this.tags = const [],
    this.isMe = false,
  });
}