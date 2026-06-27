import 'package:chack_chack/employer/home/notification/RNotificationPage.dart';
import 'package:chack_chack/employer/home/schedule/RMakingSchedulePage.dart';
import 'package:chack_chack/employer/home/schedule/RRecentSchedulePage.dart';
import 'package:chack_chack/employer/home/widgets/RAutoScheduleBottomSheet.dart';
import 'package:chack_chack/employer/home/widgets/RHomeHeader.dart';
import 'package:chack_chack/employer/home/widgets/RNoticeBanner.dart';
import 'package:chack_chack/employer/home/widgets/RNoticeWriteCard.dart';
import 'package:chack_chack/employer/home/widgets/RScheduleCard.dart';
import 'package:chack_chack/employer/home/widgets/RTodayWorkCard.dart';
import 'package:flutter/material.dart';

import '../../../common/widgets/BottomNavBar.dart';
import '../crews/RCrewPage.dart';
import '../mypage/RMyPage.dart';
import '../schedule/RMainSchedulePage.dart';

enum HomeCardType {
  none,

  /// 스케줄
  weeklySchedule,
  scheduleCreationAvailable,
  submissionStatus,
}

class RHomePage extends StatefulWidget {
  const RHomePage({super.key});

  @override
  State<RHomePage> createState() => _RHomePageState();
}

class _RHomePageState extends State<RHomePage> {
  bool isCardVisible = true;

  /// 카드에서 사용할 남은 일수
  int get daysLeft {
    final now = DateTime.now();
    return 8 - now.weekday;
  }

  //==========================================================
  // 개발용
  //==========================================================

  // static const HomeCardType? debugCardType =
  //     HomeCardType.weeklySchedule;

  static const HomeCardType? debugCardType =
      HomeCardType.scheduleCreationAvailable;

  // static const HomeCardType? debugCardType =
  //     HomeCardType.submissionStatus;

  // static const HomeCardType? debugCardType =
  //     HomeCardType.none;

  // static const HomeCardType? debugCardType = null;

  //==========================================================
  // 실제 카드 타입
  //==========================================================

  HomeCardType get cardType {
    if (debugCardType != null) {
      return debugCardType!;
    }

    /// TODO : API 연결

    return HomeCardType.none;
  }

  void _showScheduleBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) {
        return SafeArea(
          child: Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Center(
                  child: Container(
                    width: 48,
                    height: 5,
                    decoration: BoxDecoration(
                      color: const Color(0xFFD9D9D9),
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                const Column(
                  children: [
                    Text(
                      "최근 기록 불러오기",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      "최근에 작성했던 스케줄 상세 내용을\n불러올 수 있어요",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF767676),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 32),

                /// 불러오기 버튼
                SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const RRecentSchedulePage(),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0084FF),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: const Text(
                      "불러오기",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                /// 직접 만들기 버튼
                SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: OutlinedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const RMakingSchedulePage(),
                        ),
                      );
                    },
                    style: OutlinedButton.styleFrom(
                      backgroundColor: Colors.white,
                      side: const BorderSide(
                        color: Color(0xFFE0E0E0),
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: const Text(
                      "직접 만들기",
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
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
                builder: (_) => const RCrewPage(),
              ),
            );
          } else if (index == 2) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const RMainSchedulePage(),
              ),
            );
          } else if (index == 4) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const RMyPage(),
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
              RHomeHeader(
                storeName: "매장명",
                onStoreTap: () {},
                onNotificationTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const RNotificationPage(),
                    ),
                  );
                },
              ),

              const SizedBox(height: 20),

              /// Notice
              RNoticeBanner(
                notice: "마감 때 쓰레기 비우는거 잊지 마세요",
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const RNotificationPage(),
                    ),
                  );
                },
              ),

              const SizedBox(height: 16),

              /// Schedule Card
              if (cardType != HomeCardType.none && isCardVisible)
                RScheduleCard(
                  type: cardType,
                  daysLeft: daysLeft,
                  onClose: () {
                    setState(() {
                      isCardVisible = false;
                    });
                  },
                  onMakeScheduleTap: () {
                    switch (cardType) {
                    /// 제출 기간 (최근 기록 불러오기 BottomSheet)
                      case HomeCardType.weeklySchedule:
                        _showScheduleBottomSheet(context);
                        break;

                    /// 제출 완료 → 자동 스케줄 안내 BottomSheet
                      case HomeCardType.scheduleCreationAvailable:
                        showModalBottomSheet(
                          context: context,
                          isScrollControlled: true,
                          backgroundColor: Colors.transparent,
                          builder: (_) => RAutoScheduleBottomSheet(
                            onNext: () {
                              // 자동 스케줄 생성 페이지로 이동
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const RMakingSchedulePage(),
                                ),
                              );
                            },
                          ),
                        );
                        break;

                    /// 제출 현황
                      case HomeCardType.submissionStatus:
                      // TODO : 제출 현황 페이지 이동
                        break;

                      case HomeCardType.none:
                        break;
                    }
                  },
                ),

              const SizedBox(height: 14),

              /// Notice Write
              RNoticeWriteCard(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const RNotificationPage(),
                    ),
                  );
                },
              ),

              const SizedBox(height: 14),

              /// Today Work
              RTodayWorkCard(
                onDetailTap: () {},
              ),
            ],
          ),
        ),
      ),
    );
  }
}