// 회원가입 약관 조회(GET /api/terms/signup) 응답의 약관 1건.
// - 기존 signup_request.dart의 TermsAgreement(termsId + agreed만 있는 제출용 모델)와는 다른,
//   화면 표시용 모델이다. 제출할 땐 이 리스트를 TermsAgreement 리스트로 변환해서 보낸다.
class TermsItem {
  final int termsId;
  final String termsType; // COMMON / OWNER / WORKER
  final String title;
  final bool isRequired;
  final String version;
  // null이면 상세 본문이 없는 약관(예: "만 14세 이상입니다")이라, 화면에서 상세보기를 비활성화한다.
  final String? content;

  // 서버 응답엔 없고, 화면에서 체크 상태를 들고 있기 위한 로컬 상태.
  bool agreed;

  TermsItem({
    required this.termsId,
    required this.termsType,
    required this.title,
    required this.isRequired,
    required this.version,
    required this.content,
    this.agreed = false,
  });

  factory TermsItem.fromJson(Map<String, dynamic> json) {
    return TermsItem(
      termsId: json['termsId'] ?? 0,
      termsType: json['termsType'] ?? '',
      title: json['title'] ?? '',
      isRequired: json['required'] ?? false,
      version: json['version'] ?? '',
      content: json['content'],
    );
  }
}
