import 'package:flutter/material.dart';

class ETagChip extends StatelessWidget {
  final String text;

  const ETagChip({
    super.key,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 3,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFFE6F3FF),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: Color(0xFF004A8F),
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}