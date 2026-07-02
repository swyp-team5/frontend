class RCrewModel {
  final int crewId;
  final int memberId;

  final String name;
  final String phoneNumber;
  final String? profileImageUrl;

  final String crewRole;
  final String joinStatus;
  final String crewStatus;

  final DateTime createdAt;

  RCrewModel({
    required this.crewId,
    required this.memberId,
    required this.name,
    required this.phoneNumber,
    required this.profileImageUrl,
    required this.crewRole,
    required this.joinStatus,
    required this.crewStatus,
    required this.createdAt,
  });

  factory RCrewModel.fromJson(Map<String, dynamic> json) {
    return RCrewModel(
      crewId: json["crewId"],
      memberId: json["memberId"],
      name: json["name"],
      phoneNumber: json["phoneNumber"],
      profileImageUrl: json["profileImageUrl"],
      crewRole: json["crewRole"],
      joinStatus: json["joinStatus"],
      crewStatus: json["crewStatus"],
      createdAt: DateTime.parse(json["createdAt"]),
    );
  }
}