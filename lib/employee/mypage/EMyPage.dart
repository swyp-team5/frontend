import 'package:flutter/material.dart';

import '../../../common/widgets/BottomNavBar.dart';
import '../home/EHomePage.dart';
import 'EProfileEditPage.dart';

class EMyPage extends StatefulWidget {

  const EMyPage({super.key});

  @override
  State<EMyPage> createState() =>
      _EMyPageState();
}

class _EMyPageState extends State<EMyPage> {

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor:
      const Color(0xFFF5F5F5),

      /// 공통 BottomNavBar 적용
      bottomNavigationBar:
      BottomNavBar(
        currentIndex: 4,

        onTap: (index) {

          /// 홈
          if (index == 0) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) =>
                const EHomePage(),
              ),
            );
          }

          /// 동료
          else if (index == 1) {
            // Navigator.push(
            //   context,
            //   MaterialPageRoute(
            //     builder: (_) =>
            //     const RCrewPage(),
            //   ),
            // );
          }

          /// 스케줄
          else if (index == 2) {}

          /// 급여
          else if (index == 3) {}

          /// 마이페이지
          else if (index == 4) {}
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

                /// 타이틀
                const Text(
                  '마이페이지',

                  style: TextStyle(
                    fontSize: 25,
                    fontWeight:
                    FontWeight.w700,
                  ),
                ),

                const SizedBox(height: 40),

                /// 내 프로필
                _buildSectionTitle(
                  '내 프로필',
                ),

                const SizedBox(height: 20),

                Row(
                  children: [

                    /// 프로필 이미지
                    Container(
                      width: 40,
                      height: 40,

                      decoration: BoxDecoration(
                        color:
                        Colors.grey.shade300,

                        shape: BoxShape.circle,
                      ),
                    ),

                    const SizedBox(width: 15),

                    /// 이름
                    const Expanded(
                      child: Text(
                        '스폰지밥',

                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),

                    /// 버튼
                    OutlinedButton(
                      onPressed: () {
                        Navigator.push(
                          context,

                          MaterialPageRoute(
                            builder: (_) =>
                            const EProfileEditPage(),
                          ),
                        );
                      },

                      style:
                      OutlinedButton.styleFrom(
                        side: BorderSide(
                          color:
                          Colors.grey.shade500,
                        ),

                        padding:
                        const EdgeInsets.symmetric(
                          horizontal: 13,
                          vertical: 10,
                        ),

                        shape:
                        RoundedRectangleBorder(
                          borderRadius:
                          BorderRadius.circular(
                            0,
                          ),
                        ),
                      ),

                      child: const Text(
                        '프로필 변경하기',

                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 12,
                          fontWeight:
                          FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 40),

                /// 근무 관리
                _buildSectionTitle(
                  '근무 관리',
                ),

                const SizedBox(height: 20),


                _buildMenuItem(
                  icon:
                  Icons.calendar_month_rounded,
                  title: '근무 스케줄',
                ),

                const SizedBox(height: 15),

                _buildMenuItem(
                  icon:
                  Icons.access_time_outlined,
                  title: '출퇴근 기록',
                ),

                const SizedBox(height: 40),

                /// 업무 관리
                _buildSectionTitle(
                  '업무 관리',
                ),

                const SizedBox(height: 20),

                _buildMenuItem(
                  icon:
                  Icons.send_outlined,
                  title: '교대 요청 내역',
                ),

                const SizedBox(height: 15),

                _buildMenuItem(
                  icon:
                  Icons.send_outlined,
                  title: '교대 수락 내역',
                ),

                const SizedBox(height: 40),

                /// 고객 지원
                _buildSectionTitle(
                  '고객 지원',
                ),

                const SizedBox(height: 20),

                _buildMenuItem(
                  icon:
                  Icons.support_agent_outlined,
                  title: '고객 센터',
                ),

                const SizedBox(height: 15),

                _buildMenuItem(
                  icon:
                  Icons.settings_outlined,
                  title: '계정 설정',
                ),

                const SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// 섹션 제목
  Widget _buildSectionTitle(
      String title,
      ) {

    return Text(
      title,

      style: TextStyle(
        color: Colors.grey.shade400,
        fontSize: 13,
        fontWeight: FontWeight.w600,
      ),
    );
  }

  /// 메뉴 아이템
  Widget _buildMenuItem({
    required IconData icon,
    required String title,
  }) {

    return Row(
      children: [

        Icon(icon, size: 26,),

        const SizedBox(width: 14),

        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}