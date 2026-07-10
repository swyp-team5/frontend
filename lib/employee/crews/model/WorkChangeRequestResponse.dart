class WorkChangeRequestResponse {
  final int workChangeRequestId;
  final int workPlaceId;
  final String requestType;
  final String status;
  final int requesterMemberId;
  final int? targetMemberId;
  final int? requestAssignmentId;
  final int? targetAssignmentId;
  final String reason;
  final String? targetRespondedAt;
  final int? processedByMemberId;
  final String? processedAt;
  final String? canceledAt;
  final String createdAt;

  const WorkChangeRequestResponse({
    required this.workChangeRequestId,
    required this.workPlaceId,
    required this.requestType,
    required this.status,
    required this.requesterMemberId,
    this.targetMemberId,
    this.requestAssignmentId,
    this.targetAssignmentId,
    required this.reason,
    this.targetRespondedAt,
    this.processedByMemberId,
    this.processedAt,
    this.canceledAt,
    required this.createdAt,
  });

  factory WorkChangeRequestResponse.fromJson(Map<String, dynamic> json) {
    return WorkChangeRequestResponse(
      workChangeRequestId: json['workChangeRequestId'] as int,
      workPlaceId: json['workPlaceId'] as int,
      requestType: json['requestType'] as String,
      status: json['status'] as String,
      requesterMemberId: json['requesterMemberId'] as int,
      targetMemberId: json['targetMemberId'] as int?,
      requestAssignmentId: json['requestAssignmentId'] as int?,
      targetAssignmentId: json['targetAssignmentId'] as int?,
      reason: json['reason'] as String,
      targetRespondedAt: json['targetRespondedAt'] as String?,
      processedByMemberId: json['processedByMemberId'] as int?,
      processedAt: json['processedAt'] as String?,
      canceledAt: json['canceledAt'] as String?,
      createdAt: json['createdAt'] as String,
    );
  }
}