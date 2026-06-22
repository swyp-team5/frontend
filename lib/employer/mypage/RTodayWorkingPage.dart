import 'package:flutter/material.dart';

class RTodayWorkingPage extends StatelessWidget {
  const RTodayWorkingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            /// 상단 헤더
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 20, vertical: 30,
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: const Icon(
                        Icons.arrow_back_ios_new,
                        size: 22,
                        color: Colors.black,
                      ),
                    ),
                  ),
                  const Center(
                    child: Text(
                      "오늘 근무",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: const [
                  _WorkingSection(
                    label: "오픈",
                    labelColor: Color(0xFFE6F3FF),
                    textColor: Color(0xFF0084FF),
                    time: "07:00 - 12:00",
                    members: [
                      "이수봉",
                      "모수연",
                    ],
                  ),

                  Divider(
                    height: 1,
                    color: Color(0xFFF1F1F5),
                  ),

                  _WorkingSection(
                    label: "미들",
                    labelColor: Color(0xFFEEEBFF),
                    textColor: Color(0xFF7D67FD),
                    time: "12:00 - 19:00",
                    members: [
                      "이수봉",
                      "김다봉",
                      "모수연",
                    ],
                  ),

                  Divider(
                    height: 1,
                    color: Color(0xFFF1F1F5),
                  ),

                  _WorkingSection(
                    label: "마감",
                    labelColor: Color(0xFFD0F9D5),
                    textColor: Color(0xFF0FA48B),
                    time: "19:00 - 22:00",
                    members: [
                      "이수봉",
                      "모수연",
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _WorkingSection extends StatelessWidget {
  final String label;
  final Color labelColor;
  final Color textColor;
  final String time;
  final List<String> members;

  const _WorkingSection({
    required this.label,
    required this.labelColor,
    required this.textColor,
    required this.time,
    required this.members,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 20,
        vertical: 20,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// 근무 타입 + 시간
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: labelColor,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  label,
                  style: TextStyle(
                    color: textColor,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),

              const SizedBox(width: 10),

              Text(
                time,
                style: const TextStyle(
                  fontSize: 15,
                  color: Color(0xFF767676),
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          /// 근무자 목록
          ...members.map(
                (member) => Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16, vertical: 10
              ),
              child: Text(
                member,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Colors.black,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}