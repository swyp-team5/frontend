/// 공지 이미지의 "캐시버스팅 버전"을 앱 메모리에 보관하는 헬퍼.
///
/// 문제 상황:
/// - 서버가 같은 objectKey/URL 경로에 이미지를 덮어쓰는 구조라서
///   공지를 수정해도 imageUrl 문자열 자체는 바뀌지 않을 수 있다.
/// - Flutter의 Image 위젯은 NetworkImage의 URL이 이전과 완전히 같으면
///   (설령 ImageCache를 비워도) 새로 네트워크 요청을 하지 않고
///   기존 이미지 스트림을 그대로 유지한다.
/// - 따라서 "실제로 값이 바뀌는" 쿼리 파라미터를 URL 뒤에 붙여줘야만
///   Flutter가 새 이미지를 다시 받아온다.
///
/// 사용 흐름:
/// 1) RNotiEditPage에서 공지 수정(이미지 포함)이 성공하면
///    `NoticeImageCacheBuster.bump(noticeId)`를 호출해 현재 시각을 기록한다.
/// 2) RNotificationPage(목록)에서 이미지를 그릴 때
///    `NoticeImageCacheBuster.versionFor(noticeId)` 값을 URL 쿼리에 붙인다.
///    한 번이라도 bump된 적이 있으면 그 값을, 없으면 null을 반환하므로
///    호출부에서 기존 방식(noticeId_date)으로 폴백하면 된다.
class NoticeImageCacheBuster {
  NoticeImageCacheBuster._();

  static final Map<int, int> _versions = {};

  /// 공지 수정(이미지 변경 포함)이 성공했을 때 호출.
  /// 현재 시각(ms)을 새 버전 값으로 기록한다.
  static void bump(int noticeId) {
    _versions[noticeId] = DateTime.now().millisecondsSinceEpoch;
  }

  /// 해당 noticeId에 기록된 버전 값. 없으면 null.
  static int? versionFor(int noticeId) => _versions[noticeId];
}