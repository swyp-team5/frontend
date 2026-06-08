import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../crews/CrewsPage.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),

      /// 하단 네비게이션 바
      bottomNavigationBar: Container(
        padding: const EdgeInsets.symmetric(
          vertical: 10,
        ),

        decoration: BoxDecoration(
          color: Colors.white,

          border: Border(
            top: BorderSide(
              color: Colors.grey.shade300,
            ),
          ),
        ),

        child: SafeArea(
          top: false,

          child: Row(
            mainAxisAlignment:
            MainAxisAlignment.spaceAround,

            children: [

              /// 홈
              _buildBottomItem(
                icon: Icons.home_filled,
                label: '홈',
                isSelected: true,

                onTap: () {},
              ),

              /// 동료
              _buildBottomItem(
                icon: Icons.groups_rounded,
                label: '동료',
                isSelected: false,

                onTap: () {

                  Navigator.push(
                    context,

                    MaterialPageRoute(
                      builder: (_) =>
                      const CrewsPage(),
                    ),
                  );
                },
              ),

              /// 스케줄
              _buildBottomItem(
                icon: Icons.calendar_month,
                label: '스케줄',
                isSelected: false,

                onTap: () {},
              ),

              /// 급여
              _buildBottomItem(
                icon: Icons.payments_outlined,
                label: '급여',
                isSelected: false,

                onTap: () {},
              ),

              /// 마이페이지
              _buildBottomItem(
                icon: Icons.person_outline,
                label: '마이페이지',
                isSelected: false,

                onTap: () {},
              ),
            ],
          ),
        ),
      ),

      /// body
      body: SafeArea(
        child: SingleChildScrollView(

          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),

            child: Column(
              children: [

                /// 상단 헤더
                Row(
                  mainAxisAlignment:
                  MainAxisAlignment.spaceBetween,

                  children: [

                    Row(
                      children: [

                        const Text(
                          '매장명',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        const SizedBox(width: 4),

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
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 10),

                /// 공지 배너
                Container(
                  width: double.infinity,

                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 12,
                  ),

                  decoration: BoxDecoration(
                    color: const Color(0xFFE8E8ED),
                    borderRadius:
                    BorderRadius.circular(10),
                  ),

                  child: const Text(
                    '공지  마감 때 쓰레기 비우는거 잊지 마세요',

                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),

                const SizedBox(height: 14),

                /// 메인 카드
                Container(
                  width: double.infinity,

                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 28,
                  ),

                  decoration: BoxDecoration(
                    color: const Color(0xFFE8E8ED),
                    borderRadius:
                    BorderRadius.circular(18),
                  ),

                  child: Column(
                    children: [

                      const Icon(
                        Icons.calendar_month_outlined,
                        size: 48,
                      ),

                      const SizedBox(height: 20),

                      const Text(
                        '직원의 스케줄을 자동으로 만들고\n편하게 스케줄을 만들어 보세요!',

                        textAlign: TextAlign.center,

                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          height: 1.5,
                        ),
                      ),

                      const SizedBox(height: 24),

                      SizedBox(
                        width: double.infinity,
                        height: 54,

                        child: ElevatedButton(
                          onPressed: () {},

                          style: ElevatedButton.styleFrom(
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
                            '스케줄 만들기',

                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight:
                              FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 14),

                /// 공지 작성 카드
                _buildMenuCard(
                  title: '공지 작성',
                ),

                const SizedBox(height: 14),

                /// 오늘 근무 카드
                Container(
                  width: double.infinity,

                  padding: const EdgeInsets.all(18),

                  decoration: BoxDecoration(
                    color: const Color(0xFFE8E8ED),
                    borderRadius:
                    BorderRadius.circular(18),
                  ),

                  child: Column(
                    crossAxisAlignment:
                    CrossAxisAlignment.start,

                    children: [

                      Row(
                        mainAxisAlignment:
                        MainAxisAlignment
                            .spaceBetween,

                        children: [

                          const Text(
                            '오늘 근무',

                            style: TextStyle(
                              fontSize: 20,
                              fontWeight:
                              FontWeight.bold,
                            ),
                          ),

                          const Icon(
                            Icons.chevron_right,
                          ),
                        ],
                      ),

                      const SizedBox(height: 50),

                      Center(
                        child: Text(
                          '오늘 근무하는 직원이 없어요',

                          style: TextStyle(
                            color: Colors.grey.shade500,
                            fontSize: 16,
                            fontWeight:
                            FontWeight.w500,
                          ),
                        ),
                      ),

                      const SizedBox(height: 40),

                      Center(
                        child: Row(
                          mainAxisSize:
                          MainAxisSize.min,

                          children: const [

                            Text(
                              '자세히보기',

                              style: TextStyle(
                                fontSize: 18,
                                fontWeight:
                                FontWeight.bold,
                              ),
                            ),

                            SizedBox(width: 4),

                            Icon(
                              Icons.chevron_right,
                            ),
                          ],
                        ),
                      ),
                    ],
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

  Widget _buildMenuCard({
    required String title,
  }) {

    return Container(
      width: double.infinity,

      padding: const EdgeInsets.symmetric(
        horizontal: 18,
        vertical: 22,
      ),

      decoration: BoxDecoration(
        color: const Color(0xFFE8E8ED),
        borderRadius: BorderRadius.circular(18),
      ),

      child: Row(
        mainAxisAlignment:
        MainAxisAlignment.spaceBetween,

        children: [

          Text(
            title,

            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),

          const Icon(
            Icons.chevron_right,
          ),
        ],
      ),
    );
  }

  Widget _buildBottomItem({
    required IconData icon,
    required String label,
    required bool isSelected,
    VoidCallback? onTap,
  }) {

    return InkWell(
      onTap: onTap,

      borderRadius: BorderRadius.circular(12),

      child: Padding(
        padding: const EdgeInsets.all(8),

        child: Column(
          mainAxisSize: MainAxisSize.min,

          children: [

            Icon(
              icon,

              color:
              isSelected
                  ? Colors.grey.shade700
                  : Colors.grey.shade400,
            ),

            const SizedBox(height: 4),

            Text(
              label,

              style: TextStyle(
                color:
                isSelected
                    ? Colors.grey.shade700
                    : Colors.grey.shade400,

                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}