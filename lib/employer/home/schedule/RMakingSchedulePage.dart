import 'package:flutter/material.dart';
import 'TimeInputBottomSheet.dart';

class RMakingSchedulePage extends StatefulWidget {
  const RMakingSchedulePage({super.key});

  @override
  State<RMakingSchedulePage> createState() => _RMakingSchedulePageState();
}

class _RMakingSchedulePageState extends State<RMakingSchedulePage> {
  TimeOfDay openTime = const TimeOfDay(hour: 0, minute: 0);
  TimeOfDay closeTime = const TimeOfDay(hour: 0, minute: 0);

  int minWork = 1;
  int maxWork = 1;

  final List<String> days = ["월", "화", "수", "목", "금", "토", "일"];
  final Set<String> selectedDays = {};

  String _format(TimeOfDay time) {
    return "${time.hour.toString().padLeft(2, "0")}:${time.minute.toString().padLeft(2, "0")}";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF7F7F7),

      appBar: AppBar(
        backgroundColor: const Color(0xffF7F7F7),
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "스케줄 만들기",
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              // TODO: 불러오기
            },
            child: const Text(
              "불러오기",
              style: TextStyle(
                color: Color(0xff2F80FF),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),

      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
          child: SizedBox(
            height: 56,
            child: ElevatedButton(
              onPressed: () {
                // TODO: 스케줄 만들기
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xff78B6F8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                elevation: 0,
              ),
              child: const Text(
                "스케줄 만들기",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 17,
                ),
              ),
            ),
          ),
        ),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 12),

            const Text(
              "매장 운영 시간",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 20),

            Row(
              children: [
                Expanded(
                  child: _timeBox(
                    title: "오픈 시간",
                    value: _format(openTime),
                    onTap: () async {
                      final result = await TimeInputBottomSheet.show(
                        context,
                        initialTime: openTime,
                      );

                      if (result != null) {
                        setState(() {
                          openTime = result;
                        });
                      }
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _timeBox(
                    title: "마감 시간",
                    value: _format(closeTime),
                    onTap: () async {
                      final result = await TimeInputBottomSheet.show(
                        context,
                        initialTime: closeTime,
                      );

                      if (result != null) {
                        setState(() {
                          closeTime = result;
                        });
                      }
                    },
                  ),
                ),
              ],
            ),

            const SizedBox(height: 28),
            const Divider(),
            const SizedBox(height: 28),

            const Text(
              "인원당 근무 횟수",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 20),

            Row(
              children: [
                Expanded(
                  child: _counterBox(
                    title: "최소",
                    value: minWork,
                    onMinus: () {
                      if (minWork > 0) {
                        setState(() => minWork--);
                      }
                    },
                    onPlus: () {
                      setState(() => minWork++);
                    },
                  ),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: _counterBox(
                    title: "최대",
                    value: maxWork,
                    onMinus: () {
                      if (maxWork > 0) {
                        setState(() => maxWork--);
                      }
                    },
                    onPlus: () {
                      setState(() => maxWork++);
                    },
                  ),
                ),
              ],
            ),

            const SizedBox(height: 28),
            const Divider(),
            const SizedBox(height: 28),

            const Text(
              "요일 선택",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 20),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: days.map((day) {
                final selected = selectedDays.contains(day);

                return GestureDetector(
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
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: selected
                          ? const Color(0xff2F80FF)
                          : const Color(0xffECECF1),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Center(
                      child: Text(
                        day,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color:
                          selected ? Colors.white : Colors.grey.shade700,
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _timeBox({
    required String title,
    required String value,
    required VoidCallback onTap,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(color: Colors.grey.shade700),
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: onTap,
          child: Container(
            height: 58,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: const Color(0xffECECF1),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              children: [
                Text(
                  value,
                  style: const TextStyle(fontSize: 16),
                ),
                const Spacer(),
                const Icon(Icons.access_time, color: Colors.grey),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _counterBox({
    required String title,
    required int value,
    required VoidCallback onMinus,
    required VoidCallback onPlus,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title),
        const SizedBox(height: 8),
        Container(
          height: 44,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              Expanded(
                child: IconButton(
                  onPressed: onMinus,
                  icon: const Icon(Icons.remove),
                ),
              ),
              Container(width: 1, color: Colors.grey.shade300),
              Expanded(
                child: Center(
                  child: Text(
                    "$value",
                    style: const TextStyle(fontSize: 18),
                  ),
                ),
              ),
              Container(width: 1, color: Colors.grey.shade300),
              Expanded(
                child: IconButton(
                  onPressed: onPlus,
                  icon: const Icon(Icons.add),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}