import 'package:flutter/material.dart';

class EInfoRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isEditMode;
  final VoidCallback? onTap;

  const EInfoRow({
    super.key,
    required this.label,
    required this.value,
    required this.isEditMode,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: isEditMode ? onTap : null,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 18),
        child: Row(
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 16,
                color: isEditMode
                    ? Colors.black              // 저장 상태
                    : const Color(0xFF767676),  // 에딧 아이콘 상태
                fontWeight: FontWeight.w500,
              ),
            ),

            const Spacer(),

            Text(
              value,
              style: TextStyle(
                fontSize: 16,
                color: isEditMode
                    ? const Color(0xFF999999)   // 저장 상태
                    : Colors.black,             // 에딧 아이콘 상태
              ),
            ),

            if (isEditMode)
              const Padding(
                padding: EdgeInsets.only(left: 4),
                child: Icon(
                  Icons.chevron_right,
                  size: 18,
                  color: Color(0xFFB5B5BC),
                ),
              ),
          ],
        ),
      ),
    );
  }
}