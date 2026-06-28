import 'package:flutter/material.dart';
import '../models/ShiftCount.dart';

class RShiftRow extends StatelessWidget {
  final String title;
  final List<ShiftCount> counts;

  const RShiftRow({
    super.key,
    required this.title,
    required this.counts,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 54,
      child: Row(
        children: [
          SizedBox(
            width: 52,
            child: Center(
              child: Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),

          ...counts.map(
                (e) => Expanded(
              child: Center(
                child: Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: e.shortage
                        ? Colors.red
                        : _backgroundColor(title),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    "${e.count}",
                    style: TextStyle(
                      color: e.shortage
                          ? Colors.white
                          : _textColor(title),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }

  Color _backgroundColor(String type) {
    switch (type) {
      case "오픈":
        return const Color(0xFFE5F2FF);

      case "미들":
        return const Color(0xFFEAE4FF);

      case "마감":
        return const Color(0xFFDDF8E5);

      default:
        return Colors.grey.shade200;
    }
  }

  Color _textColor(String type) {
    switch (type) {
      case "오픈":
        return const Color(0xFF1687F8);

      case "미들":
        return const Color(0xFF7666F5);

      case "마감":
        return const Color(0xFF2AA85A);

      default:
        return Colors.black;
    }
  }
}