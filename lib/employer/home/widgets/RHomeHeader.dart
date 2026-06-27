import 'package:flutter/material.dart';

class RHomeHeader extends StatelessWidget {
  final String storeName;
  final VoidCallback? onStoreTap;
  final VoidCallback? onNotificationTap;

  const RHomeHeader({
    super.key,
    this.storeName = "매장명",
    this.onStoreTap,
    this.onNotificationTap,
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
          icon: const Icon(
            Icons.notifications_none,
            size: 28,
          ),
        ),
      ],
    );
  }
}