import 'package:chack_chack/employer/crews/widgets/RInfoSectionCard.dart';
import 'package:chack_chack/employer/crews/widgets/RTagChip.dart';
import 'package:flutter/material.dart';

import '../../../common/widgets/BottomNavBar.dart';
import '../home/RHomePage.dart';
import '../mypage/RMyPage.dart';
import 'RCrewPage.dart';


class RCrewDetailPage extends StatefulWidget {

  const RCrewDetailPage({super.key});

  @override
  State<RCrewDetailPage> createState() =>
      _RCrewDetailPageState();
}

class _RCrewDetailPageState
    extends State<RCrewDetailPage> {

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor:
      const Color(0xFFF5F5F5),

      /// 공통 BottomNavBar 적용
      bottomNavigationBar:
      BottomNavBar(
        currentIndex: 1,

        onTap: (index) {

          /// 홈
          if (index == 0) {

            Navigator.push(
              context,

              MaterialPageRoute(
                builder: (_) =>
                const RHomePage(),
              ),
            );
          }

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
          else if (index == 2) {}

          /// 급여
          else if (index == 3) {}

          /// 마이페이지
          else if (index == 4) {

            Navigator.push(
              context,

              MaterialPageRoute(
                builder: (_) =>
                const RMyPage(),
              ),
            );
          }
        },
      ),

      body: SafeArea(
        child: SingleChildScrollView(

          child: Padding(
            padding:
            const EdgeInsets.symmetric(
              horizontal: 25,
              vertical: 35,
            ),

            child: Column(
              children: [

                /// 상단 헤더
                Row(
                  mainAxisAlignment:
                  MainAxisAlignment.spaceBetween,

                  children: [

                    GestureDetector(
                      onTap: () {
                        Navigator.pop(
                          context,
                        );
                      },

                      child: const Icon(
                        Icons.arrow_back_ios_new,
                        size: 22,
                      ),
                    ),

                    const Text(
                      '상세 정보',

                      style: TextStyle(
                        fontSize: 22,
                        fontWeight:
                        FontWeight.bold,
                      ),
                    ),

                    GestureDetector(
                      onTap: () {
                        // Navigator.push(
                        //   context,
                        //
                        //   MaterialPageRoute(
                        //     builder: (_) =>
                        //     const MyPage(),
                        //   ),
                        // );
                      },

                      child: const Icon(
                        Icons.edit_outlined,
                        size: 24,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 30),

                /// 프로필 이미지
                Container(
                  width: 92,
                  height: 92,

                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,

                    borderRadius:
                    BorderRadius.circular(16),
                  ),
                ),

                const SizedBox(height: 18),

                /// 역할
                Text(
                  '동료',

                  style: TextStyle(
                    color:
                    Colors.grey.shade600,

                    fontSize: 15,
                    fontWeight:
                    FontWeight.w600,
                  ),
                ),

                const SizedBox(height: 6),

                /// 이름 + 상태
                Row(
                  mainAxisAlignment:
                  MainAxisAlignment.center,

                  children: [

                    const Text(
                      '박지연',

                      style: TextStyle(
                        fontSize: 30,
                        fontWeight:
                        FontWeight.bold,
                      ),
                    ),

                    const SizedBox(width: 10),

                    Container(
                      padding:
                      const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),

                      decoration: BoxDecoration(
                        color:
                        Colors.grey.shade800,

                        borderRadius:
                        BorderRadius.circular(
                          10,
                        ),
                      ),

                      child: const Text(
                        '재직중',

                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight:
                          FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                /// 태그
                Wrap(
                  spacing: 8,

                  children: const [

                    TagChip(text: '매점'),
                    TagChip(text: '매표'),
                    TagChip(text: '마감 불가'),
                  ],
                ),

                const SizedBox(height: 26),

                /// 개인 정보
                InfoSectionCard(
                  title: '개인 정보',

                  items: [
                    ['이름', '박지연'],
                    ['생년월일', '2000.00.00'],
                    ['휴대폰 번호', '010-1234-2050'],
                  ],
                ),

                const SizedBox(height: 16),

                /// 소속 정보
                InfoSectionCard(
                  title: '소속 정보',

                  items: [
                    ['직급', '동료'],
                    ['입사일', '2026년 4월 1일'],
                    ['재직 상태', '재직중'],
                  ],
                ),

                const SizedBox(height: 16),

                /// 근무 정보
                InfoSectionCard(
                  title: '근무 정보',

                  items: [
                    ['근무 시간', '오전 07:00 - 11:00'],
                    ['근무 요일', '월,수,금'],
                  ],
                ),

                const SizedBox(height: 16),

                /// 지난 달 근무 정보
                InfoSectionCard(
                  title: '지난 달 근무 정보',

                  items: [
                    ['총 근무 일수', '16일'],
                    ['총 근무 시간', '80시간'],
                  ],
                ),

                const SizedBox(height: 16),

                /// 지난 달 급여 정보
                GestureDetector(
                  onTap: () {},

                  child: Container(
                    width: double.infinity,

                    padding:
                    const EdgeInsets.symmetric(
                      horizontal: 18,
                      vertical: 22,
                    ),

                    decoration: BoxDecoration(
                      color:
                      Colors.grey.shade200,

                      borderRadius:
                      BorderRadius.circular(24),
                    ),

                    child: Row(
                      mainAxisAlignment:
                      MainAxisAlignment.spaceBetween,

                      children: [

                        const Text(
                          '지난 달 급여 정보',

                          style: TextStyle(
                            fontSize: 20,
                            fontWeight:
                            FontWeight.bold,
                          ),
                        ),

                        Icon(
                          Icons.chevron_right,
                          size: 28,
                          color:
                          Colors.grey.shade600,
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ),
    );
  }
}