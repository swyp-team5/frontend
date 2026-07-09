class FcmTokenResponse {
  final int fcmTokenId;
  final String deviceId;
  final String platform;
  final String appVersion;
  final String status;
  final String lastRegisteredAt;

  FcmTokenResponse({
    required this.fcmTokenId,
    required this.deviceId,
    required this.platform,
    required this.appVersion,
    required this.status,
    required this.lastRegisteredAt,
  });

  factory FcmTokenResponse.fromJson(Map<String, dynamic> json) {
    return FcmTokenResponse(
      fcmTokenId: json['fcmTokenId'] ?? 0,
      deviceId: json['deviceId'] ?? '',
      platform: json['platform'] ?? '',
      appVersion: json['appVersion'] ?? '',
      status: json['status'] ?? '',
      lastRegisteredAt: json['lastRegisteredAt'] ?? '',
    );
  }
}