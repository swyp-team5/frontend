import 'package:flutter/material.dart';

class ApplicationFormHeader extends StatelessWidget {
  const ApplicationFormHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        GestureDetector(
          onTap: () => Navigator.pop(context),
          child: const Icon(Icons.arrow_back_ios_new, size: 22),
        ),
        const Expanded(
          child: Center(
            child: Text(
              "신청서 작성",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
            ),
          ),
        ),
        const SizedBox(width: 22),
      ],
    );
  }
}