import 'package:flutter/material.dart';

import 'RInfoRow.dart';

class InfoSectionCard extends StatelessWidget {

  final String title;
  final List<List<String>> items;
  final bool isEditMode;

  const InfoSectionCard({
    super.key,
    required this.title,
    required this.items,
    this.isEditMode = false,
  });

  @override
  Widget build(BuildContext context) {

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),

      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: isEditMode
                  ? const Color(0xFF999999)
                  : const Color(0xFF505050),
            ),
          ),

          const SizedBox(height: 30),

          for (int i = 0; i < items.length; i++) ...[
            InfoRow(
              label: items[i][0],
              value: items[i][1],
              isEditMode: isEditMode,
            ),

            if (i != items.length - 1) ...[
              const SizedBox(height: 1),
              Container(
                height: 1,
                color: const Color(0xFFF1F1F5),
              ),
              const SizedBox(height: 16),
            ],
          ],
        ],
      ),
    );
  }
}