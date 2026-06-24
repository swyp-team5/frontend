class RCrewModel {
  final String role;
  final String name;
  List<String> tags;
  final bool showArrow;

  RCrewModel({
    required this.role,
    required this.name,
    this.tags = const [],
    this.showArrow = true,
  });

  Map<String, dynamic> toJson() => {
    "role": role,
    "name": name,
    "tags": tags,
  };

  factory RCrewModel.fromJson(Map<String, dynamic> json) {
    return RCrewModel(
      role: json["role"],
      name: json["name"],
      tags: List<String>.from(json["tags"]),
    );
  }
}
