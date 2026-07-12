import 'dart:ui';

import 'package:flutter/material.dart';

class EHomeHeader extends StatelessWidget {
  final String workPlaceName;
  final VoidCallback? onNotificationTap;
  final bool hasUnread;

  const EHomeHeader({
    super.key,
    required this.workPlaceName,
    this.onNotificationTap,
    this.hasUnread = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Text(
              workPlaceName.isEmpty ? "" : workPlaceName,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(width: 4),
            const Icon(Icons.keyboard_arrow_down),
          ],
        ),

        Row(
          children: [
            // Container(
            //   padding: const EdgeInsets.symmetric(
            //     horizontal: 16,
            //     vertical: 8,
            //   ),
            //   decoration: BoxDecoration(
            //     color: Colors.white,
            //     borderRadius: BorderRadius.circular(30),
            //   ),
            //   child: Row(
            //     children: [
            //       CircleAvatar(
            //         radius: 3,
            //         backgroundColor: const Color(0xFF9E9E9E),
            //       ),
            //       SizedBox(width: 6),
            //       Text(
            //         "출근전",
            //         style: TextStyle(
            //           color: const Color(0xFF8A8A8A),
            //           fontWeight: FontWeight.w600,
            //         ),
            //       ),
            //     ],
            //   ),
            // ),
            // const SizedBox(width: 10),
            GestureDetector(
              onTap: onNotificationTap,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  const Icon(Icons.notifications_none, size: 28),
                  if (hasUnread)
                    Positioned(
                      right: -1,
                      top: -1,
                      child: Container(
                        width: 9,
                        height: 9,
                        decoration: const BoxDecoration(
                          color: Color(0xFFFF3B30),
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}