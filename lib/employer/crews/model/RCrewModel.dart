class CrewModel {
  final String role;
  final String name;
  final List<String> tags;
  final bool showArrow;

  CrewModel({
    required this.role,
    required this.name,
    required this.tags,
    this.showArrow = true,
  });
}