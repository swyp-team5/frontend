import 'package:flutter/material.dart';

/// 홈 화면의 "요청 목록 >" 카드
/// 근무자들이 보낸 근무 변경(교대/대타) 요청 목록으로 이동하는 진입점
class RRequestListCard extends StatelessWidget {
  final VoidCallback? onTap;

  const RRequestListCard({
    super.key,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 18,
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            const Expanded(
              child: Text(
                "요청 목록",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            Icon(Icons.chevron_right),
          ],
        ),
      ),
    );
  }
}