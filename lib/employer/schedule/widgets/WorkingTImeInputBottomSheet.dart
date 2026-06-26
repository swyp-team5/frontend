import 'package:flutter/material.dart';

class WorkingTimeInputBottomSheet extends StatefulWidget {
  const WorkingTimeInputBottomSheet({
    super.key,
    this.initialOpenTime,
    this.initialCloseTime,
  });

  final TimeOfDay? initialOpenTime;
  final TimeOfDay? initialCloseTime;

  static Future<StoreTimeRange?> show(
      BuildContext context, {
        TimeOfDay? initialOpenTime,
        TimeOfDay? initialCloseTime,
      }) {
    return showModalBottomSheet<StoreTimeRange>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(28),
        ),
      ),
      builder: (_) => WorkingTimeInputBottomSheet(
        // initial 값 전달
        initialOpenTime: initialOpenTime,
        initialCloseTime: initialCloseTime,
      ),
    );
  }

  @override
  State<WorkingTimeInputBottomSheet> createState() =>
      _WorkingTimeInputBottomSheetState();
}

class _WorkingTimeInputBottomSheetState extends State<WorkingTimeInputBottomSheet> {
  late List<String> digits;

  // 현재 선택 중인 입력 칸
// 0: 오픈 시, 1: 오픈 분, 2: 마감 시, 3: 마감 분
  int selectedIndex = 0;

  // 현재 선택된 칸에 몇 자리 입력했는지 (0 또는 1)
  int inputCount = 0;

// 각 칸은 "00" 형태의 문자열로 관리
  String openHour = "00";
  String openMinute = "00";
  String closeHour = "00";
  String closeMinute = "00";

  @override
  void initState() {
    super.initState();

    if (widget.initialOpenTime != null) {
      openHour =
          widget.initialOpenTime!.hour.toString().padLeft(2, "0");
      openMinute =
          widget.initialOpenTime!.minute.toString().padLeft(2, "0");
    }

    if (widget.initialCloseTime != null) {
      closeHour =
          widget.initialCloseTime!.hour.toString().padLeft(2, "0");
      closeMinute =
          widget.initialCloseTime!.minute.toString().padLeft(2, "0");
    }
  }

  /// 저장 버튼 활성화 여부
  bool get canSave {
    return !(openHour == "00" &&
        openMinute == "00" &&
        closeHour == "00" &&
        closeMinute == "00");
  }

  /// 숫자 입력
  void input(String value) {
    setState(() {
      switch (selectedIndex) {
      // 오픈 시간(HH)
        case 0:
          if (inputCount == 0) {
            final n = int.parse(value);

            if (n >= 3) {
              // 3~9 -> 03~09 확정 후 분으로 이동
              openHour = "0$value";
              selectedIndex = 1;
            } else {
              // 0~2 -> 오른쪽 자리에 임시 표시 (00, 01, 02)
              openHour = "0$value";
              inputCount = 1;
            }
          } else {
            // 두 번째 입력 -> 기존 오른쪽 숫자를 왼쪽으로 이동
            // 예) 01 + 5 -> 15
            //     02 + 3 -> 23
            //     00 + 8 -> 08
            openHour = "${openHour[1]}$value";
            selectedIndex = 1;
            inputCount = 0;
          }
          break;

      // 오픈 분(MM)
        case 1:
          if (inputCount == 0) {
            openMinute = "${value}0";
            inputCount = 1;
          } else {
            openMinute = "${openMinute[0]}$value";
            selectedIndex = 2;
            inputCount = 0;
          }
          break;

      // 마감 시간(HH)
      // 마감 시간(HH)
        case 2:
          if (inputCount == 0) {
            final n = int.parse(value);

            if (n >= 3) {
              // 3~9 -> 03~09로 확정 후 다음 칸(마감 분)으로 이동
              closeHour = "0$value";
              selectedIndex = 3;
              inputCount = 0;
            } else {
              // 0~2 -> 00, 01, 02 형태로 임시 표시하고 시간 입력 유지
              closeHour = "0$value";
              inputCount = 1;
            }
          } else {
            // 두 번째 숫자 입력
            // 예) 01 + 5 -> 15
            //     02 + 3 -> 23
            //     00 + 8 -> 08
            closeHour = "${closeHour[1]}$value";
            selectedIndex = 3;
            inputCount = 0;
          }
          break;

      // 마감 분(MM)
        case 3:
          if (inputCount == 0) {
            closeMinute = "${value}0";
            inputCount = 1;
          } else {
            closeMinute = "${closeMinute[0]}$value";
            inputCount = 0;
          }
          break;
      }
    });
  }

  /// 삭제 버튼
  void backspace() {
    setState(() {
      switch (selectedIndex) {
        case 0:
          openHour = "00";
          break;
        case 1:
          openMinute = "00";
          break;
        case 2:
          closeHour = "00";
          break;
        case 3:
          closeMinute = "00";
          break;
      }

      inputCount = 0;

      if (selectedIndex > 0) {
        selectedIndex--;
      }
    });
  }

  Widget timeBox({
    required String value,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 56,
        height: 48,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: const Color(0xFFF2F2F5),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: selected
                ? const Color(0xFF1E88FF)
                : Colors.transparent,
            width: 2,
          ),
        ),
        child: Text(
          value,
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget numberButton(String value) {
    return InkWell(
      onTap: () => input(value),
      borderRadius: BorderRadius.circular(40),
      child: SizedBox(
        width: 70,
        height: 60,
        child: Center(
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding:
        const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 10),

            Container(
              width: 52,
              height: 6,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius:
                BorderRadius.circular(99),
              ),
            ),

            const SizedBox(height: 22),

            Stack(
              alignment: Alignment.center,
              children: [
                const Center(
                  child: Text(
                    "근무 시간 설정",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Align(
                  alignment: Alignment.centerRight,
                  child: IconButton(
                    onPressed: () {
                      Navigator.pop(
                        context,
                        StoreTimeRange(
                          openTime: TimeOfDay(
                            hour: int.parse(openHour.replaceAll("_", "0")),
                            minute: int.parse(openMinute.replaceAll("_", "0")),
                          ),
                          closeTime: TimeOfDay(
                            hour: int.parse(closeHour.replaceAll("_", "0")),
                            minute: int.parse(closeMinute.replaceAll("_", "0")),
                          ),
                        ),
                      );
                    },
                    icon: const Icon(Icons.close),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 6),

            const Text(
              "근무 시간을 입력해주세요",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Color(0xFF767676),
              ),
            ),

            const SizedBox(height: 24),

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                timeBox(
                  value: openHour,
                  selected: selectedIndex == 0,
                  onTap: () => setState(() => selectedIndex = 0),
                ),

                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 6),
                  child: Text(
                    ":",
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),

                timeBox(
                  value: openMinute,
                  selected: selectedIndex == 1,
                  onTap: () => setState(() => selectedIndex = 1),
                ),

                const SizedBox(width: 16),

                const Text(
                  "-",
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(width: 16),

                timeBox(
                  value: closeHour,
                  selected: selectedIndex == 2,
                  onTap: () => setState(() => selectedIndex = 2),
                ),

                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 6),
                  child: Text(
                    ":",
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),

                timeBox(
                  value: closeMinute,
                  selected: selectedIndex == 3,
                  onTap: () => setState(() => selectedIndex = 3),
                ),
              ],
            ),

            const SizedBox(height: 24),

            GridView.count(
              crossAxisCount: 3,
              shrinkWrap: true,
              physics:
              const NeverScrollableScrollPhysics(),
              childAspectRatio: 1.6,
              children: [
                ...List.generate(
                  9,
                      (i) => numberButton("${i + 1}"),
                ),
                const SizedBox(),
                numberButton("0"),
                InkWell(
                  onTap: backspace,
                  child: const Center(
                    child: Icon(
                      Icons.backspace_outlined,
                      size: 28,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: canSave
                    ? () {
                  Navigator.pop(
                    context,
                    StoreTimeRange(
                      openTime: TimeOfDay(
                        hour: int.parse(openHour.replaceAll("_", "0")),
                        minute: int.parse(openMinute.replaceAll("_", "0")),
                      ),
                      closeTime: TimeOfDay(
                        hour: int.parse(closeHour.replaceAll("_", "0")),
                        minute: int.parse(closeMinute.replaceAll("_", "0")),
                      ),
                    ),
                  );
                }
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                  const Color(0xff1687F8),
                  disabledBackgroundColor:
                  const Color(0xffA9D0FB),
                  elevation: 0,
                  shape:
                  RoundedRectangleBorder(
                    borderRadius:
                    BorderRadius.circular(14),
                  ),
                ),
                child: const Text(
                  "저장",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 17,
                    fontWeight:
                    FontWeight.bold,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

class StoreTimeRange {
  final TimeOfDay openTime;
  final TimeOfDay closeTime;

  const StoreTimeRange({
    required this.openTime,
    required this.closeTime,
  });
}