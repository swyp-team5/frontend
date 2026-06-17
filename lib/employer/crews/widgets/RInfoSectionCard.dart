import 'package:flutter/material.dart';

import 'RInfoRow.dart';

class InfoSectionCard extends StatelessWidget {

  final String title;
  final List<List<String>> items;

  const InfoSectionCard({
    super.key,
    required this.title,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {

    return Container(
      width: double.infinity,

      padding: const EdgeInsets.symmetric(
        horizontal: 18,
        vertical: 22,
      ),

      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(24),
      ),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,

        children: [

          Text(title,
            style: const TextStyle(
              fontSize: 20,
              fontWeight:
              FontWeight.bold,
            ),
          ),

          const SizedBox(height: 24),

          ...items.map((item) => InfoRow(
              label: item[0],
              value: item[1],
            ),
          ),
        ],
      ),
    );
  }
}