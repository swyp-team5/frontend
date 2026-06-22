import 'package:chack_chack/common/notification/NotificationPage.dart';
import 'package:chack_chack/employee/mypage/EMyPage.dart';
import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

import '../../common/widgets/BottomNavBar.dart';
import '../../employer/crews/RCrewPage.dart';
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
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,

                children: [

                  Row(
                    children: [

                      const Text('매장명',
                        style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                      ),

                      const SizedBox(width: 4,),

                      const Icon(
                        Icons.keyboard_arrow_down,
                        size: 24,
                      ),
                    ],
                  ),

                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: const Row(
                          children: [
                            CircleAvatar(
                              radius: 3,
                              backgroundColor: Color(0xFF9E9E9E),
                            ),
                            SizedBox(width: 6),
                            Text(
                              "출근전",
                              style: TextStyle(
                                color: Color(0xFF8A8A8A),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 10),
                      const Icon(Icons.notifications_none, size: 28),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 20),

              /// 공지 배너
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Row(
                  children: [
                    const SizedBox(width: 10),
                    const Text(
                      "공지 \t 📌",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: TextButton(
                        onPressed: () {
                          Navigator.push(context,
                              MaterialPageRoute(builder: (_) => const ENotificationPage()));
                        },
                        child: const Text(
                          "마감 때 쓰레기 비우는거 잊지 마세요",
                          style: TextStyle(
                            fontSize: 14,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),

                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              /// 스케줄 제출 카드
              SizedBox(
                width: double.infinity,
                child: AspectRatio(
                  aspectRatio: 1059 / 414, // 업로드한 이미지 비율
                  child: Stack(
                    children: [
                      /// 배경 이미지
                      Positioned.fill(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: Image.asset(
                            "assets/images/e_main_card.png",
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),

                      /// 하단 버튼
                      Positioned(
                        left: 20,
                        bottom: 18,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // 마감까지 n일 칩
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFFBFE1FF),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                "마감까지 ${daysLeft}일",
                                style: const TextStyle(
                                  color: Color(0xFF0084FF),
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),

                            const SizedBox(height: 18),

                            // 자세히 보기
                            Padding(
                              padding: const EdgeInsets.only(left: 5), // 칩 텍스트 시작 위치와 맞춤
                              child: InkWell(
                                onTap: () {
                                  // TODO: 자세히 보기 페이지 이동
                                },
                                child: const Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      "자세히 보기",
                                      style: TextStyle(
                                        color: Color(0xFF004A8F),
                                        fontSize: 14,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                    SizedBox(width: 2),
                                    Icon(
                                      Icons.chevron_right,
                                      size: 18,
                                      color: Color(0xFF004A8F),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 14),

              /// 출근 카드
              _buildCheckInCard(),

              const SizedBox(height: 14),

              /// 캘린더
              Container(
                padding: const EdgeInsets.all(16),

                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                ),

                child: TableCalendar(
                  locale: 'ko_KR', // 한국어 적용

                  firstDay: DateTime.utc(2020, 1, 1),

                  lastDay: DateTime.utc(2035, 12, 31),

                  focusedDay: focusedDay,

                  weekendDays: const [DateTime.sunday], // 일요일을 주말로 설정

                  selectedDayPredicate:
                      (day) => isSameDay(selectedDay, day,),

                  onDaySelected: (selected, focused) {

                    setState(() {
                      selectedDay = selected;

                      focusedDay = focused;
                    });
                  },

                  headerStyle:
                  const HeaderStyle(
                    formatButtonVisible: false,

                    titleCentered: true,

                    titleTextStyle: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  daysOfWeekStyle: const DaysOfWeekStyle(
                    // 일요일 요일 텍스트 빨간색
                    weekendStyle: TextStyle(color: Colors.red),
                  ),

                  calendarStyle: const CalendarStyle(

                    // 일요일 날짜 텍스트 빨간색
                    weekendTextStyle: TextStyle(color: Colors.red),

                    // 오늘 날짜 데코레이션
                    todayDecoration: BoxDecoration(
                      color: Color(0xFF9FA8DA),
                      shape: BoxShape.circle,
                    ),

                    // 선택된 날짜 데코레이션
                    selectedDecoration: BoxDecoration(
                      color: Colors.black,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCheckInCard() {
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