class ECrewModel {
  final int crewId;
  final int memberId;

  final String name;
  final String phoneNumber;
  final String? profileImageUrl;

  final String crewRole;
  final String joinStatus;
  final String crewStatus;

  final DateTime? createdAt;

  ECrewModel({
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

  factory ECrewModel.fromJson(Map<String, dynamic> json) {
    return ECrewModel(
      crewId: json["crewId"] is int
          ? json["crewId"]
          : int.tryParse(json["crewId"]?.toString() ?? "") ?? 0,
      memberId: json["memberId"] is int
          ? json["memberId"]
          : int.tryParse(json["memberId"]?.toString() ?? "") ?? 0,
      name: json["name"]?.toString() ?? "이름 없음",
      phoneNumber: json["phoneNumber"]?.toString() ?? "",
      profileImageUrl: json["profileImageUrl"]?.toString(),
      crewRole: json["crewRole"]?.toString() ?? "",
      joinStatus: json["joinStatus"]?.toString() ?? "",
      crewStatus: json["crewStatus"]?.toString() ?? "",
      createdAt: json["createdAt"] != null
          ? DateTime.tryParse(json["createdAt"].toString())
          : null,
    );
  }
}