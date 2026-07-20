import 'package:flutter/material.dart';

import '../api/AssignmentApi.dart';

class DeleteWorkItem {
  final String role;
  final String startTime;
  final String endTime;
  final List<String> workers;

  /// 삭제 API 호출에 필요한 timeDetailId
  final int timeDetailId;

  DeleteWorkItem({
    required this.role,
    required this.startTime,
    required this.endTime,
    required this.workers,
    required this.timeDetailId,
  });
}

class RDeleteWorkingBottomSheet extends StatefulWidget {
  final int workPlaceId;
  final int confirmedWeekScheduleId;
  final List<DeleteWorkItem> works;

  /// 삭제 성공 시 실제로 삭제된 index 리스트를 전달합니다.
  final void Function(List<int>)? onDelete;

  const RDeleteWorkingBottomSheet({
    super.key,
    required this.workPlaceId,
    required this.confirmedWeekScheduleId,
    required this.works,
    this.onDelete,
  });

  @override
  State<RDeleteWorkingBottomSheet> createState() =>
      _RDeleteWorkingBottomSheetState();
}

class _RDeleteWorkingBottomSheetState
    extends State<RDeleteWorkingBottomSheet> {
  final Set<int> selectedIndexes = {};
  bool isDeleting = false;

  /// 상단 에러 배너에 표시할 메시지. null이면 배너를 숨긴다.
  String? errorMessage;

  bool get canDelete => selectedIndexes.isNotEmpty && !isDeleting;

  /// timeName(role)마다 색을 동적으로 배정하기 위한 팔레트.
  /// role이 "오픈/미들/마감"으로 고정되어 있지 않고 매장마다 자유롭게
  /// 지정되므로, 처음 등장하는 순서대로 색을 순환 배정한다.
  static const List<Color> _roleColors = [
    Color(0xFF0084FF),
    Color(0xFF7D67FD),
    Color(0xFF00B475),
    Color(0xFFC77700),
    Color(0xFFC03A54),
    Color(0xFF00877D),
  ];

  /// role -> 색상 인덱스 캐시 (static이라 위젯이 새로 생성돼도 유지됨)
  static final Map<String, int> _roleColorMap = {};
  static int _nextColorIndex = 0;

  static int _colorIndexForRole(String role) {
    if (_roleColorMap.containsKey(role)) {
      return _roleColorMap[role]!;
    }

    final assigned = _nextColorIndex % _roleColors.length;
    _roleColorMap[role] = assigned;
    _nextColorIndex++;

    return assigned;
  }

  Color _roleColor(String role) =>
      _roleColors[_colorIndexForRole(role)];

  void _toggleSelection(int index) {
    setState(() {
      if (selectedIndexes.contains(index)) {
        selectedIndexes.remove(index);
      } else {
        selectedIndexes.add(index);
      }
    });
  }

  void _showErrorBanner(String message) {
    setState(() => errorMessage = message);

    // 4초 뒤 자동으로 배너를 숨긴다.
    Future.delayed(const Duration(seconds: 4), () {
      if (mounted && errorMessage == message) {
        setState(() => errorMessage = null);
      }
    });
  }

  Future<void> _deleteSelected() async {
    if (selectedIndexes.isEmpty || isDeleting) return;

    setState(() {
      isDeleting = true;
      errorMessage = null;
    });

    final targetIndexes = selectedIndexes.toList();
    final deletedIndexes = <int>[];
    String? failureMessage;

    for (final index in targetIndexes) {
      try {
        final timeDetailId = widget.works[index].timeDetailId;

        final result = await AssignmentApi.delete(
          workPlaceId: widget.workPlaceId,
          confirmedWeekScheduleId: widget.confirmedWeekScheduleId,
          timeDetailId: timeDetailId,
        );

        if (result.status == 'DELETED') {
          deletedIndexes.add(index);
        }
      } catch (e) {
        // 하나가 실패해도 그 이전까지 성공한 삭제는 유지하고,
        // 나머지 선택 항목은 계속 시도한다. 에러 메시지는 마지막 것을 보여준다.
        failureMessage = e.toString().replaceFirst('Exception: ', '');
      }
    }

    if (!mounted) return;

    // 하나라도 성공적으로 삭제됐다면, 실패가 섞여 있어도 부모에 반영한다.
    if (deletedIndexes.isNotEmpty) {
      widget.onDelete?.call(deletedIndexes);
    }

    if (failureMessage != null) {
      setState(() => isDeleting = false);
      _showErrorBanner(failureMessage);

      // 성공한 항목이 있다면 선택 상태에서는 제거해준다.
      if (deletedIndexes.isNotEmpty) {
        setState(() {
          selectedIndexes.removeWhere((i) => deletedIndexes.contains(i));
        });
      }
      return;
    }

    // 전부 성공한 경우에만 바텀시트를 닫는다.
    Navigator.pop(context, deletedIndexes);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 550,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(28),
        ),
      ),
      child: Stack(
        children: [
          Column(
            children: [
              const SizedBox(height: 10),

              Container(
                width: 46,
                height: 5,
                decoration: BoxDecoration(
                  color: const Color(0xFFE2E2E2),
                  borderRadius: BorderRadius.circular(999),
                ),
              ),

              const SizedBox(height: 24),

              Stack(
                children: [
                  const Center(
                    child: Text(
                      "삭제하시겠습니까?",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  Positioned(
                    right: 24,
                    child: GestureDetector(
                      onTap: isDeleting ? null : () => Navigator.pop(context),
                      child: Container(
                        width: 32,
                        height: 32,
                        decoration: const BoxDecoration(
                          color: Color(0xFFF2F2F7),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.close,
                          color: Color(0xFFA6A6A6),
                        ),
                      ),
                    ),
                  )
                ],
              ),

              const SizedBox(height: 8),

              const Text(
                "삭제하실 근무 타입을 선택해주세요 (복수선택 가능)",
                style: TextStyle(
                  color: Color(0xFF767676),
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),

              const SizedBox(height: 20),
              const Divider(height: 1, color: Color(0xFFF1F1F5)),
              const SizedBox(height: 20),

              Expanded(
                child: ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  itemCount: widget.works.length,
                  separatorBuilder: (_, __) =>
                  const SizedBox(height: 14),
                  itemBuilder: (_, index) {
                    final work = widget.works[index];

                    final selected =
                    selectedIndexes.contains(index);

                    return GestureDetector(
                      onTap: isDeleting ? null : () => _toggleSelection(index),
                      child: AnimatedContainer(
                        duration:
                        const Duration(milliseconds: 200),
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(
                          color: selected
                              ? const Color(0xFFEAF4FF)
                              : const Color(0xFFF5F5F7),
                          borderRadius:
                          BorderRadius.circular(18),
                          border: Border.all(
                            color: selected
                                ? const Color(0xFF0084FF)
                                : Colors.transparent,
                            width: 2,
                          ),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment:
                                CrossAxisAlignment.start,
                                children: [
                                  RichText(
                                    text: TextSpan(
                                      children: [
                                        TextSpan(
                                          text: work.role,
                                          style: TextStyle(
                                            color: _roleColor(work.role),
                                            fontWeight: FontWeight.w500,
                                            fontSize: 16,
                                          ),
                                        ),
                                        TextSpan(
                                          text:
                                          " ${work.startTime} - ${work.endTime}",
                                          style: const TextStyle(
                                            color: Colors.black,
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    work.workers.join(", "),
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                      color: Color(0xFF767676),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            if (selected)
                              const Icon(
                                Icons.check_circle,
                                color: Color(0xFF0084FF),
                              )
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),

              Padding(
                padding: const EdgeInsets.fromLTRB(
                    20, 20, 20, 30),
                child: SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: canDelete ? _deleteSelected : null,
                    style: ElevatedButton.styleFrom(
                      elevation: 0,
                      backgroundColor:
                      canDelete ? const Color(0xFF0084FF) : const Color(0xFFBFDDFC),
                      disabledBackgroundColor: const Color(0xFFBFDDFC),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: isDeleting
                        ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        color: Colors.white,
                      ),
                    )
                        : Text(
                      "삭제",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: selectedIndexes.isNotEmpty
                            ? Colors.white
                            : const Color(0xFFE6F2FF),
                      ),
                    ),
                  ),
                ),
              )
            ],
          ),

          // ===== 상단 에러 배너 =====
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 250),
              transitionBuilder: (child, animation) => SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0, -1),
                  end: Offset.zero,
                ).animate(animation),
                child: child,
              ),
              child: errorMessage == null
                  ? const SizedBox.shrink(key: ValueKey('empty'))
                  : SafeArea(
                key: ValueKey(errorMessage),
                bottom: false,
                child: Container(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFEBEE),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: const Color(0xFFFF5252),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.error_outline,
                        color: Color(0xFFD32F2F),
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          errorMessage!,
                          style: const TextStyle(
                            color: Color(0xFFD32F2F),
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: () => setState(() => errorMessage = null),
                        child: const Icon(
                          Icons.close,
                          color: Color(0xFFD32F2F),
                          size: 18,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}