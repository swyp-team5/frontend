import 'package:chack_chack/employer/home/RHomePage.dart';
import 'package:chack_chack/employer/mypage/RProfileEditPage.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../common/widgets/BottomNavBar.dart';
import '../crews/ECrewPage.dart';
import '../home/EHomePage.dart';
import '../schedule/EMainSchedulePage.dart';
import 'EProfileEditPage.dart';

class EMyPage extends StatefulWidget {

  const EMyPage({super.key});

  @override
  State<EMyPage> createState() => _EMyPageState();
}

class _EMyPageState extends State<EMyPage> {

  /// 현재는 더미 사용자 ID
  /// API 연결 시: response.user.id 사용
  final String userId = "owner_1";

  /// 사용자별 저장 키
  String get EstorePreferenceKey => "E_selected_store_$userId";

  /// 현재는 더미 데이터
  /// API 연결 시:
  // final List<StoreModel> stores = response.data;
  final List<String> stores = [
    "매장명1", "매장명2"
  ];

  String EselectedStore = "매장명1";
  String EtempSelectedStore = "매장명1";

  /// API 연결 시:
  // selectedStore = response.currentStore.name;
  // tempSelectedStore = selectedStore;


  void _EshowStoreBottomSheet(BuildContext context) {
    EtempSelectedStore = EselectedStore;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return SafeArea(
              top: false,
              child: Container(
                padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(28),
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    /// 드래그 핸들
                    Container(
                      width: 42,
                      height: 5,
                      decoration: BoxDecoration(
                        color: Color(0xFFD9D9D9),
                        borderRadius: BorderRadius.circular(999),
                      ),
                    ),

                    const SizedBox(height: 22),

                    /// 제목
                    SizedBox(
                      width: double.infinity,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          const Text(
                            "매장 변경",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),

                          Positioned(
                            right: 0,
                            child: GestureDetector(
                              onTap: () => Navigator.pop(context),
                              child: Container(
                                width: 28,
                                height: 28,
                                decoration: const BoxDecoration(
                                  color: Color(0xFFF2F2F6),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(Icons.close),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    Container(
                      width: double.infinity,
                      height: 1,
                      color: const Color(0xFFE5E5E5),
                    ),

                    const SizedBox(height: 18),

                    /// 매장 목록
                    ...stores.map((store) {
                      final selected = store == EtempSelectedStore;

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(18),
                          onTap: () {
                            setModalState(() {
                              EtempSelectedStore = store;
                            });
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 22,
                            ),
                            decoration: BoxDecoration(
                              color: selected
                                  ? const Color(0xFFE6F3FF) // 선택 시 파란 배경
                                  : const Color(0xFFF5F5F7), // 미선택 시 회색 배경
                              borderRadius: BorderRadius.circular(12),
                              border: selected
                                  ? Border.all(
                                color: Color(0xFF0084FF),
                                width: 2,
                              )
                                  : null,
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    store,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),

                                if (selected)
                                  Container(
                                    width: 22,
                                    height: 22,
                                    decoration: const BoxDecoration(
                                      color: Color(0xFF0084FF),
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Center(
                                      child: Icon(
                                        Icons.check,
                                        size: 16,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }),

                    const SizedBox(height: 20),

                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: () async {
                          final prefs = await SharedPreferences.getInstance();

                          // 선택한 매장 저장
                          await prefs.setString(
                            EstorePreferenceKey,
                            EtempSelectedStore,
                          );

                          setState(() {
                            EselectedStore = EtempSelectedStore;
                          });

                          Navigator.pop(context);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF0084FF),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text(
                          "변경",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
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
      },
    );
  }

  @override
  void initState() {
    super.initState();
    _loadSelectedStore();
  }

  Future<void> _loadSelectedStore() async {
    final prefs = await SharedPreferences.getInstance();

    final savedStore = prefs.getString(EstorePreferenceKey);

    if (savedStore != null && stores.contains(savedStore)) {
      setState(() {
        EselectedStore = savedStore;
        EtempSelectedStore = savedStore;
      });
    }
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor:
      const Color(0xFFF5F5F5),

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
            horizontal: 24,
            vertical: 28,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// 상단 헤더
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "마이페이지",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  GestureDetector(
                    onTap: () {
                      _EshowStoreBottomSheet(context);
                    },
                    child: Row(
                      children: [
                        Text(
                          EselectedStore,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 4),
                        const Icon(Icons.keyboard_arrow_down),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 36),

              /// 내 프로필
              _buildSectionTitle("내 프로필"),
              const SizedBox(height: 14),

              _buildCard(
                children: [
                  _buildMenuRow(
                    icon: Icons.account_circle_outlined,
                    title: "김알바",
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const EProfileEditPage(),
                        ),
                      );
                    },
                  ),
                ],
              ),

              const SizedBox(height: 32),

              /// 근무 관리
              _buildSectionTitle("근무 관리"),
              const SizedBox(height: 14),

              _buildCard(
                children: [
                  _buildMenuRow(
                    icon: Icons.calendar_month_outlined,
                    title: "근무 스케줄",
                  ),
                  const Divider(height: 1, color: Color(0xFFF2F2F2)),
                  _buildMenuRow(
                    icon: Icons.access_time_outlined,
                    title: "출퇴근 기록",
                  ),
                ],
              ),

              const SizedBox(height: 32),

              /// 업무 관리
              _buildSectionTitle("업무 관리"),
              const SizedBox(height: 14),

              _buildCard(
                children: [
                  _buildMenuRow(
                    icon: Icons.send_outlined,
                    title: "보낸 요청 내역",
                  ),
                  const Divider(height: 1, color: Color(0xFFF2F2F2)),
                  _buildMenuRow(
                    icon: Icons.send_outlined,
                    title: "받은 요청 내역",
                  ),
                ],
              ),

              const SizedBox(height: 32),

              /// 고객 지원
              _buildSectionTitle("고객 지원"),
              const SizedBox(height: 14),

              _buildCard(
                children: [
                  _buildMenuRow(
                    icon: Icons.groups_outlined,
                    title: "고객 센터",
                  ),
                  const Divider(height: 1, color: Color(0xFFF2F2F2)),
                  _buildMenuRow(
                    icon: Icons.settings_outlined,
                    title: "계정 설정",
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 흰 색 컨테이너
  Widget _buildCard({
    required List<Widget> children,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(children: children),
    );
  }

  /// (아이콘, 제목, 화살표) 아이템
  Widget _buildMenuRow({
    required IconData icon,
    required String title,
    VoidCallback? onTap,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 20,
        ),
        child: Row(
          children: [
            Icon(icon, size: 20),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const Icon(
              Icons.chevron_right,
              color: Color(0xFFB8B8BE),
            ),
          ],
        ),
      ),
    );
  }

  /// 섹션 제목
  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        color: Color(0xFF767676),
        fontSize: 16,
        fontWeight: FontWeight.w600,
      ),
    );
  }
}