import 'package:chack_chack/employer/home/schedule/RMakingSchedulePage.dart';
import 'package:chack_chack/employer/home/schedule/RRecentSchedulePage.dart';
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
import 'notification/RNotificationPage.dart';

class RHomePage extends StatefulWidget {
  const RHomePage({super.key});

  @override
  State<RHomePage> createState() => _RHomePageState();
}

class _RHomePageState extends State<RHomePage> {

  void _showScheduleBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
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
                /// 상단 작은 막대 (Drag Handle)
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

                /// 제목 + 설명 (가운데 정렬)
                const Center(
                  child: Column(
                    children: [
                      Text(
                        "최근 기록 불러오기",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        "최근에 작성했던 스케줄 상세 내용을\n불러올 수 있어요",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 15,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
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
                        fontWeight: FontWeight.bold,
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
                        fontWeight: FontWeight.w600,
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

      /// 공통 BottomNavBar 적용
      bottomNavigationBar: BottomNavBar(
        currentIndex: 0,
        onTap: (index) {
          if (index == 0) {
            Navigator.push(context,
                MaterialPageRoute(builder: (_) => const RHomePage()));
          } else if (index == 1) {
            Navigator.push(context,
                MaterialPageRoute(builder: (_) => const RCrewPage()));
          } else if (index == 2) {
            Navigator.push(context,
                MaterialPageRoute(builder: (_) => const RMainSchedulePage()));
          } else if (index == 4) {
            Navigator.push(
                context, MaterialPageRoute(builder: (_) => const RMyPage()));
          }
        },
      ),

      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 30),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// ---------------- Header ----------------
              RHomeHeader(
                storeName: "매장명",
                onStoreTap: () {
                  // TODO : 매장 선택
                },
                onNotificationTap: () {
                  // TODO : 알림 페이지 이동
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const RNotificationPage(),
                    ),
                  );
                },
              ),

              const SizedBox(height: 14),

              /// ---------------- 공지 ----------------
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

              /// ---------------- 메인 카드 ----------------
              RScheduleCard(
                onMakeScheduleTap: () {
                  _showScheduleBottomSheet(context);
                },
              ),

              const SizedBox(height: 14),

              /// ---------------- 공지 작성 ----------------
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

              /// ---------------- 오늘 근무 ----------------
              RTodayWorkCard(
                onDetailTap: () {
                  // TODO : 오늘 근무 상세 페이지 이동
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}