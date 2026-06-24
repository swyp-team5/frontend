import 'package:flutter/material.dart';

class WorkDaysBottomSheet extends StatefulWidget {
  final List<String>? initialDays;
  final ValueChanged<List<String>> onSave;

  const WorkDaysBottomSheet({
    super.key,
    this.initialDays,
    required this.onSave,
  });

  @override
  State<WorkDaysBottomSheet> createState() =>
      _WorkDaysBottomSheetState();
}

class _WorkDaysBottomSheetState
    extends State<WorkDaysBottomSheet> {
  /// 요일 순서
  final List<String> weekDays = const [
    "월요일",
    "화요일",
    "수요일",
    "목요일",
    "금요일",
    "토요일",
    "일요일",
  ];

  late Set<String> selectedDays;

  @override
  void initState() {
    super.initState();

    /// 현재 설정: 처음에는 아무것도 선택되지 않은 상태
    selectedDays = <String>{};

    ///나중에 저장한 값을 다시 보여주고 싶다면 아래 한 줄로 교체
    /// selectedDays = widget.initialDays?.toSet() ?? {};
  }

  /// 저장 버튼 활성화 여부
  bool get canSave => selectedDays.isNotEmpty;

  Widget _buildDayButton(String day) {
    final bool selected = selectedDays.contains(day);

    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            if (selected) {
              selectedDays.remove(day);
            } else {
              selectedDays.add(day);
            }
          });
        },
        child: Container(
          height: 60,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: selected
                ? const Color(0xFFE6F3FF)
                : const Color(0xFFF1F1F5),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: selected
                  ? const Color(0xFF0084FF)
                  : Colors.transparent,
              width: 1.5,
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  day,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight:
                    selected ? FontWeight.w700 : FontWeight.w400,
                    color: const Color(0xFF202020),
                  ),
                ),
              ),
              if (selected)
                Container(
                  width: 24,
                  height: 24,
                  decoration: const BoxDecoration(
                    color: Color(0xFF0084FF),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check,
                    color: Colors.white,
                    size: 16,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRow(String left, [String? right]) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          _buildDayButton(left),
          if (right != null) ...[
            const SizedBox(width: 12),
            _buildDayButton(right),
          ] else
            const Spacer(),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
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
                const Column(
                  children: [
                    Text(
                      "근무 요일 설정",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: 6),
                    Text(
                      "중복 선택이 가능해요",
                      style: TextStyle(
                        fontSize: 14,
                        color: Color(0xFF767676),
                      ),
                    ),
                  ],
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

            const SizedBox(height: 20),

            const Divider(
              height: 1,
              color: Color(0xFFF1F1F5),
            ),

            const SizedBox(height: 20),

            _buildRow("월요일", "화요일"),
            _buildRow("수요일", "목요일"),
            _buildRow("금요일", "토요일"),
            _buildRow("일요일"),

            const SizedBox(height: 20),

            SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton(
                onPressed: canSave
                    ? () {
                  // 항상 월~일 순으로 정렬해서 저장
                  final orderedDays = weekDays
                      .where(
                        (day) => selectedDays.contains(day),
                  )
                      .toList();

                  widget.onSave(orderedDays);
                  Navigator.pop(context);
                }
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0084FF),
                  disabledBackgroundColor:
                  const Color(0xFF7FC1FF),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius:
                    BorderRadius.circular(8),
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