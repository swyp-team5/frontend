import 'package:chack_chack/employee/mypage/EMyPage.dart';
import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

import '../../common/widgets/BottomNavBar.dart';
import '../../employer/crews/RCrewPage.dart';

class EHomePage extends StatefulWidget {
  const EHomePage({super.key});

  @override
  State<EHomePage> createState() =>
      _EHomePageState();
}

class _EHomePageState
    extends State<EHomePage> {

  DateTime focusedDay = DateTime.now();
  DateTime? selectedDay;

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor:
      const Color(0xFFF5F5F5),

      /// 공통 BottomNavBar 적용
      bottomNavigationBar:
      BottomNavBar(
        currentIndex: 0,

        onTap: (index) {

          /// 홈
          if (index == 0) {}

          /// 동료
          else if (index == 1) {

            Navigator.push(
              context,

              MaterialPageRoute(
                builder: (_) =>
                const RCrewPage(),
              ),
            );
          }

          /// 스케줄
          else if (index == 2) {

            Navigator.push(
              context,

              MaterialPageRoute(
                builder: (_) =>
                const EHomePage(),
              ),
            );
          }

          /// 급여
          else if (index == 3) {}

          /// 마이페이지
          else if (index == 4) {

            Navigator.push(
              context,

              MaterialPageRoute(
                builder: (_) =>
                const EMyPage(),
              ),
            );
          }
        },
      ),

      body: SafeArea(
        child: SingleChildScrollView(
          padding:
          const EdgeInsets.symmetric(
            horizontal: 25,
            vertical: 35,
          ),

          child: Column(
            children: [

              /// 상단 헤더
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,

                children: [

                  Row(
                    children: [

                      const Text('매장명', style: TextStyle(
                        fontSize: 25,
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

                  IconButton(
                    onPressed: () {},

                    icon: const Icon(
                      Icons.notifications_none,
                      size: 35,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              /// 공지 배너
              Container(
                width: double.infinity,

                padding:
                const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 12,
                ),

                decoration: BoxDecoration(
                  color:
                  const Color(
                    0xFFE8E8ED,
                  ),

                  borderRadius:
                  BorderRadius.circular(
                    10,
                  ),
                ),

                child: Row(
                  children: [

                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),

                      child: const Text(
                        '공지',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),

                    const SizedBox(width: 10),

                    const Expanded(
                      child: Text(
                        '마감 때 쓰레기 비우는거 잊지 마세요',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 14),

              /// 스케줄 제출 카드
              _buildScheduleCard(),

              const SizedBox(height: 14),

              /// 출근 카드
              _buildCheckInCard(),

              const SizedBox(height: 14),

              /// 캘린더
              Container(
                padding:
                const EdgeInsets.all(16),

                decoration: BoxDecoration(
                  color: const Color(0xFFE8E8ED,),

                  borderRadius:
                  BorderRadius.circular(18),
                ),

                child:
                TableCalendar(
                  locale: 'ko_KR', // 한국어 적용

                  firstDay:
                  DateTime.utc(2020, 1, 1),

                  lastDay:
                  DateTime.utc(2035, 12, 31),

                  focusedDay: focusedDay,

                  weekendDays: const [DateTime.sunday], // 일요일을 주말로 설정

                  selectedDayPredicate:
                      (day) =>
                      isSameDay(
                        selectedDay,
                        day,
                      ),

                  onDaySelected:
                      (selected, focused) {

                    setState(() {

                      selectedDay =
                          selected;

                      focusedDay =
                          focused;
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

              const SizedBox(height: 14),

              /// 공지
              _buildMenuSection(
                title: '공지',
              ),

              const SizedBox(height: 14),

              /// 이번달 근무
              Container(
                width: double.infinity,
                padding:
                const EdgeInsets.all(20),

                decoration: BoxDecoration(
                  color: const Color(0xFFE8E8ED,),

                  borderRadius:
                  BorderRadius.circular(18),
                ),

                child: Column(
                  children: [

                    Row(
                      children: [

                        const Text('이번달 근무', style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        const Spacer(),

                        Icon(Icons.chevron_right,),
                      ],
                    ),

                    const SizedBox(height: 50),

                    Text(
                      '이번달 근무 현황이 없어요.',

                      style: TextStyle(
                        color:
                        Colors.grey.shade500,

                        fontSize: 18,
                      ),
                    ),

                    const SizedBox(height: 40),

                    const Row(
                      mainAxisAlignment:
                      MainAxisAlignment.center,

                      children: [

                        Text(
                          '자세히보기', style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        SizedBox(width: 4),

                        Icon(
                          Icons.chevron_right,
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 14),

              /// 교대 근무 신청
              _buildMenuSection(
                title: '교대 근무 신청',
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildScheduleCard() {

    return Container(
      width: double.infinity,
      padding:
      const EdgeInsets.all(24),

      decoration: BoxDecoration(
        color: const Color(0xFFE8E8ED,),

        borderRadius:
        BorderRadius.circular(18),
      ),

      child: Column(
        children: [

          const Icon(
            Icons.calendar_month_outlined,
            size: 56,
          ),

          const SizedBox(height: 20),

          const Text(
            '사장님의 매장 크루에 참여하고 근무 시간을 입력해\n자동스케줄을 만들어보세요!',

            textAlign:
            TextAlign.center,

            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),

          const SizedBox(height: 20),

          SizedBox(
            width: double.infinity,
            height: 52,

            child: ElevatedButton(
              onPressed: () {},

              style:
              ElevatedButton.styleFrom(
                backgroundColor:
                Colors.black,

                shape:
                RoundedRectangleBorder(
                  borderRadius:
                  BorderRadius.circular(
                    30,
                  ),
                ),
              ),

              child: const Text(
                '스케줄 제출하기',

                style: TextStyle(
                  color: Colors.white,
                  fontWeight:
                  FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCheckInCard() {

    return Container(
      width: double.infinity,
      padding:
      const EdgeInsets.all(24),

      decoration: BoxDecoration(
        color: const Color(0xFFE8E8ED,),

        borderRadius:
        BorderRadius.circular(18),
      ),

      child: Column(
        children: [

          const Text(
            '출근 후 출근하기를 누르면 자동으로\n출근에 반영이 돼요!',

            textAlign:
            TextAlign.center,

            style: TextStyle(
              fontSize: 18,
              fontWeight:
              FontWeight.w700,
            ),
          ),

          const SizedBox(height: 20),

          SizedBox(
            width: double.infinity,
            height: 52,

            child: ElevatedButton(
              onPressed: () {},

              style:
              ElevatedButton.styleFrom(
                backgroundColor:
                Colors.green,

                shape:
                RoundedRectangleBorder(
                  borderRadius:
                  BorderRadius.circular(
                    10,
                  ),
                ),
              ),

              child: const Text(
                '출근하기',

                style: TextStyle(
                  color: Colors.white,
                  fontWeight:
                  FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuSection({
    required String title,
  }) {

    return Container(
      width: double.infinity,
      padding:
      const EdgeInsets.symmetric(
        horizontal: 20,
        vertical: 20,
      ),

      decoration: BoxDecoration(
        color: const Color(0xFFE8E8ED,),

        borderRadius:
        BorderRadius.circular(18),
      ),

      child: Row(
        children: [

          Text(
            title,

            style: const TextStyle(
              fontSize: 18,
              fontWeight:
              FontWeight.bold,
            ),
          ),

          const Spacer(),

          const Icon(
            Icons.chevron_right,
          ),
        ],
      ),
    );
  }
}