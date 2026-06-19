import 'package:flutter/material.dart';

class TimeInputBottomSheet extends StatefulWidget {
  const TimeInputBottomSheet({
    super.key,
    this.initialTime,
  });

  final TimeOfDay? initialTime;

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
      builder: (_) => TimeInputBottomSheet(
        // 필요하면 initial 값 전달
      ),
    );
  }

  @override
  State<TimeInputBottomSheet> createState() =>
      _TimeInputBottomSheetState();
}

class _TimeInputBottomSheetState extends State<TimeInputBottomSheet> {
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

    if (widget.initialTime != null) {
      openHour = widget.initialTime!.hour.toString().padLeft(2, "0");
      openMinute = widget.initialTime!.minute.toString().padLeft(2, "0");
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
                    "매장 운영 시간",
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
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
              "운영 시간이 요일별로 상이한 경우\n가장 빠른 오픈 시간과 가장 늦은 마감 시간을 적어주세요",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey,
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