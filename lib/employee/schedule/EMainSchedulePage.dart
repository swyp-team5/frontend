import 'package:flutter/material.dart';

import '../../common/widgets/BottomNavBar.dart';
import '../crews/ECrewPage.dart';
import '../home/EHomePage.dart';
import '../mypage/EMyPage.dart';
import 'EMonthSchedulePage.dart';
import 'EWeekSchedulePage.dart';

class EMainSchedulePage extends StatefulWidget {
  const EMainSchedulePage({super.key});

  @override
  State<EMainSchedulePage> createState() => _EMainSchedulePageState();
}

class _EMainSchedulePageState extends State<EMainSchedulePage> {
  /// true = 주간, false = 월간
  bool isWeekMode = true;

  /// 현재 선택된 날짜
  DateTime selectedDate = DateTime.now();

  /// API 연동 전 더미 데이터
  final Map<String, List<String>> monthSchedules = {
    "2026-06-02": ["이다빈"],
    "2026-06-06": ["이다빈"],
    "2026-06-10": ["이다빈"],
    "2026-06-13": ["이다빈"],
    "2026-06-17": ["이다빈"],
    "2026-06-20": ["이다빈"],
    "2026-06-24": ["이다빈"],
    "2026-06-27": ["이다빈"],
  };

  bool isAllViewSelected = false;


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      bottomNavigationBar: BottomNavBar(
        currentIndex: 2,
        onTap: (index) {
          if (index == 0) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const EHomePage()),
            );
          } else if (index == 1) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ECrewPage()),
            );
          } else if (index == 4) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const EMyPage()),
            );
          }
        },
      ),

      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                // ==========================
                // Header
                // ==========================
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 14,
                  ),
                  child: Row(
                    children: [
                      PopupMenuButton<int>(
                        padding: EdgeInsets.zero,
                        onSelected: (month) {
                          setState(() {
                            selectedDate = DateTime(
                              selectedDate.year,
                              month,
                              1,
                            );
                          });
                        },
                        itemBuilder: (_) {
                          return List.generate(
                            12,
                                (index) => PopupMenuItem(
                              value: index + 1,
                              child: Text("${index + 1}월"),
                            ),
                          );
                        },
                        child: Row(
                          children: [
                            Text(
                              "${selectedDate.month}월",
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(width: 2),
                            const Icon(Icons.keyboard_arrow_down),
                          ],
                        ),
                      ),

                      const Spacer(),

                      GestureDetector(
                        onTap: () {
                          setState(() {
                            isAllViewSelected = !isAllViewSelected;
                          });
                        },
                        child: Container(
                          height: 34,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: isAllViewSelected
                                ? const Color(0xFFEEEBFF)
                                : const Color(0xFFF1F1F5),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: isAllViewSelected
                                  ? const Color(0xFF7D67FD)
                                  : const Color(0xFFE0E2E5),
                              width: 1,
                            ),
                          ),
                          child: Text(
                            "전체 보기",
                            style: TextStyle(
                              fontSize: 12,
                              color: isAllViewSelected
                                  ? const Color(0xFF7D67FD)
                                  : const Color(0xFF767676),
                            ),
                          ),
                        ),
                      ),

                      IconButton(
                        onPressed: () {
                          // TODO : 필터
                        },
                        icon: const Icon(Icons.tune),
                      ),
                    ],
                  ),
                ),

                // ==========================
                // 내용
                // ==========================

                Expanded(
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 250),
                    child: isWeekMode
                        ? EWeekSchedulePage(
                      key: const ValueKey("week"),
                      selectedDate: selectedDate,
                      onDateChanged: (date) {
                        setState(() {
                          selectedDate = date;
                        });
                      },
                    )
                        : EMonthSchedulePage(
                      key: const ValueKey("month"),
                      selectedDate: selectedDate,
                      isAllViewSelected: isAllViewSelected,
                      schedules: monthSchedules,
                      onDateChanged: (date) {
                        setState(() {
                          selectedDate = date;
                        });
                      },
                    ),
                  ),
                ),
              ],
            ),

            // ==========================
            // 주 / 월 토글
            // ==========================

            Positioned(
              bottom: 14,
              left: 0,
              right: 0,
              child: Center(
                child: Container(
                  width: 88,
                  height: 34,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF2F2F5),
                    borderRadius: BorderRadius.circular(17),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              isWeekMode = true;
                            });
                          },
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 180),
                            decoration: BoxDecoration(
                              color: isWeekMode
                                  ? const Color(0xFF3A3A3C)
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(17),
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              "주",
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: isWeekMode
                                    ? Colors.white
                                    : const Color(0xFF8E8E93),
                              ),
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              isWeekMode = false;
                            });
                          },
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 180),
                            decoration: BoxDecoration(
                              color: !isWeekMode
                                  ? const Color(0xFF3A3A3C)
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(17),
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              "월",
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: !isWeekMode
                                    ? Colors.white
                                    : const Color(0xFF8E8E93),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}