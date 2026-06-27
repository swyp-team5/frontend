import 'package:flutter/material.dart';

class RNoticeBanner extends StatelessWidget {
  final String title;
  final String notice;
  final VoidCallback? onTap;

  const RNoticeBanner({
    super.key,
    this.title = "공지",
    this.notice = "마감 때 쓰레기 비우는거 잊지 마세요",
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
          vertical: 14,
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            const SizedBox(width: 10),
            Text(
              "$title \t 📌",
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                notice,
                style: const TextStyle(
                  fontSize: 14,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}