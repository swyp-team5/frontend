import 'package:chack_chack/common/notification/NotificationPage.dart';
import 'package:chack_chack/employee/home/schedule/ESubmitSchedulePage.dart';
import 'package:chack_chack/employee/home/widgets/ECheckInCard.dart';
import 'package:chack_chack/employee/home/widgets/EHomeCalendar.dart';
import 'package:chack_chack/employee/home/widgets/EHomeHeader.dart';
import 'package:chack_chack/employee/home/widgets/ENoticeBanner.dart';
import 'package:chack_chack/employee/home/widgets/EScheduleCard.dart';
import 'package:chack_chack/employee/mypage/EMyPage.dart';
import 'package:chack_chack/employee/schedule/EMainSchedulePage.dart';
import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

import '../../common/widgets/BottomNavBar.dart';
import '../crews/ECrewPage.dart';
import 'notification/ENotificationPage.dart';

class EHomePage extends StatefulWidget {
  const EHomePage({super.key});

  @override
  State<EHomePage> createState() => _EHomePageState();
}

class _EHomePageState extends State<EHomePage> {

  DateTime focusedDay = DateTime.now();
  DateTime? selectedDay;

  final DateTime deadline = DateTime(2026, 6, 5);
  late final int daysLeft =
  deadline.difference(DateTime.now()).inDays.clamp(0, 999);

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F7),

      /// 공통 BottomNavBar 적용
      bottomNavigationBar: BottomNavBar(
        currentIndex: 0,
        onTap: (index) {
          if (index == 0) {
            Navigator.push(context,
                MaterialPageRoute(builder: (_) => const EHomePage()));
          } else if (index == 1) {
            Navigator.push(context,
                MaterialPageRoute(builder: (_) => const ECrewPage()));
          } else if (index == 2) {
            Navigator.push(context,
                MaterialPageRoute(builder: (_) => const EMainSchedulePage()));
          } else if (index == 4) {
            Navigator.push(
                context, MaterialPageRoute(builder: (_) => const EMyPage()));
          }
        },
      ),

      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(
            horizontal: 20, vertical: 30,),

          child: Column(
            children: [

              /// 상단 헤더
              EHomeHeader(),

              const SizedBox(height: 20),

              /// 공지 배너
              ENoticeBanner(),

              const SizedBox(height: 16),

              /// 스케줄 제출 카드
              EScheduleCard(
                daysLeft: daysLeft,
              ),

              const SizedBox(height: 14),

              /// 출근 카드
              ECheckInCard(),

              const SizedBox(height: 14),

              /// 캘린더
              EHomeCalendar(
                focusedDay: focusedDay,
                selectedDay: selectedDay,
                onDaySelected: (selected, focused) {
                  setState(() {
                    selectedDay = selected;
                    focusedDay = focused;
                  });
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}