import 'package:flutter/material.dart';

class RDropdownField extends StatelessWidget {
  final String value;

  final String hintText;

  final VoidCallback onTap;

  const RDropdownField({
    super.key,
    required this.value,
    required this.hintText,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {

    final bool isHint = value.isEmpty;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 54,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: const Color(0xFFF5F5FA),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [

            Expanded(
              child: Text(
                isHint ? hintText : value,
                style: TextStyle(
                  fontSize: 16,
                  color: isHint
                      ? const Color(0xFF9A9AA2)
                      : const Color(0xFF666666),
                ),
              ),
            ),

            const Icon(
              Icons.keyboard_arrow_down,
              size: 22,
            ),
          ],
        ),
      ),
    );
  }
}