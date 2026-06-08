import 'package:flutter/material.dart';

class TagChip extends StatelessWidget {

  final String text;

  const TagChip({
    super.key,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 4,
      ),

      decoration: BoxDecoration(
        color: Colors.grey.shade400,
        borderRadius:
        BorderRadius.circular(20),
      ),

      child: Text(
        text,

        style: const TextStyle(
          color: Colors.white,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}