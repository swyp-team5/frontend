import 'package:flutter/material.dart';
import 'package:chack_chack/employer/schedule/RMainSchedulePage.dart';

import '../../employer/home/schedule/RSelectSchedulePage.dart';

class RAutoSchedulingPage extends StatefulWidget {
  const RAutoSchedulingPage({super.key});

  @override
  State<RAutoSchedulingPage> createState() => _RAutoSchedulingPageState();
}

class _RAutoSchedulingPageState extends State<RAutoSchedulingPage> {

  @override
  void initState() {
    super.initState();

    Future.delayed(const Duration(seconds: 3), () {
      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => const RSelectSchedulePage(),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                /// 스케줄 이미지
                Image.asset(
                  "assets/images/automatic_schedule_creation.png",
                  width: 200,
                  height: 200,
                  fit: BoxFit.contain,
                ),

                const Text(
                  "근무자들의 스케줄을 취합해",
                  style: TextStyle(
                    color: Color(0xFF0084FF),
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),

                const SizedBox(height: 20),

                const Text(
                  "자동으로 스케줄을\n만들고 있어요",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 24,
                    height: 1.4,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}