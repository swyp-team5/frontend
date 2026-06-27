import 'package:flutter/material.dart';

class DeleteWorkItem {
  final String role;
  final String startTime;
  final String endTime;
  final List<String> workers;

  DeleteWorkItem({
    required this.role,
    required this.startTime,
    required this.endTime,
    required this.workers,
  });
}

class RDeleteWorkingBottomSheet extends StatefulWidget {
  final List<DeleteWorkItem> works;
  final void Function(List<int>)? onDelete;

  const RDeleteWorkingBottomSheet({
    super.key,
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

  bool get canDelete => selectedIndexes.isNotEmpty;

  Color _roleColor(String role) {
    switch (role) {
      case "오픈":
        return const Color(0xFF0084FF);

      case "미들":
        return const Color(0xFF7D67FD);

      case "마감":
        return const Color(0xFF00B475);

      default:
        return Colors.black;
    }
  }

  void _toggleSelection(int index) {
    setState(() {
      if (selectedIndexes.contains(index)) {
        selectedIndexes.remove(index);
      } else {
        selectedIndexes.add(index);
      }
    });
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
      child: Column(
        children: [
          const SizedBox(height: 10),

          Container(
            width: 46,
            height: 5,
            decoration: BoxDecoration(
              color: Color(0xFFE2E2E2),
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
                  onTap: () => Navigator.pop(context),
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
          Divider(height: 1, color: Color(0xFFF1F1F5)),
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
                  onTap: () => _toggleSelection(index),
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
                onPressed: canDelete
                    ? () {
                  widget.onDelete?.call(
                    selectedIndexes.toList(),
                  );
                }
                    : null,
                style: ElevatedButton.styleFrom(
                  elevation: 0,
                  backgroundColor:
                  canDelete ? const Color(0xFF0084FF) : const Color(0xFFBFDDFC),
                  disabledBackgroundColor: const Color(0xFFBFDDFC),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: Text(
                  "삭제",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: canDelete
                        ? Colors.white
                        : const Color(0xFFE6F2FF),
                  ),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}