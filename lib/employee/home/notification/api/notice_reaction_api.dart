import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../../../../employer/home/notification/RNotificationModel.dart';

// 공지 공감 선택/변경/취소 API — WORKER 전용.
// 공지 조회/작성 API(NoticeApi)는 employer/home/notification/api/에 있지만,
// 공감은 서버가 WORKER 권한으로 강제하는 근무자 전용 기능이라 employee/ 밑에 따로 둔다.
class NoticeReactionApi {
  final Dio dio;

  NoticeReactionApi(this.dio);

  // 공감 선택/변경/취소 (토글)
  // - 공감 없음 + 새 타입 요청 -> 신규 생성
  // - 다른 타입 활성 + 새 타입 요청 -> 해당 타입으로 변경
  // - 같은 타입 활성 + 같은 타입 재요청 -> 취소 (myReactionType이 null로 옴)
  // 클라이언트는 "지금 뭐가 선택돼있는지" 따질 필요 없이 탭한 reactionType만 그대로 보내면 된다.
  /// PUT /api/notices/{noticeId}/reactions
  Future<NoticeReactionResult> selectReaction({
    required int noticeId,
    required String accessToken,
    required String reactionType,
  }) async {
    try {
      final response = await dio.put(
        "/api/notices/$noticeId/reactions",
        data: {"reactionType": reactionType},
        options: Options(
          headers: {"Authorization": "Bearer $accessToken"},
        ),
      );

      debugPrint("✅ [NoticeReactionApi] 공감 선택 성공 — 응답: ${response.data}");

      return NoticeReactionResult.fromJson(response.data);
    } on DioException catch (e) {
      debugPrint(
          "🔴 [NoticeReactionApi] 공감 선택 실패: ${e.response?.statusCode} / ${e.response?.data}");

      final message =
      e.response?.data is Map ? e.response?.data["message"] : null;
      throw Exception(message ?? "공감 선택 실패 (${e.response?.statusCode})");
    }
  }

  // 공감 취소 (명시적). 지금 화면엔 이걸 부를 트리거가 없어서(같은 이모지 재탭은 위 PUT으로
  // 처리됨) 실제 사용처는 아직 없지만, 명세서에 있는 엔드포인트라 구현은 해둔다.
  // 활성 공감이 없어도 실패하지 않고 현재 집계를 그대로 반환한다.
  /// DELETE /api/notices/{noticeId}/reactions
  Future<NoticeReactionResult> cancelReaction({
    required int noticeId,
    required String accessToken,
  }) async {
    try {
      final response = await dio.delete(
        "/api/notices/$noticeId/reactions",
        options: Options(
          headers: {"Authorization": "Bearer $accessToken"},
        ),
      );

      debugPrint("✅ [NoticeReactionApi] 공감 취소 성공 — 응답: ${response.data}");

      return NoticeReactionResult.fromJson(response.data);
    } on DioException catch (e) {
      debugPrint(
          "🔴 [NoticeReactionApi] 공감 취소 실패: ${e.response?.statusCode} / ${e.response?.data}");

      final message =
      e.response?.data is Map ? e.response?.data["message"] : null;
      throw Exception(message ?? "공감 취소 실패 (${e.response?.statusCode})");
    }
  }
}
