import 'package:chack_chack/employer/mypage/MyPage.dart';
import 'package:flutter/material.dart';

import '../../../common/widgets/BottomNavBar.dart';

import '../home/HomePage.dart';
import 'model/CrewModel.dart';

import 'widgets/CrewCard.dart';
import 'widgets/SectionTitle.dart';

class CrewsPage extends StatefulWidget {
  const CrewsPage({super.key});

  @override
  State<CrewsPage> createState() =>
      _CrewsPageState();
}

class _CrewsPageState
    extends State<CrewsPage> {

  final List<CrewModel> inviteCrews = [

    CrewModel(
      name: '모수연',
      role: '동료',
      tags: ['웰컴'],
      status: 'invite',
    ),

    CrewModel(
      name: '윤서준',
      role: '동료',
      tags: ['매점', '오픈 불가'],
      status: 'invite',
    ),
  ];

  final List<CrewModel> waitingCrews = [

    CrewModel(
      name: '김상우',
      role: '동료',
      tags: ['웰컴', '매점'],
      status: 'waiting',
    ),
  ];

  final List<CrewModel> completedCrews = [

    CrewModel(
      name: '박지연',
      role: '동료',
      tags: ['매점', '마감 불가'],
      status: 'completed',
    ),
  ];

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
                const HomePage(),
              ),
            );
          }

          /// 동료
          else if (index == 1) {}

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
                const MyPage(),
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
              crossAxisAlignment:
              CrossAxisAlignment.start,

              children: [

                /// 헤더
                Row(
                  mainAxisAlignment:
                  MainAxisAlignment
                      .spaceBetween,

                  children: [

                    const Text(
                      '동료',

                      style: TextStyle(
                        fontSize: 25,
                        fontWeight:
                        FontWeight.w700,
                      ),
                    ),

                    IconButton(
                      onPressed: () {},

                      icon: const Icon(
                        Icons
                            .person_add_alt_1_outlined,
                        size: 35,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                /// 내 카드
                Row(
                  children: [

                    Container(
                      width: 68,
                      height: 68,

                      decoration:
                      BoxDecoration(
                        color: Colors
                            .grey.shade300,

                        borderRadius:
                        BorderRadius
                            .circular(
                          14,
                        ),
                      ),
                    ),

                    const SizedBox(width: 14),

                    Column(
                      crossAxisAlignment:
                      CrossAxisAlignment
                          .start,

                      children: [

                        Text(
                          '사장님',

                          style: TextStyle(
                            color: Colors
                                .grey
                                .shade600,

                            fontSize: 13,
                            fontWeight:
                            FontWeight
                                .w600,
                          ),
                        ),

                        const SizedBox(
                          height: 4,
                        ),

                        const Text(
                          '김다빈 (나)',

                          style: TextStyle(
                            fontSize: 18,
                            fontWeight:
                            FontWeight
                                .bold,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),

                const SizedBox(height: 30),

                /// 초대 예정
                SectionTitle(
                  title:
                  '초대 예정 ${inviteCrews.length}',
                ),

                const SizedBox(height: 16),

                ...inviteCrews.map(
                      (crew) {

                    return Padding(
                      padding:
                      const EdgeInsets.only(
                        bottom: 16,
                      ),

                      child: CrewCard(
                        crew: crew,
                      ),
                    );
                  },
                ),

                const SizedBox(height: 20),

                /// 초대 수락 대기중
                SectionTitle(
                  title:
                  '초대 수락 대기 중 ${waitingCrews.length}',
                ),

                const SizedBox(height: 16),

                ...waitingCrews.map(
                      (crew) {

                    return Padding(
                      padding:
                      const EdgeInsets.only(
                        bottom: 16,
                      ),

                      child: CrewCard(
                        crew: crew,
                      ),
                    );
                  },
                ),

                /// 초대 완료
                SectionTitle(
                  title: '초대 완료 ${waitingCrews.length}',
                ),

                const SizedBox(height: 16),

                ...completedCrews.map(
                      (crew) {

                    return Padding(
                      padding:
                      const EdgeInsets.only(
                        bottom: 16,
                      ),

                      child: CrewCard(
                        crew: crew,
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}