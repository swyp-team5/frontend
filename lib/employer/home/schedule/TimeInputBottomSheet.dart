import 'package:flutter/material.dart';

class TimeInputBottomSheet extends StatefulWidget {
  const TimeInputBottomSheet({
    super.key,
    this.initialTime,
  });

  final TimeOfDay? initialTime;

  static Future<TimeOfDay?> show(
      BuildContext context, {
        TimeOfDay? initialTime,
      }) {
    return showModalBottomSheet<TimeOfDay>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(28),
        ),
      ),
      builder: (_) => TimeInputBottomSheet(
        initialTime: initialTime,
      ),
    );
  }

  @override
  State<TimeInputBottomSheet> createState() =>
      _TimeInputBottomSheetState();
}

class _TimeInputBottomSheetState
    extends State<TimeInputBottomSheet> {
  late List<String> digits;

  /// 0=시10자리,1=시1자리,2=분10자리,3=분1자리
  int selectedIndex = 0;

  @override
  void initState() {
    super.initState();

    final hour =
    (widget.initialTime?.hour ?? 0).toString().padLeft(2, "0");
    final minute =
    (widget.initialTime?.minute ?? 0).toString().padLeft(2, "0");

    digits = [
      hour[0],
      hour[1],
      minute[0],
      minute[1],
    ];
  }

  bool get canSave {
    final h = int.parse("${digits[0]}${digits[1]}");
    final m = int.parse("${digits[2]}${digits[3]}");

    return !(h == 0 && m == 0);
  }

  int get hour =>
      int.parse("${digits[0]}${digits[1]}");

  int get minute =>
      int.parse("${digits[2]}${digits[3]}");

  void input(String value) {
    setState(() {
      digits[selectedIndex] = value;

      if (selectedIndex < 3) {
        selectedIndex++;
      }
    });
  }

  void backspace() {
    setState(() {
      digits[selectedIndex] = "0";

      if (selectedIndex > 0) {
        selectedIndex--;
      }
    });
  }

  Widget timeBox(int index) {
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedIndex = index;
        });
      },
      child: Container(
        width: 54,
        height: 46,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: const Color(0xffF2F2F5),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: selectedIndex == index
                ? const Color(0xff1E88FF)
                : Colors.transparent,
            width: 2,
          ),
        ),
        child: Text(
          digits[index],
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
                      Navigator.pop(context);
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
              mainAxisAlignment:
              MainAxisAlignment.center,
              children: [
                timeBox(0),
                const SizedBox(width: 6),
                timeBox(1),
                const Padding(
                  padding:
                  EdgeInsets.symmetric(horizontal: 8),
                  child: Text(
                    ":",
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                timeBox(2),
                const SizedBox(width: 6),
                timeBox(3),
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
                    TimeOfDay(
                      hour: hour,
                      minute: minute,
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