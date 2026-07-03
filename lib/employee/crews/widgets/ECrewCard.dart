import 'package:flutter/material.dart';

import '../model/ECrewModel.dart';

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
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.only(bottom: 20),
        child: Row(
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                image: DecorationImage(
                  image: (crew.profileImageUrl != null &&
                      crew.profileImageUrl!.isNotEmpty)
                      ? NetworkImage(crew.profileImageUrl!)
                      : const AssetImage(
                      "assets/images/profile.png")
                  as ImageProvider,
                  fit: BoxFit.cover,
                ),
              ),
            ),

            const SizedBox(width: 14),

            Expanded(
              child: Column(
                crossAxisAlignment:
                CrossAxisAlignment.start,
                children: [
                  Text(
                    crew.crewRole == "OWNER"
                        ? "사장님"
                        : "근무자",
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF8E8E93),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    crew.name,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),

            if (showArrow)
              const Icon(
                Icons.chevron_right,
                color: Color(0xFFB8B8BE),
                size: 28,
              ),
          ],
        ),
      ),
    );
  }
}