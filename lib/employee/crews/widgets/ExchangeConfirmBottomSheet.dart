import 'package:flutter/material.dart';

import '../../../common/employee/EExchangeApplicationComplete.dart';
import '../api/WorkChangeRequestApi.dart';
import '../model/WorkChangeRequestResponse.dart';

class ExchangeConfirmBottomSheet extends StatefulWidget {
  const ExchangeConfirmBottomSheet({
    super.key,
    required this.workPlaceId,
    required this.requestAssignmentId,
    required this.targetAssignmentId,
    required this.myName,
    required this.workerName,
    required this.myDate,
    required this.workerDate,
    required this.myTime,
    required this.workerTime,
    required this.reason,
    required this.onConfirm,
  });

  final int workPlaceId;
  final int requestAssignmentId;
  final int targetAssignmentId;

  final String myName;
  final String workerName;

  final String myDate;
  final String workerDate;

  final String myTime;
  final String workerTime;

  final String reason;

  final ValueChanged<WorkChangeRequestResponse> onConfirm;

  @override
  State<ExchangeConfirmBottomSheet> createState() =>
      _ExchangeConfirmBottomSheetState();
}

class _ExchangeConfirmBottomSheetState
    extends State<ExchangeConfirmBottomSheet> {
  bool _isLoading = false;
  final WorkChangeRequestApi _api = WorkChangeRequestApi();

  Future<void> _handleConfirm() async {
    if (_isLoading) return;

    setState(() => _isLoading = true);

    debugPrint(
      "[ExchangeConfirm] 교대 신청 요청 시작 - "
          "workPlaceId: ${widget.workPlaceId}, "
          "requestAssignmentId: ${widget.requestAssignmentId}, "
          "targetAssignmentId: ${widget.targetAssignmentId}, "
          "reason: ${widget.reason}",
    );

    try {
      final response = await _api.requestShiftSwap(
        workPlaceId: widget.workPlaceId,
        requestAssignmentId: widget.requestAssignmentId,
        targetAssignmentId: widget.targetAssignmentId,
        reason: widget.reason,
      );

      debugPrint("[ExchangeConfirm] 교대 신청 성공 ✅ response: $response");

      if (!mounted) return;

      widget.onConfirm(response);

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => const EExchangeApplicationComplete(),
        ),
      );
    } catch (e, stackTrace) {
      debugPrint("[ExchangeConfirm] 교대 신청 실패 ❌ error: $e");
      debugPrint("[ExchangeConfirm] stackTrace: $stackTrace");

      if (!mounted) return;
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('$e'.replaceFirst('Exception: ', ''))),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(28),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 48,
              height: 6,
              decoration: BoxDecoration(
                color: const Color(0xffD9D9D9),
                borderRadius: BorderRadius.circular(100),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              "이대로 신청하시겠습니까?",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            const Text(
              "한 번 전송된 신청서는 이후 수정이 불가능해요",
              style: TextStyle(
                color: Color(0xff767676),
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 10),
            const Divider(height: 1, color: Color(0xFFF1F1F5)),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xffF5F5F9),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xffE6F3FF),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                widget.myName,
                                style: const TextStyle(
                                  color: Color(0xff0063BF),
                                  fontWeight: FontWeight.w500,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              widget.myDate,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              widget.myTime,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: Color(0xFF505050),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16),
                        child: Icon(
                          Icons.swap_horiz,
                          size: 34,
                          color: Color(0xff8F8F8F),
                        ),
                      ),
                      Expanded(
                        child: Column(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xffCDFFD4),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                widget.workerName,
                                style: const TextStyle(
                                  color: Color(0xff019A4E),
                                  fontWeight: FontWeight.w500,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              widget.workerDate,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              widget.workerTime,
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w500,
                                color: Color(0xFF505050),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 22),
                  const Divider(),
                  const SizedBox(height: 18),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      children: [
                        const Text(
                          "교대 사유",
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: Color(0xff767676),
                          ),
                        ),
                        Expanded(
                          child: Text(
                            widget.reason,
                            textAlign: TextAlign.end,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 26),
            Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 56,
                    child: OutlinedButton(
                      onPressed:
                      _isLoading ? null : () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(side: BorderSide.none),
                      child: const Text(
                        "취소",
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 1,
                  child: SizedBox(
                    height: 56,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _handleConfirm,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xff0084FF),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: _isLoading
                          ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          valueColor:
                          AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                          : const Text(
                        "확정",
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}