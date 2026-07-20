import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';

import '../../../../common/auth/server_token_manager.dart'; // 실제 경로에 맞게 수정

/// "받은 요청" 상세 화면에서 수락 버튼을 눌렀을 때 뜨는 확인 모달.
///
/// showModalBottomSheet(
///   backgroundColor: Colors.transparent,
///   isScrollControlled: true,
///   builder: (_) => RWorkChangeAcceptBottomSheet(
///     workPlaceId: item.workPlaceId,
///     requestId: item.workChangeRequestId,
///     onSuccess: () => Navigator.of(context).pop("APPROVED"),
///   ),
/// )
/// 형태로 사용한다.
class RWorkChangeAcceptBottomSheet extends StatefulWidget {
  final int workPlaceId;
  final int requestId;

  /// 승인 API 호출이 성공했을 때 호출된다. (모달은 이미 닫힌 상태)
  final VoidCallback onSuccess;

  const RWorkChangeAcceptBottomSheet({
    super.key,
    required this.workPlaceId,
    required this.requestId,
    required this.onSuccess,
  });

  @override
  State<RWorkChangeAcceptBottomSheet> createState() =>
      _RWorkChangeAcceptBottomSheetState();
}

class _RWorkChangeAcceptBottomSheetState
    extends State<RWorkChangeAcceptBottomSheet> {
  final Dio _dio = ServerTokenManager.authorizedDio;

  bool _isSubmitting = false;

  // 서버가 내려주는 raw 메시지/코드 대신, 사용자가 이해하기 쉬운 문구로 바꿔서 보여준다.
  static String _errorMessage(int? statusCode, String? serverMessage) {
    final msg = serverMessage ?? "";

    switch (statusCode) {
      case 400:
        if (msg.contains("이미 지난 근무는 교대/대타를 요청할 수 없습니다.")) {
          return "이미 지난 근무여서 승인할 수 없습니다.";
        }
        return "요청 내용을 다시 확인해 주세요.";
      case 401:
        return "로그인이 만료됐어요. 다시 로그인해주세요.";
      case 403:
        return "근무 배정 정보가 변경되어 승인할 수 없습니다.";
      case 404:
        return "요청 또는 사업장 정보를 찾을 수 없어요. 새로고침 후 다시 시도해주세요.";
      case 409:
        if (msg.contains("대상 근무자가 수락한 요청만 승인할 수 있습니다.")) {
          return "이미 처리된 요청이에요. 새로고침 후 다시 확인해 주세요.";
        }
        if (msg.contains("확정 근무 배정 상태가 변경되어 요청을 처리할 수 없습니다.") ||
            msg.contains("대상 근무자가 해당 시간에 이미 근무 중입니다.")) {
          return "이미 같은 시간대에 다른 요청이 먼저 승인되어 "
              "이 요청은 처리할 수 없습니다.";
        }
        return "다른 요청과 상태가 충돌해 처리할 수 없어요.";
      default:
        return "승인 처리에 실패했어요. 잠시 후 다시 시도해주세요.";
    }
  }

  /// POST /api/work-places/{workPlaceId}/owner/work-change-requests/{requestId}/approve
  Future<void> _approve() async {
    if (_isSubmitting) {
      debugPrint("[AcceptBottomSheet] 이미 처리 중이라 무시함");
      return;
    }

    debugPrint(
      "[AcceptBottomSheet] 승인 버튼 클릭됨: "
          "workPlaceId=${widget.workPlaceId}, requestId=${widget.requestId}",
    );

    setState(() => _isSubmitting = true);

    try {
      final token = await ServerTokenManager.getValidAccessToken();
      if (token == null) {
        debugPrint("[AcceptBottomSheet] 승인 실패: 토큰 없음");
        throw Exception("인증이 필요합니다. 다시 로그인해주세요.");
      }
      debugPrint("[AcceptBottomSheet] 토큰 확인 완료, API 호출 시도");

      final url =
          "/api/work-places/${widget.workPlaceId}/owner/work-change-requests/${widget.requestId}/approve";
      debugPrint("[AcceptBottomSheet] POST 요청: $url");

      final response = await _dio.post(
        url,
        options: Options(headers: {"Authorization": "Bearer $token"}),
      );

      debugPrint(
        "[AcceptBottomSheet] approve 응답: "
            "status=${response.statusCode}, data=${response.data}",
      );

      final success =
          response.statusCode == 200 || response.statusCode == 204;

      debugPrint("[AcceptBottomSheet] approve 결과: success=$success");

      if (!success) {
        throw Exception("승인 처리에 실패했어요. (${response.statusCode})");
      }

      debugPrint("[AcceptBottomSheet] ✅ 승인 성공 → 모달 닫고 onSuccess 호출");

      if (!mounted) {
        debugPrint("[AcceptBottomSheet] 위젯이 dispose됨, 처리 중단");
        return;
      }
      Navigator.of(context).pop(); // 모달 닫기
      widget.onSuccess();
    } on DioException catch (e) {
      debugPrint(
        "🔴 [AcceptBottomSheet] approve DioException: "
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
      debugPrint("🔴 [AcceptBottomSheet] approve 실패: $e");
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
              "요청을 수락하시겠습니까?",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 8),

            const Text(
              "사장님에게 근무 변경 수락 요청이 전송돼요",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Color(0xFF767676),
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
                onPressed: _isSubmitting ? null : _approve,
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
                  "수락하기",
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
