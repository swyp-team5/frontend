import 'package:flutter/material.dart';

class EmploymentDateBottomSheet extends StatefulWidget {
  final int year;
  final int month;
  final Function(DateTime date) onSave;

  const EmploymentDateBottomSheet({
    super.key,
    required this.year,
    required this.month,
    required this.onSave,
  });

  @override
  State<EmploymentDateBottomSheet> createState() =>
      _EmploymentDateBottomSheetState();
}

class _EmploymentDateBottomSheetState
    extends State<EmploymentDateBottomSheet> {
  int? selectedDay;

  late int currentYear;
  late int currentMonth;

  @override
  void initState() {
    super.initState();

    currentYear = widget.year;
    currentMonth = widget.month;
  }

  int get daysInMonth {
    return DateTime(
      currentMonth == 12 ? currentYear + 1 : currentYear,
      currentMonth == 12 ? 1 : currentMonth + 1,
      0,
    ).day;
  }

  @override
  Widget build(BuildContext context) {
    final bool canSave = selectedDay != null;

    // 현재 달의 1일
    final firstDay = DateTime(currentYear, currentMonth, 1);

    // 일요일 시작으로 변환 (일=0, 월=1 ... 토=6)
    final int startOffset = firstDay.weekday % 7;

    // 이전 달 마지막 날짜
    final int prevMonthLastDay =
        DateTime(currentYear, currentMonth, 0).day;

    // 총 셀 수
    final int totalCells =
        ((startOffset + daysInMonth) / 7).ceil() * 7;

    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(28),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            /// 핸들
            Container(
              width: 48,
              height: 5,
              decoration: BoxDecoration(
                color: const Color(0xFFD9D9D9),
                borderRadius: BorderRadius.circular(100),
              ),
            ),

            const SizedBox(height: 20),

            /// 제목
            Stack(
              alignment: Alignment.center,
              children: [
                const Text(
                  "입사일 설정",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Align(
                  alignment: Alignment.centerRight,
                  child: GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: const CircleAvatar(
                      radius: 14,
                      backgroundColor: Color(0xFFF2F2F7),
                      child: Icon(
                        Icons.close,
                        size: 18,
                        color: Color(0xFFA5A5AF),
                      ),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 6),

            const Text(
              "입사일을 설정해주세요",
              style: TextStyle(
                color: Color(0xFF767676),
              ),
            ),

            const SizedBox(height: 20),

            const Divider(
              height: 1,
              color: Color(0xFFF1F1F5),
            ),

            const SizedBox(height: 16),

            /// 월 이동
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: const Icon(Icons.chevron_left),
                  onPressed: () {
                    setState(() {
                      if (currentMonth == 1) {
                        currentMonth = 12;
                        currentYear--;
                      } else {
                        currentMonth--;
                      }

                      selectedDay = null;
                    });
                  },
                ),

                Text(
                  "$currentYear년 $currentMonth월",
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                  ),
                ),

                IconButton(
                  icon: const Icon(Icons.chevron_right),
                  onPressed: () {
                    setState(() {
                      if (currentMonth == 12) {
                        currentMonth = 1;
                        currentYear++;
                      } else {
                        currentMonth++;
                      }

                      selectedDay = null;
                    });
                  },
                ),
              ],
            ),

            const SizedBox(height: 12),

            /// 요일
            const Row(
              children: [
                Expanded(
                  child: Center(
                    child: Text(
                      "일",
                      style: TextStyle(
                        color: Color(0xFF999999), fontSize: 14,
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: Center(
                    child: Text(
                      "월",
                      style: TextStyle(
                        color: Color(0xFF999999), fontSize: 14,
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: Center(
                    child: Text(
                      "화",
                      style: TextStyle(
                        color: Color(0xFF999999), fontSize: 14,
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: Center(
                    child: Text(
                      "수",
                      style: TextStyle(
                          color: Color(0xFF999999), fontSize: 14,
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: Center(
                    child: Text(
                      "목",
                      style: TextStyle(
                        color: Color(0xFF999999), fontSize: 14,
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: Center(
                    child: Text(
                      "금",
                      style: TextStyle(
                        color: Color(0xFF999999), fontSize: 14,
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: Center(
                    child: Text(
                      "토",
                      style: TextStyle(
                        color: Color(0xFF999999), fontSize: 14,
                      ),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            /// 캘린더
            SizedBox(
              height: 320,
              child: GridView.builder(
                physics: const NeverScrollableScrollPhysics(),
                itemCount: totalCells,
                gridDelegate:
                const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 7,
                  crossAxisSpacing: 6,
                  mainAxisSpacing: 8,
                  childAspectRatio: 1,
                ),
                itemBuilder: (_, index) {
                  late int day;
                  bool isCurrentMonth = true;

                  if (index < startOffset) {
                    day = prevMonthLastDay -
                        startOffset +
                        index +
                        1;
                    isCurrentMonth = false;
                  } else if (index >=
                      startOffset + daysInMonth) {
                    day =
                        index - (startOffset + daysInMonth) + 1;
                    isCurrentMonth = false;
                  } else {
                    day = index - startOffset + 1;
                  }

                  final bool selected =
                      isCurrentMonth &&
                          selectedDay == day;

                  return GestureDetector(
                    onTap: isCurrentMonth
                        ? () {
                      setState(() {
                        selectedDay = day;
                      });
                    }
                        : null,
                    child: Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: selected
                            ? const Color(0xFF0084FF)
                            : Colors.transparent,
                      ),
                      child: Center(
                        child: Text(
                          "$day",
                          style: TextStyle(
                            fontSize: 16,
                            color: selected
                                ? Colors.white
                                : isCurrentMonth
                                ? Colors.black
                                : const Color(0xFFD1D1D6),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

            /// 저장 버튼
            SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton(
                onPressed: canSave
                    ? () {
                  widget.onSave(
                    DateTime(
                      currentYear,
                      currentMonth,
                      selectedDay!,
                    ),
                  );

                  Navigator.pop(context);
                }
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0084FF),
                  disabledBackgroundColor:
                  const Color(0xFF7FC1FF),
                  shape: RoundedRectangleBorder(
                    borderRadius:
                    BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  "저장",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
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