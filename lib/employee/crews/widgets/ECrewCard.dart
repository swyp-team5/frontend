import 'package:flutter/material.dart';

import '../model/ECrewModel.dart';

class EmployeeCrewCard extends StatelessWidget {

  final EmployeeCrewModel crew;

  const EmployeeCrewCard({
    super.key,
    required this.crew,
  });

  @override
  Widget build(BuildContext context) {

    return Padding(
      padding: const EdgeInsets.only(bottom: 22),

      child: Row(
        children: [

          Container(
            width: 76,
            height: 76,

            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(14),
            ),
          ),

          const SizedBox(width: 18),

          Column(
            crossAxisAlignment:
            CrossAxisAlignment.start,

            children: [

              Text(
                crew.role,

                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                ),
              ),

              const SizedBox(height: 2),

              Text(
                crew.name,

                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}