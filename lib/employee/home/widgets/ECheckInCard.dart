import 'package:flutter/material.dart';

class ECheckInCard extends StatefulWidget {
  const ECheckInCard({super.key});

  @override
  State<ECheckInCard> createState() => _ECheckInCardState();
}

class _ECheckInCardState extends State<ECheckInCard> {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: 20,
        vertical: 16,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          const Expanded(
            child: Text(
              '출퇴근 기록',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          ),
          SizedBox(
            width: 170,
            height: 45,
            child: ElevatedButton(
              onPressed: () {
                // TODO: 출근하기 동작
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFEEEBFF),
                foregroundColor: const Color(0xFF7D67FD),
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                '출근하기',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}