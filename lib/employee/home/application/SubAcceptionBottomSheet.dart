import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

import '../../../common/employee/ESubstitueAccept.dart';
import '../../../../common/auth/server_token_manager.dart';

class SubAcceptionBottomSheet extends StatefulWidget {
  final int workPlaceId;
  final int workChangeRequestId;
  final VoidCallback onAccept;

  const SubAcceptionBottomSheet({
    super.key,
    required this.workPlaceId,
    required this.workChangeRequestId,
    required this.onAccept,
  });

  @override
  State<SubAcceptionBottomSheet> createState() =>
      _SubAcceptionBottomSheetState();
}

class _SubAcceptionBottomSheetState extends State<SubAcceptionBottomSheet> {
  final Dio _dio = Dio(BaseOptions(baseUrl: "https://chackchack.shop"));

  // 수락 API 호출 중인지 여부 (버튼 중복 클릭 방지 및 로딩 표시용)
  bool _isLoading = false;

  /// POST /api/work-places/{workPlaceId}/work-change-requests/{requestId}/accept
  /// accept는 별도 요청 바디(reason 등)가 필요 없음.
  Future<bool> _acceptRequest() async {
    final url =
        "/api/work-places/${widget.workPlaceId}/work-change-requests/${widget.workChangeRequestId}/accept";
    debugPrint("[SubAcceptionBottomSheet] accept 요청 시작: $url");

    try {
      final token = await ServerTokenManager.getValidAccessToken();
      if (token == null) {
        debugPrint("[SubAcceptionBottomSheet] accept 실패: 토큰 없음");
        return false;
      }

      final response = await _dio.post(
        url,
        options: Options(
          headers: {"Authorization": "Bearer $token"},
        ),
      );

      debugPrint(
        "[SubAcceptionBottomSheet] accept 응답: "
            "status=${response.statusCode}, data=${response.data}",
      );

      final success =
          response.statusCode == 200 || response.statusCode == 204;
      debugPrint("[SubAcceptionBottomSheet] accept 결과: success=$success");
      return success;
    } on DioException catch (e) {
      debugPrint(
        "[SubAcceptionBottomSheet] accept DioException: "
            "status=${e.response?.statusCode}, data=${e.response?.data}, "
            "requestUri=${e.requestOptions.uri}",
      );
      return false;
    } catch (e, st) {
      debugPrint("[SubAcceptionBottomSheet] accept 실패(예상치 못한 예외): $e");
      debugPrint("$st");
      return false;
    }
  }

  Future<void> _handleAccept() async {
    if (_isLoading) return;

    debugPrint("[SubAcceptionBottomSheet] 수락하기 버튼 클릭됨");

    setState(() {
      _isLoading = true;
    });

    final success = await _acceptRequest();

    if (!mounted) return;

    setState(() {
      _isLoading = false;
    });

    if (success) {
      debugPrint("[SubAcceptionBottomSheet] 수락 성공 → ESubstituteAccept로 이동");
      widget.onAccept();

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => const ESubstituteAccept(),
        ),
      );
    } else {
      debugPrint("[SubAcceptionBottomSheet] 수락 실패 → 스낵바 표시");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("수락 처리에 실패했어요. 다시 시도해주세요.")),
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
                "수락 시 스케줄이 자동으로 변경돼요",
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