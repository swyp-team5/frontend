import 'package:flutter/material.dart';

class RTagChip extends StatelessWidget {
  final String text;

  const RTagChip({
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
        color: const Color(0xFFD8EBFF),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: Color(0xFF0B6FD8),
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}