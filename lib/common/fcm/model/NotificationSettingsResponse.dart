// 회원 알림(FCM 푸시) 수신 설정 응답 모델
// - fcmPushEnabled: 실제 "기기로" FCM 푸시를 보낼지 여부.
//   false여도 앱 내부 알림함 데이터는 항상 저장되며, 이 값은 기기 푸시 발송 여부만 제어한다.
// - 서버에 설정 row가 없을 때 응답 자체가 없을 가능성을 대비해 기본값은 true로 파싱한다
//   (명세서: "설정 row가 없으면 조회 시 기본값 true로 생성한다").
class NotificationSettingsResponse {
  final bool fcmPushEnabled;

  NotificationSettingsResponse({
    required this.fcmPushEnabled,
  });

  factory NotificationSettingsResponse.fromJson(Map<String, dynamic> json) {
    return NotificationSettingsResponse(
      fcmPushEnabled: json['fcmPushEnabled'] ?? true,
    );
  }
}