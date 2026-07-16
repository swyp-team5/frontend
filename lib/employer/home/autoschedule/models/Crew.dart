class CrewsResponse {
  final List<Crew> crews;

  CrewsResponse({required this.crews});

  factory CrewsResponse.fromJson(Map<String, dynamic> json) {
    return CrewsResponse(
      crews: (json['crews'] as List)
          .map((e) => Crew.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

class Crew {
  final int crewId;
  final int memberId;
  final String name;
  final String crewRole;

  Crew({
    required this.crewId,
    required this.memberId,
    required this.name,
    required this.crewRole,
  });

  factory Crew.fromJson(Map<String, dynamic> json) {
    return Crew(
      crewId: json['crewId'] as int,
      memberId: json['memberId'] as int,
      name: json['name'] as String,
      crewRole: json['crewRole'] as String? ?? "WORKER",
    );
  }
}