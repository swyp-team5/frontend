import 'package:flutter/material.dart';

class EYearMonthBottomSheet extends StatefulWidget {
  const EYearMonthBottomSheet({
    super.key,
  });

  @override
  State<EYearMonthBottomSheet> createState() => _EYearMonthBottomSheetState();
}

class _EYearMonthBottomSheetState extends State<EYearMonthBottomSheet> {

  int? selectedYear;
  int? selectedMonth;

  bool get canSave =>
      selectedYear != null &&
          selectedMonth != null;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 30,),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(20),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [

            /// 핸들
            Container(
              width: 48,
              height: 5,
              decoration: BoxDecoration(
                color: const Color(0xFFE3E3E8),
                borderRadius:
                BorderRadius.circular(999),
              ),
            ),

            const SizedBox(height: 24),

            /// 제목
            Stack(
              alignment: Alignment.center,
              children: [
                const Center(
                  child: Text(
                    "연월별 설정",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),

                Positioned(
                  right: 0,
                  child: GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
                    },
                    child: Container(
                      width: 28,
                      height: 28,
                      decoration: const BoxDecoration(
                        color: Color(0xFFF2F2F7),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.close,
                        size: 18,
                        color: Color(0xFFA5A5AF),
                      ),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            Container(
              height: 1,
              color: const Color(0xFFF1F1F5),
            ),

            const SizedBox(height: 20),

            /// 연도 선택
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "연도 선택",
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),

            const SizedBox(height: 14),

            Row(
              children: [
                Expanded(
                  child: _YearButton(
                    text: "2024년",
                    selected: selectedYear == 2024,
                    onTap: () {
                      setState(() {
                        selectedYear = 2024;
                      });
                    },
                  ),
                ),

                const SizedBox(width: 8),

                Expanded(
                  child: _YearButton(
                    text: "2025년",
                    selected: selectedYear == 2025,
                    onTap: () {
                      setState(() {
                        selectedYear = 2025;
                      });
                    },
                  ),
                ),

                const SizedBox(width: 8),

                Expanded(
                  child: _YearButton(
                    text: "2026년",
                    selected: selectedYear == 2026,
                    onTap: () {
                      setState(() {
                        selectedYear = 2026;
                      });
                    },
                  ),
                ),
              ],
            ),

            const SizedBox(height: 26),

            /// 월 선택
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "월 선택",
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),

            const SizedBox(height: 14),

            GridView.builder(
              shrinkWrap: true,
              physics:
              const NeverScrollableScrollPhysics(),
              itemCount: 12,
              gridDelegate:
              const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
                childAspectRatio: 1.5,
              ),
              itemBuilder: (_, index) {

                final month = index + 1;

                return _MonthButton(
                  text: "$month월",
                  selected:
                  selectedMonth == month,
                  onTap: () {
                    setState(() {
                      selectedMonth = month;
                    });
                  },
                );
              },
            ),

            const SizedBox(height: 28),

            /// 저장
            SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton(
                onPressed: canSave
                    ? () {

                  Navigator.pop(
                    context,
                    DateTime(
                      selectedYear!,
                      selectedMonth!,
                      1,
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
                child: Text(
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

class _YearButton extends StatelessWidget {
  final String text;
  final bool selected;
  final VoidCallback onTap;

  const _YearButton({
    required this.text,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {

    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 48,
        decoration: BoxDecoration(
          color: selected
              ? const Color(0xFFE6F3FF)
              : const Color(0xFFF1F1F5),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: selected
                ? const Color(0xFF0084FF)
                : Colors.transparent,
            width: 1.5,
          ),
        ),
        alignment: Alignment.center,
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
    );
  }
}

class _MonthButton extends StatelessWidget {
  final String text;
  final bool selected;
  final VoidCallback onTap;

  const _MonthButton({
    required this.text,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {

    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 48,
        decoration: BoxDecoration(
          color: selected
              ? const Color(0xFFE6F3FF)
              : const Color(0xFFF1F1F5),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: selected
                ? const Color(0xFF0084FF)
                : Colors.transparent,
            width: 1.5,
          ),
        ),
        alignment: Alignment.center,
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
    );
  }
}