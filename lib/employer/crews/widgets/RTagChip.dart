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
        horizontal: 6,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFFE6F3FF),
        borderRadius: BorderRadius.circular(100),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: Color(0xFF004A8F),
          fontSize: 13,
        ),
      ),
    );
  }
}