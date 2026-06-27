import 'package:flutter/material.dart';

class RTodayWorkCard extends StatelessWidget {
  final VoidCallback? onDetailTap;

  const RTodayWorkCard({
    super.key,
    this.onDetailTap,
  });

  /// TODO : API 연결 전 더미 데이터
  final List<Map<String, dynamic>> todayWorks = const [
    {
      "role": "오픈",
      "roleColor": Color(0xFFE6F3FF),
      "textColor": Color(0xFF0084FF),
      "time": "10:00 - 14:00",
      "employees": ["손흥민", "이수봉"],
    },
    {
      "role": "미들",
      "roleColor": Color(0xFFEEEBFF),
      "textColor": Color(0xFF7D67FD),
      "time": "14:00 - 16:00",
      "employees": ["모수연", "김다봉"],
    },
    {
      "role": "마감",
      "roleColor": Color(0xFFD0F9D5),
      "textColor": Color(0xFF0FA48B),
      "time": "16:00 - 20:00",
      "employees": ["김지연"],
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        children: [
          Row(
            children: const [
              Text(
                "오늘 근무",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),

          const SizedBox(height: 18),

          Column(
            children: List.generate(todayWorks.length, (index) {
              final work = todayWorks[index];

              return Column(
                children: [
                  _workRow(
                    role: work["role"],
                    roleColor: work["roleColor"],
                    textColor: work["textColor"],
                    time: work["time"],
                    employee:
                    (work["employees"] as List<String>).join(", "),
                  ),

                  if (index != todayWorks.length - 1)
                    const Divider(
                      height: 40,
                      thickness: 1,
                      color: Color(0xFFF2F2F5),
                    ),
                ],
              );
            }),
          ),

          const SizedBox(height: 18),

          InkWell(
            onTap: onDetailTap,
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "자세히 보기",
                  style: TextStyle(
                    color: Colors.grey,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(width: 4),
                Icon(
                  Icons.chevron_right,
                  color: Colors.grey,
                  size: 18,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _workRow({
    required String role,
    required Color roleColor,
    required Color textColor,
    required String time,
    required String employee,
  }) {
    return Row(
      children: [
        Container(
          width: 52,
          alignment: Alignment.center,
          padding: const EdgeInsets.symmetric(
            vertical: 6,
          ),
          decoration: BoxDecoration(
            color: roleColor,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            role,
            style: TextStyle(
              color: textColor,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),

        const SizedBox(width: 12),

        SizedBox(
          width: 95,
          child: Text(
            time,
            style: const TextStyle(
              fontWeight: FontWeight.w500,
            ),
          ),
        ),

        Expanded(
          child: Text(
            employee,
            textAlign: TextAlign.end,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}