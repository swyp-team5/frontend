import 'package:flutter/material.dart';
import '../api/DayTimeDetailsApi.dart';
import '../models/DayTimeDetails.dart';

class ESubmitScheduleBottomSheet extends StatefulWidget {
  final int workPlaceId;
  final int weekScheduleId;
  final DateTime date;

  const ESubmitScheduleBottomSheet({
    super.key,
    required this.workPlaceId,
    required this.weekScheduleId,
    required this.date,
  });

  @override
  State<ESubmitScheduleBottomSheet> createState() =>
      _ESubmitScheduleBottomSheetState();
}

class _ESubmitScheduleBottomSheetState
    extends State<ESubmitScheduleBottomSheet> {
  final Set<int> selectedIds = {};

  List<DayTimeDetail> _timeDetails = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadTimeDetails();
  }

  Future<void> _loadTimeDetails() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final res = await DayTimeDetailsApi.getDayTimeDetails(
        workPlaceId: widget.workPlaceId,
        weekScheduleId: widget.weekScheduleId,
        date: widget.date,
      );

      setState(() {
        _timeDetails = res.timeDetails;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = _stripExceptionPrefix(e.toString());
        _isLoading = false;
      });
    }
  }

  /// 원본 예외 문자열 맨 앞의 "Exception: " / "Error: " 접두어만 제거한다.
  /// (원본 메시지 자체는 그대로 유지하고 접두어만 감춘다)
  String _stripExceptionPrefix(String raw) {
    return raw.replaceFirst(RegExp(r'^(Exception|Error):\s*'), '');
  }

  void _select(int timeDetailId) {
    setState(() {
      if (selectedIds.contains(timeDetailId)) {
        selectedIds.remove(timeDetailId);
      } else {
        selectedIds.add(timeDetailId);
      }
    });
  }

  void _submit() {
    if (selectedIds.isEmpty) return;

    final selected =
    _timeDetails.where((d) => selectedIds.contains(d.timeDetailId)).toList();

    Navigator.pop(context, {
      "date": widget.date,
      "timeDetailIds": selected.map((d) => d.timeDetailId).toList(),
      "types": selected.map((d) => d.timeName).toList(),
      "timeRange": selected.map((d) => d.displayTime).join(", "),
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 44,
              height: 4,
              decoration: BoxDecoration(
                color: const Color(0xFFE6E6E6),
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            const SizedBox(height: 18),
            const Text(
              "스케줄 시간 선택",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 6),
            const Text(
              "불가능한 근무 시간을 선택해주세요 (중복 선택 가능)",
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Color(0xFF767676),
              ),
            ),
            const SizedBox(height: 10),
            const Divider(height: 10, color: Color(0xFFF1F1F5)),
            const SizedBox(height: 10),

            if (_isLoading)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 40),
                child: Center(child: CircularProgressIndicator()),
              )
            else if (_error != null)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 24),
                child: Column(
                  children: [
                    Text(_error!, style: const TextStyle(color: Colors.red)),
                    const SizedBox(height: 12),
                    ElevatedButton(
                      onPressed: _loadTimeDetails,
                      child: const Text("다시 시도"),
                    ),
                  ],
                ),
              )
            else if (_timeDetails.isEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 24),
                  child: Text(
                    "해당 날짜에 설정된 근무 시간이 없어요",
                    style: TextStyle(color: Color(0xFF767676)),
                  ),
                )
              else
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _timeDetails.length,
                  gridDelegate:
                  const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 10,
                    crossAxisSpacing: 15,
                    childAspectRatio: 2,
                  ),
                  itemBuilder: (context, index) {
                    final detail = _timeDetails[index];
                    final isSelected =
                    selectedIds.contains(detail.timeDetailId);

                    return GestureDetector(
                      onTap: () => _select(detail.timeDetailId),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 12),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? const Color(0xFFE6F3FF)
                              : const Color(0xFFF1F1F5),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isSelected
                                ? const Color(0xFF0084FF)
                                : Colors.transparent,
                            width: 1.5,
                          ),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    detail.timeName,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    detail.displayTime,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                      color: Color(0xFF767676),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 10),
                            if (isSelected)
                              Container(
                                width: 22,
                                height: 22,
                                decoration: const BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Color(0xFF0084FF),
                                ),
                                child: const Icon(
                                  Icons.check,
                                  size: 14,
                                  color: Colors.white,
                                ),
                              ),
                          ],
                        ),
                      ),
                    );
                  },
                ),

            const SizedBox(height: 18),

            SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton(
                onPressed: selectedIds.isEmpty ? null : _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0084FF),
                  disabledBackgroundColor: const Color(0xFFA9D0FB),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  "저장",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}