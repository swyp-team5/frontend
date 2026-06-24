import 'package:flutter/material.dart';

import 'EmploymentDateBottomSheet.dart';

class EmploymentYearMonthBottomSheet extends StatefulWidget {
  final int initialYear;
  final int initialMonth;

  // DateTime 하나를 전달하도록 변경
  final Function(DateTime date) onSave;

  const EmploymentYearMonthBottomSheet({
    super.key,
    required this.initialYear,
    required this.initialMonth,
    required this.onSave,
  });

  @override
  State<EmploymentYearMonthBottomSheet> createState() =>
      _EmploymentYearMonthBottomSheetState();
}

class _EmploymentYearMonthBottomSheetState
    extends State<EmploymentYearMonthBottomSheet> {
  int? selectedYear;
  int? selectedMonth;

  final List<int> years = [2024, 2025, 2026];

  @override
  void initState() {
    super.initState();

    // 초기에는 선택 없이 시작
    selectedYear = null;
    selectedMonth = null;
  }

  Widget _buildSelectButton({
    required String text,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 52,
        decoration: BoxDecoration(
          color: selected
              ? const Color(0xFFE6F3FF)
              : const Color(0xFFF1F1F5),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: selected
                ? const Color(0xFF007AFF)
                : Colors.transparent,
            width: 1.5,
          ),
        ),
        child: Center(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: selected
                  ? const Color(0xFF004A8F)
                  : const Color(0xFF767676),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool canSubmit =
        selectedYear != null && selectedMonth != null;

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
            // 핸들
            Container(
              width: 48,
              height: 5,
              decoration: BoxDecoration(
                color: const Color(0xFFD9D9D9),
                borderRadius: BorderRadius.circular(100),
              ),
            ),

            const SizedBox(height: 20),

            // 제목
            Stack(
              alignment: Alignment.center,
              children: [
                const Center(
                  child: Text(
                    "입사일 설정",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Align(
                  alignment: Alignment.centerRight,
                  child: GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      width: 28,
                      height: 28,
                      decoration: const BoxDecoration(
                        color: Color(0xFFF2F2F7),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.close,
                        color: Color(0xFFA5A5AF),
                      ),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            const Divider(
              height: 1,
              color: Color(0xFFF1F1F5),
            ),

            const SizedBox(height: 20),

            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "연도 선택",
                style: TextStyle(
                  fontSize: 14,
                  color: Color(0xFF505050),
                ),
              ),
            ),

            const SizedBox(height: 12),

            Row(
              children: years.map((year) {
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: _buildSelectButton(
                      text: "$year년",
                      selected: selectedYear == year,
                      onTap: () {
                        setState(() {
                          selectedYear = year;
                        });
                      },
                    ),
                  ),
                );
              }).toList(),
            ),

            const SizedBox(height: 24),

            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "월 선택",
                style: TextStyle(
                  fontSize: 14,
                  color: Color(0xFF505050),
                ),
              ),
            ),

            const SizedBox(height: 12),

            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: 12,
              gridDelegate:
              const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4,
                crossAxisSpacing: 8,
                mainAxisSpacing: 10,
                childAspectRatio: 1.6,
              ),
              itemBuilder: (_, index) {
                final month = index + 1;

                return _buildSelectButton(
                  text: "$month월",
                  selected: selectedMonth == month,
                  onTap: () {
                    setState(() {
                      selectedMonth = month;
                    });
                  },
                );
              },
            ),

            const SizedBox(height: 28),

            SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton(
                onPressed: canSubmit
                    ? () {
                  // 현재 바텀시트 닫기
                  Navigator.pop(context);

                  // 날짜 선택 바텀시트 열기
                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    backgroundColor: Colors.white,
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(28),
                      ),
                    ),
                    builder: (_) => EmploymentDateBottomSheet(
                      year: selectedYear!,
                      month: selectedMonth!,
                      onSave: (date) {
                        // RCrewDetailPage까지 전달
                        widget.onSave(date);
                      },
                    ),
                  );
                }
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0084FF),
                  disabledBackgroundColor:
                  const Color(0xFF7FC1FF),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  "다음",
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