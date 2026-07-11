import 'package:flutter/material.dart';

class BottomNavBar extends StatelessWidget {

  final int currentIndex;
  final Function(int) onTap;

  const BottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {

    final items = [
      {
        "icon": Icons.home_filled,
        "label": "홈",
      },

      {
        "icon": Icons.groups_rounded,
        "label": "동료",
      },

      {
        "icon": Icons.calendar_month,
        "label": "스케줄",
      },

      // {
      //   "icon": Icons.payments_outlined,
      //   "label": "급여",
      // },

      {
        "icon": Icons.person_outline,
        "label": "마이페이지",
      },
    ];

    return Container(
      padding: const EdgeInsets.symmetric(
        vertical: 8,
      ),

      decoration: BoxDecoration(
        color: Colors.white,

        border: Border(
          top: BorderSide(
            color: Colors.grey.shade300,
          ),
        ),
      ),

      child: SafeArea(
        top: false,

        child: Row(
          mainAxisAlignment:
          MainAxisAlignment.spaceAround,

          children: List.generate(
            items.length,
                (index) {

              final item = items[index];

              final bool isSelected =
                  currentIndex == index;

              return GestureDetector(
                onTap: () {
                  onTap(index);
                },

                child: Column(
                  mainAxisSize: MainAxisSize.min,

                  children: [

                    Icon(
                      item["icon"] as IconData,

                      size: 24,

                      color:
                      isSelected
                          ? Colors.grey.shade700
                          : Colors.grey.shade400,
                    ),

                    const SizedBox(height: 4),

                    Text(
                      item["label"] as String,

                      style: TextStyle(
                        color:
                        isSelected
                            ? Colors.grey.shade700
                            : Colors.grey.shade400,

                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}