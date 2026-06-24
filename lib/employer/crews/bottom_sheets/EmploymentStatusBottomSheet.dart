import 'package:flutter/material.dart';

class EmploymentStatusBottomSheet extends StatefulWidget {
  final String? initialStatus;
  final ValueChanged<String> onSave;

  const EmploymentStatusBottomSheet({
    super.key,
    this.initialStatus,
    required this.onSave,
  });

  @override
  State<EmploymentStatusBottomSheet> createState() =>
      _EmploymentStatusBottomSheetState();
}

class _EmploymentStatusBottomSheetState
    extends State<EmploymentStatusBottomSheet> {
  String? selectedStatus;

  @override
  void initState() {
    super.initState();

    // 처음에는 아무것도 선택하지 않음
    selectedStatus = null;
  }

  Widget _buildStatusButton(String status) {
    final bool selected = selectedStatus == status;

    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            selectedStatus = status;
          });
        },
        child: Container(
          height: 60,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: selected
                ? const Color(0xFFE6F3FF)
                : const Color(0xFFF1F1F5),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: selected
                  ? const Color(0xFF0084FF)
                  : Colors.transparent,
              width: 1.5,
            ),
          ),
          child: Row(
            children: [
              Text(
                status,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight:
                  selected ? FontWeight.w700 : FontWeight.w400,
                  color: const Color(0xFF202020),
                ),
              ),

              const Spacer(),

              if (selected)
                Container(
                  width: 24,
                  height: 24,
                  decoration: const BoxDecoration(
                    color: Color(0xFF0084FF),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check,
                    size: 16,
                    color: Colors.white,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool canSave = selectedStatus != null;

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
            // 핸들
            Container(
              width: 48,
              height: 5,
              decoration: BoxDecoration(
                color: const Color(0xFFD9D9D9),
                borderRadius: BorderRadius.circular(100),
              ),
            ),

            const SizedBox(height: 20),

            // 제목
            Stack(
              alignment: Alignment.center,
              children: [
                const Center(
                  child: Text(
                    "재직 상태 변경",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                Align(
                  alignment: Alignment.centerRight,
                  child: GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      width: 28,
                      height: 28,
                      decoration: const BoxDecoration(
                        color: Color(0xFFF2F2F7),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.close,
                        color: Color(0xFFA5A5AF),
                      ),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            const Divider(
              height: 1,
              color: Color(0xFFF1F1F5),
            ),

            const SizedBox(height: 20),

            Row(
              children: [
                _buildStatusButton("퇴사"),
                const SizedBox(width: 12),
                _buildStatusButton("재직중"),
              ],
            ),

            const SizedBox(height: 28),

            SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton(
                onPressed: canSave
                    ? () {
                  widget.onSave(selectedStatus!);
                  Navigator.pop(context);
                }
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0084FF),
                  disabledBackgroundColor:
                  const Color(0xFF7FC1FF),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  "저장",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
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