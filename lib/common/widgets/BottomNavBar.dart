import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

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
        "icon": "assets/images/home.svg",
        "label": "홈",
      },

      {
        "icon": "assets/images/worker.svg",
        "label": "동료",
      },

      {
        "icon": "assets/images/calendar.svg", // calender -> calendar 오타 수정
        "label": "스케줄",
      },

      // {
      //   "icon": "assets/images/salary.svg",
      //   "label": "급여",
      // },

      {
        "icon": "assets/images/mypage.svg",
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

                    SvgPicture.asset(
                      item["icon"] as String,

                      width: 24,
                      height: 24,

                      colorFilter: ColorFilter.mode(
                        isSelected
                            ? Colors.grey.shade700
                            : Colors.grey.shade400,
                        BlendMode.srcIn,
                      ),
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