import 'package:flutter/material.dart';

class InfoRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isEditMode;

  const InfoRow({
    super.key,
    required this.label,
    required this.value,
    this.isEditMode = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: Row(
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 16,
              // 기본: 회색 → 편집모드: 검정
              color: isEditMode
                  ? Colors.black
                  : const Color(0xFF767676),
              fontWeight:
              isEditMode ? FontWeight.w600 : FontWeight.normal,
            ),
          ),

          const Spacer(),

          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              // 기본: 검정 → 편집모드: 연회색
              color: isEditMode
                  ? const Color(0xFF999999)
                  : Colors.black,
            ),
          ),
        ],
      ),
    );
  }
}