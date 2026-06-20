class RCrewModel {
  final String role;
  final String name;
  final List<String> tags;
  final bool showArrow;

  RCrewModel({
    required this.role,
    required this.name,
    required this.tags,
    this.showArrow = true,
  });
}