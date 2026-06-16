class EmployeeCrewModel {
  final String name;
  final String role;
  final bool isMe;

  EmployeeCrewModel({
    required this.name,
    required this.role,
    this.isMe = false,
  });
}