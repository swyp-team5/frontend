import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';

import '../../../../common/auth/server_token_manager.dart'; // 실제 경로에 맞게 수정

/// "받은 요청" 상세 화면에서 거절 버튼을 눌렀을 때 뜨는 확인 모달.
///
/// showModalBottomSheet(
///   backgroundColor: Colors.transparent,
///   isScrollControlled: true,
///   builder: (_) => RWorkChangeRejectBottomSheet(
///     workPlaceId: item.workPlaceId,
///     requestId: item.workChangeRequestId,
///     onSuccess: () => Navigator.of(context).pop("REJECTED"),
///   ),
/// )
/// 형태로 사용한다.
class RWorkChangeRejectBottomSheet extends StatefulWidget {
  final int workPlaceId;
  final int requestId;

  /// 거절 API 호출이 성공했을 때 호출된다. (모달은 이미 닫힌 상태)
  final VoidCallback onSuccess;

  const RWorkChangeRejectBottomSheet({
    super.key,
    required this.workPlaceId,
    required this.requestId,
    required this.onSuccess,
  });

  @override
  State<RWorkChangeRejectBottomSheet> createState() =>
      _RWorkChangeRejectBottomSheetState();
}

class _RWorkChangeRejectBottomSheetState
    extends State<RWorkChangeRejectBottomSheet> {
  static const _baseUrl = "https://chackchack.shop";
  final Dio _dio = Dio(BaseOptions(baseUrl: _baseUrl));

  bool _isSubmitting = false;

  // 서버가 내려주는 raw 메시지/코드 대신, 사용자가 이해하기 쉬운 문구로 바꿔서 보여준다.
  // (WorkChangeRequestService.rejectByOwner 기준)
  static String _errorMessage(int? statusCode, String? serverMessage) {
    switch (statusCode) {
      case 401:
        return "인증이 만료됐어요. 다시 로그인해주세요.";
      case 404:
        return "요청 또는 사업장 정보를 찾을 수 없어요. 새로고침 후 다시 시도해주세요.";
      case 409:
        return "이미 처리된 요청이라 거절할 수 없습니다. 새로고침 후 다시 확인해 주세요.";
      default:
        return "거절 처리에 실패했어요. 잠시 후 다시 시도해주세요.";
    }
  }

  /// POST /api/work-places/{workPlaceId}/owner/work-change-requests/{requestId}/reject
  Future<void> _reject() async {
    if (_isSubmitting) {
      debugPrint("[RejectBottomSheet] 이미 처리 중이라 무시함");
      return;
    }

    debugPrint(
      "[RejectBottomSheet] 거절 버튼 클릭됨: "
          "workPlaceId=${widget.workPlaceId}, requestId=${widget.requestId}",
    );

    setState(() => _isSubmitting = true);

    try {
      final token = await ServerTokenManager.getValidAccessToken();
      if (token == null) {
        debugPrint("[RejectBottomSheet] 거절 실패: 토큰 없음");
        throw Exception("인증이 필요합니다. 다시 로그인해주세요.");
      }
      debugPrint("[RejectBottomSheet] 토큰 확인 완료, API 호출 시도");

      final url =
          "/api/work-places/${widget.workPlaceId}/owner/work-change-requests/${widget.requestId}/reject";
      debugPrint("[RejectBottomSheet] POST 요청: $url");

      final response = await _dio.post(
        url,
        data: {}, // reason은 사용하지 않으므로 빈 JSON 객체만 전송
        options: Options(
          headers: {
            "Authorization": "Bearer $token",
            "Content-Type": "application/json",
          },
        ),
      );

      // 응답 형태: { "reason": "..." } 이지만 reason은 사용하지 않음
      debugPrint(
        "[RejectBottomSheet] reject 응답: "
            "status=${response.statusCode}, data=${response.data}",
      );

      final success =
          response.statusCode == 200 || response.statusCode == 204;

      debugPrint("[RejectBottomSheet] reject 결과: success=$success");

      if (!success) {
        throw Exception("거절 처리에 실패했어요. (${response.statusCode})");
      }

      debugPrint("[RejectBottomSheet] ✅ 거절 성공 → 모달 닫고 onSuccess 호출");

      if (!mounted) {
        debugPrint("[RejectBottomSheet] 위젯이 dispose됨, 처리 중단");
        return;
      }
      Navigator.of(context).pop(); // 모달 닫기
      widget.onSuccess();
    } on DioException catch (e) {
      debugPrint(
        "🔴 [RejectBottomSheet] reject DioException: "
            "status=${e.response?.statusCode}, data=${e.response?.data}, "
            "requestUri=${e.requestOptions.uri}",
      );

      if (!mounted) return;
      setState(() => _isSubmitting = false);

      final data = e.response?.data;
      final serverMessage = (data is Map) ? data["message"]?.toString() : null;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_errorMessage(e.response?.statusCode, serverMessage)),
        ),
      );
    } catch (e, st) {
      debugPrint("🔴 [RejectBottomSheet] reject 실패: $e");
      debugPrint("$st");

      if (!mounted) return;
      setState(() => _isSubmitting = false);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString().replaceFirst("Exception: ", ""))),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 드래그 핸들
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: const Color(0xFFDADADA),
                borderRadius: BorderRadius.circular(2),
              ),
            ),

            const SizedBox(height: 24),

            const Text(
              "요청을 거절하시겠습니까?",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 24),

            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0084FF),
                  disabledBackgroundColor:
                  const Color(0xFF0084FF).withOpacity(.6),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: _isSubmitting ? null : _reject,
                child: _isSubmitting
                    ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
                    : const Text(
                  "거절하기",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 12),

            TextButton(
              onPressed: _isSubmitting ? null : () => Navigator.of(context).pop(),
              child: const Text(
                "취소",
                style: TextStyle(
                  fontSize: 15,
                  color: Color(0xFF767676),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}