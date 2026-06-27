import 'package:chack_chack/employee/home/widgets/ECheckInCard.dart';
import 'package:chack_chack/employee/home/widgets/EHomeCalendar.dart';
import 'package:chack_chack/employee/home/widgets/EHomeHeader.dart';
import 'package:chack_chack/employee/home/widgets/ENoticeBanner.dart';
import 'package:chack_chack/employee/home/widgets/EScheduleCard.dart';
import 'package:chack_chack/employee/mypage/EMyPage.dart';
import 'package:chack_chack/employee/schedule/EMainSchedulePage.dart';
import 'package:flutter/material.dart';

import '../../common/widgets/BottomNavBar.dart';
import '../crews/ECrewPage.dart';

enum HomeCardType {
  none,

  /// 스케줄
  weeklySchedule,
  scheduleCompleted,
  scheduleChanged,

  /// 요청
  shiftRequest,
  substituteRequest,
  ownerWorkRequest,
}

class EHomePage extends StatefulWidget {
  const EHomePage({super.key});

  @override
  State<EHomePage> createState() => _EHomePageState();
}

class _EHomePageState extends State<EHomePage> {
  DateTime focusedDay = DateTime.now();
  DateTime? selectedDay;
  bool isCardVisible = true;

  /// 월요일~일요일 기준 남은 일수
  int get daysLeft {
    final now = DateTime.now();
    return 8 - now.weekday;
  }

  //==========================================================
  // 개발용
  //==========================================================

  /// TODO-null이면 실제 로직 사용
  /// 매주 스케줄(다음주 스케 제출 요청)
  static const HomeCardType? debugCardType =
      HomeCardType.weeklySchedule;

  /// 스케줄 완성
  // static const HomeCardType? debugCardType =
  //     HomeCardType.scheduleCompleted;

  /// 스케줄 변경
  // static const HomeCardType? debugCardType =
  //     HomeCardType.scheduleChanged;

  /// 교대근무 요청
  // static const HomeCardType? debugCardType =
  //     HomeCardType.shiftRequest;

  /// 대타근무 요청
  // static const HomeCardType? debugCardType =
  //     HomeCardType.substituteRequest;

  /// 사장님 근무 요청
  // static const HomeCardType? debugCardType =
  //     HomeCardType.ownerWorkRequest;

  // static const HomeCardType? debugCardType =
  //     HomeCardType.none;

  // static const HomeCardType? debugCardType = null;

  //==========================================================
  // 실제 사용할 카드 타입
  //==========================================================

  HomeCardType get cardType {
    /// 개발 중에는 여기서 강제
    if (debugCardType != null) {
      return debugCardType!;
    }

    //==================================================
    // TODO : API 연결 후 실제 로직
    //==================================================

    /*
    if (scheduleCompleted) {
      return HomeCardType.scheduleCompleted;
    }

    if (scheduleChanged) {
      return HomeCardType.scheduleChanged;
    }

    if (shiftRequested) {
      return HomeCardType.shiftRequest;
    }

    if (substituteRequested) {
      return HomeCardType.substituteRequest;
    }

    if (ownerRequested) {
      return HomeCardType.ownerWorkRequest;
    }

    if (weeklyScheduleOpened) {
      return HomeCardType.weeklySchedule;
    }
    */

    return HomeCardType.none;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F7),

      bottomNavigationBar: BottomNavBar(
        currentIndex: 0,
        onTap: (index) {
          if (index == 1) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const ECrewPage(),
              ),
            );
          } else if (index == 2) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const EMainSchedulePage(),
              ),
            );
          } else if (index == 4) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const EMyPage(),
              ),
            );
          }
        },
      ),

      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 30,
          ),
          child: Column(
            children: [
              /// Header
              const EHomeHeader(),

              const SizedBox(height: 20),

              /// Notice
              const ENoticeBanner(),

              const SizedBox(height: 16),

              /// Schedule Card
              if (cardType != HomeCardType.none && isCardVisible)
                EScheduleCard(
                  type: cardType,
                  daysLeft: daysLeft,
                  onClose: () {
                    setState(() {
                      isCardVisible = false;
                    });
                  },
                ),

              const SizedBox(height: 14),

              /// CheckIn Card
              const ECheckInCard(),

              const SizedBox(height: 14),

              /// Calendar
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




// import 'package:chack_chack/common/notification/NotificationPage.dart';
// import 'package:chack_chack/employee/home/schedule/ESubmitSchedulePage.dart';
// import 'package:chack_chack/employee/home/widgets/ECheckInCard.dart';
// import 'package:chack_chack/employee/home/widgets/EHomeCalendar.dart';
// import 'package:chack_chack/employee/home/widgets/EHomeHeader.dart';
// import 'package:chack_chack/employee/home/widgets/ENoticeBanner.dart';
// import 'package:chack_chack/employee/home/widgets/EScheduleCard.dart';
// import 'package:chack_chack/employee/mypage/EMyPage.dart';
// import 'package:chack_chack/employee/schedule/EMainSchedulePage.dart';
// import 'package:flutter/material.dart';
// import 'package:table_calendar/table_calendar.dart';
//
// import '../../common/widgets/BottomNavBar.dart';
// import '../crews/ECrewPage.dart';
// import 'notification/ENotificationPage.dart';
//
// enum HomeCardType {
//   none,
//
//   /// 스케줄
//   weeklySchedule,     // 다음주 스케줄 제출
//   scheduleCompleted,  // 스케줄 완성
//   scheduleChanged,    // 스케줄 변경
//
//   /// 요청
//   shiftRequest,       // 교대 요청
//   substituteRequest,  // 대타 요청
//   ownerWorkRequest,   // 사장님 근무 요청
// }
//
// class EHomePage extends StatefulWidget {
//   final bool showScheduleCard;
//
//   const EHomePage({
//     super.key,
//     this.showScheduleCard = true,
//   });
//
//   @override
//   State<EHomePage> createState() => _EHomePageState();
// }
//
// class _EHomePageState extends State<EHomePage> {
//
//   HomeCardType cardType = HomeCardType.none;
//
//   DateTime focusedDay = DateTime.now();
//   DateTime? selectedDay;
//
//   int get daysLeft {
//     final now = DateTime.now();
//
//     // 월=1, 화=2 ... 일=7
//     return 8 - now.weekday;
//   }
//
//   bool isScheduleSubmitted = false;
//
//   @override
//   Widget build(BuildContext context) {
//
//     return Scaffold(
//       backgroundColor: const Color(0xFFF5F5F7),
//
//       /// 공통 BottomNavBar 적용
//       bottomNavigationBar: BottomNavBar(
//         currentIndex: 0,
//         onTap: (index) {
//           if (index == 0) {
//             Navigator.push(context,
//                 MaterialPageRoute(builder: (_) => const EHomePage()));
//           } else if (index == 1) {
//             Navigator.push(context,
//                 MaterialPageRoute(builder: (_) => const ECrewPage()));
//           } else if (index == 2) {
//             Navigator.push(context,
//                 MaterialPageRoute(builder: (_) => const EMainSchedulePage()));
//           } else if (index == 4) {
//             Navigator.push(
//                 context, MaterialPageRoute(builder: (_) => const EMyPage()));
//           }
//         },
//       ),
//
//       body: SafeArea(
//         child: SingleChildScrollView(
//           padding: const EdgeInsets.symmetric(
//             horizontal: 20, vertical: 30,),
//
//           child: Column(
//             children: [
//
//               /// 상단 헤더
//               EHomeHeader(),
//
//               const SizedBox(height: 20),
//
//               /// 공지 배너
//               ENoticeBanner(),
//
//               const SizedBox(height: 16),
//
//               /// 스케줄 제출 카드
//               EScheduleCard(
//                 daysLeft: daysLeft,
//                 type: cardType,
//               ),
//
//               const SizedBox(height: 14),
//
//               /// 출근 카드
//               ECheckInCard(),
//
//               const SizedBox(height: 14),
//
//               /// 캘린더
//               EHomeCalendar(
//                 focusedDay: focusedDay,
//                 selectedDay: selectedDay,
//                 onDaySelected: (selected, focused) {
//                   setState(() {
//                     selectedDay = selected;
//                     focusedDay = focused;
//                   });
//                 },
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }