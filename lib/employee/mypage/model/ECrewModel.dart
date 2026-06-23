class ECrewModel {
  final String role;
  final String name;
  final List<String> tags;
  final bool showArrow;

  ECrewModel({
    required this.role,
    required this.name,
    required this.tags,
    this.showArrow = true,
  });
}