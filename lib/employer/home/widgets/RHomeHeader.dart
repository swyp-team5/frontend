import 'package:flutter/material.dart';

class RHomeHeader extends StatelessWidget {
  final String storeName;
  final VoidCallback? onStoreTap;
  final VoidCallback? onNotificationTap;
  final bool hasUnread;

  const RHomeHeader({
    super.key,
    this.storeName = "매장명",
    this.onStoreTap,
    this.onNotificationTap,
    this.hasUnread = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        /// 매장 선택
        InkWell(
          onTap: onStoreTap,
          borderRadius: BorderRadius.circular(8),
          child: Row(
            children: [
              Text(
                storeName,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(width: 2),
              const Icon(Icons.keyboard_arrow_down),
            ],
          ),
        ),

        /// 알림 버튼
        IconButton(
          onPressed: onNotificationTap,
          icon: Stack(
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
    );
  }
}