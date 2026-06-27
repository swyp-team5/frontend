import 'dart:ui';

import 'package:flutter/material.dart';

class EHomeHeader extends StatelessWidget {
  const EHomeHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: const [
            Text(
              "매장명",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(width: 4),
            Icon(Icons.keyboard_arrow_down),
          ],
        ),

        Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 8,
              ),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(30),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 3,
                    backgroundColor: const Color(0xFF9E9E9E),
                  ),
                  SizedBox(width: 6),
                  Text(
                    "출근전",
                    style: TextStyle(
                      color: const Color(0xFF8A8A8A),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            const Icon(Icons.notifications_none, size: 28),
          ],
        ),
      ],
    );
  }
}