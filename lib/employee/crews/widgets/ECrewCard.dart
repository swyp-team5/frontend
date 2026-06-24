import 'package:flutter/material.dart';

import '../model/ECrewModel.dart';
import 'ETagChip.dart';

class ECrewCard extends StatelessWidget {

  final ECrewModel crew;
  final VoidCallback? onTap;
  final bool showArrow;

  const ECrewCard({
    super.key,
    required this.crew,
    this.onTap,
    this.showArrow = true,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 22),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Row(
          children: [

            /// 프로필
            Container(
              width: 60, height: 60,
              decoration: BoxDecoration(
                color: const Color(0xFFD4DCE3),
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Icon(Icons.person,
                size: 38,
                color: Color(0xFF7A8795),
              ),
            ),

            const SizedBox(width: 14),

            /// 정보
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(crew.role,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF8E8E93),
                    ),
                  ),

                  const SizedBox(height: 2),

                  Text(crew.name,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  /// 태그
                  if (crew.role != "사장님" && crew.tags.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 6, runSpacing: 6,
                      children:
                      crew.tags.map((tag) => ETagChip(text: tag)).toList(),
                    ),
                  ],
                ],
              ),
            ),

            if (showArrow)
              const Icon(Icons.chevron_right,
                color: Color(0xFFB8B8BE),
                size: 28,
              ),
          ],
        ),
      ),
    );
  }
}