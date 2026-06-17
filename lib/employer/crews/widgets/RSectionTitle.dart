import 'package:flutter/material.dart';

class SectionTitle extends StatelessWidget {

  final String title;

  const SectionTitle({
    super.key,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {

    return Text(title,
      style: TextStyle(
        color: Colors.grey.shade500,
        fontSize: 15,
        fontWeight: FontWeight.w700,
      ),
    );
  }
}