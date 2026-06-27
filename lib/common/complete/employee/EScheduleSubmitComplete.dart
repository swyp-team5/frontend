import 'package:flutter/material.dart';

class EScheduleSubmitComplete extends StatelessWidget {
  final DateTime startDate;
  final DateTime endDate;

  const EScheduleSubmitComplete({
    super.key,
    required this.startDate,
    required this.endDate,
  });

  String _formatDate(DateTime date) {
    return "${date.month}/${date.day}";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              const Spacer(),

              /// 체크 아이콘
              Image.asset(
                "assets/images/check.png", // <- 체크 이미지
                width: 200,
                height: 200,
              ),

              /// 기간
              Text(
                "${_formatDate(startDate)} - ${_formatDate(endDate)}",
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF40A3FF),
                ),
              ),

              const SizedBox(height: 20),

              const Text(
                "스케줄 제출이 완료되었어요!",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
              ),

              const SizedBox(height: 14),

              const Text(
                "스케줄이 완성되면 알려드릴게요",
                style: TextStyle(
                  fontSize: 15,
                  color: Colors.black,
                  fontWeight: FontWeight.w500,
                ),
              ),

              const Spacer(),

              SizedBox(
                width: double.infinity,
                height: 58,
                child: ElevatedButton(
                  onPressed: () {

                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0084FF),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    "홈으로 가기",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}