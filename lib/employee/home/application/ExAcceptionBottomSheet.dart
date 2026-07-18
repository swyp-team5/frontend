import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

import '../../../common/employee/EExchangeAccept.dart';
import '../../../../common/auth/server_token_manager.dart';

class ExAcceptionBottomSheet extends StatefulWidget {
  final int workPlaceId;
  final int workChangeRequestId;
  final VoidCallback onAccept;

  const ExAcceptionBottomSheet({
    super.key,
    required this.workPlaceId,
    required this.workChangeRequestId,
    required this.onAccept,
  });

  @override
  State<ExAcceptionBottomSheet> createState() =>
      _ExAcceptionBottomSheetState();
}

class _ExAcceptionBottomSheetState extends State<ExAcceptionBottomSheet> {
  final Dio _dio = Dio(BaseOptions(baseUrl: "https://chackchack.shop"));

  // 수락 API 호출 중인지 여부 (버튼 중복 클릭 방지 및 로딩 표시용)
  bool _isLoading = false;

  /// POST /api/work-places/{workPlaceId}/work-change-requests/{requestId}/accept
  /// accept는 별도 요청 바디(reason 등)가 필요 없음.
  /// 성공하면 null, 실패하면 사용자에게 보여줄 에러 메시지를 반환한다.
  Future<String?> _acceptRequest() async {
    final url =
        "/api/work-places/${widget.workPlaceId}/work-change-requests/${widget.workChangeRequestId}/accept";
    debugPrint("[ExAcceptionBottomSheet] accept 요청 시작: $url");

    try {
      final token = await ServerTokenManager.getValidAccessToken();
      if (token == null) {
        debugPrint("[ExAcceptionBottomSheet] accept 실패: 토큰 없음");
        return "인증이 만료되었습니다. 다시 로그인해 주세요.";
      }

      final response = await _dio.post(
        url,
        options: Options(
          headers: {"Authorization": "Bearer $token"},
        ),
      );

      debugPrint(
        "[ExAcceptionBottomSheet] accept 응답: "
            "status=${response.statusCode}, data=${response.data}",
      );

      final success =
          response.statusCode == 200 || response.statusCode == 204;
      debugPrint("[ExAcceptionBottomSheet] accept 결과: success=$success");

      return success ? null : _errorMessage(response.statusCode, null);
    } on DioException catch (e) {
      debugPrint(
        "[ExAcceptionBottomSheet] accept DioException: "
            "status=${e.response?.statusCode}, data=${e.response?.data}, "
            "requestUri=${e.requestOptions.uri}",
      );

      final data = e.response?.data;
      final serverMessage = (data is Map) ? data["message"]?.toString() : null;
      return _errorMessage(e.response?.statusCode, serverMessage);
    } catch (e, st) {
      debugPrint("[ExAcceptionBottomSheet] accept 실패(예상치 못한 예외): $e");
      debugPrint("$st");
      return "수락 처리에 실패했어요. 잠시 후 다시 시도해주세요.";
    }
  }

  // 서버가 내려주는 raw 메시지/코드 대신, 사용자가 이해하기 쉬운 문구로 바꿔서 보여준다.
  // (WorkChangeRequestService.acceptByTarget 기준)
  static String _errorMessage(int? statusCode, String? serverMessage) {
    switch (statusCode) {
      case 401:
        return "인증이 만료되었습니다. 다시 로그인해 주세요.";
      case 403:
        return "이 요청을 처리할 권한이 없습니다.";
      case 404:
        return "요청 정보를 찾을 수 없습니다. 새로고침 후 다시 시도해주세요.";
      case 409:
        return "이미 처리된 요청이라 수락할 수 없습니다. 새로고침 후 다시 확인해주세요.";
      default:
        return "수락 처리에 실패했어요. 잠시 후 다시 시도해주세요.";
    }
  }

  Future<void> _handleAccept() async {
    if (_isLoading) return;

    debugPrint("[ExAcceptionBottomSheet] 수락하기 버튼 클릭됨");

    setState(() {
      _isLoading = true;
    });

    final errorMessage = await _acceptRequest();

    if (!mounted) return;

    setState(() {
      _isLoading = false;
    });

    if (errorMessage == null) {
      debugPrint("[ExAcceptionBottomSheet] 수락 성공 → EExchangeAccept로 이동");
      widget.onAccept();

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => const EExchangeAccept(),
        ),
      );
    } else {
      debugPrint("[ExAcceptionBottomSheet] 수락 실패 → 스낵바 표시: $errorMessage");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(errorMessage)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(28),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 12, 24, 28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [

              /// 상단 손잡이
              Container(
                width: 56,
                height: 6,
                decoration: BoxDecoration(
                  color: const Color(0xffD9D9D9),
                  borderRadius: BorderRadius.circular(100),
                ),
              ),

              const SizedBox(height: 34),

              const Text(
                "수락하시겠습니까?",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),

              const SizedBox(height: 16),

              const Text(
                "수락 시 사장님께 근무 변경 요청이\n자동으로 전송돼요",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Color(0xff767676),
                  height: 1.5,
                ),
              ),

              const SizedBox(height: 40),

              SizedBox(
                width: double.infinity,
                height: 58,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    elevation: 0,
                    backgroundColor: const Color(0xff0084FF),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onPressed: _isLoading ? null : _handleAccept,
                  child: _isLoading
                      ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                      : const Text(
                    "수락하기",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 18),

              TextButton(
                onPressed: _isLoading
                    ? null
                    : () {
                  Navigator.pop(context);
                },
                child: const Text(
                  "취소",
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}