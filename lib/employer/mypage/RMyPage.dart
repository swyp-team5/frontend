import 'package:chack_chack/employer/home/RHomePage.dart';
import 'package:chack_chack/employer/mypage/RProfileEditPage.dart';
import 'package:chack_chack/employer/mypage/RTodayWorkingPage.dart';
import 'package:chack_chack/employer/mypage/RWorkPlaceSettingPage.dart';
import 'package:flutter/material.dart';

import '../../../common/widgets/BottomNavBar.dart';
import '../../common/workplace/selected_work_place_storage.dart';
import '../crews/RCrewPage.dart';
import '../schedule/RMainSchedulePage.dart';

import '../../../common/auth/server_token_manager.dart';
import '../../common/fcm/api/NotificationSettingsApi.dart';
import 'package:dio/dio.dart';
import 'api/profile_api.dart';

class RMyPage extends StatefulWidget {

  const RMyPage({super.key});

  @override
  State<RMyPage> createState() => _RMyPageState();
}

class _RMyPageState extends State<RMyPage> {

  final ProfileApi profileApi = ProfileApi(
    Dio(
      BaseOptions(
        baseUrl: "https://chackchack.shop",
      ),
    ),
  );

  String profileName = "";

  final String userId = "owner_1";

  String get RstorePreferenceKey => "R_selected_store_$userId";

  List<Map<String, dynamic>> stores = [];

  int? selectedWorkPlaceId;

  String RselectedStore = "";
  String RtempSelectedStore = "";

  // 9.2.1 FCM 푸시 수신 여부 (서버 기본값과 동일하게 true로 시작, 로드되면 실제 값으로 갱신)
  bool fcmPushEnabled = true;

  Future<void> _loadWorkPlaces() async {
    try {
      final token = await ServerTokenManager.getValidAccessToken();

      if (token == null) {
        debugPrint("토큰 없음");
        return;
      }

      final dio = Dio();

      final response = await dio.get(
        "https://chackchack.shop/api/work-places/me",
        options: Options(
          headers: {
            "Authorization": "Bearer $token",
          },
        ),
      );

      final List list = response.data["workPlaces"];
      final loadedStores = List<Map<String, dynamic>>.from(list);
      final storedWorkPlaceId = await SelectedWorkPlaceStorage.load();

      Map<String, dynamic>? selectedStore;
      if (loadedStores.isNotEmpty) {
        selectedStore = loadedStores.firstWhere(
          (store) => store["workPlaceId"] == storedWorkPlaceId,
          orElse: () => loadedStores.first,
        );
        await SelectedWorkPlaceStorage.save(selectedStore["workPlaceId"]);
      }

      if (!mounted) {
        return;
      }

      setState(() {
        stores = loadedStores;

        if (selectedStore != null) {
          selectedWorkPlaceId = selectedStore["workPlaceId"];

          RselectedStore = selectedStore["name"];
          RtempSelectedStore = selectedStore["name"];
        }
      });
    } catch (e) {
      debugPrint(e.toString());
    }
  }


  void _RshowStoreBottomSheet(BuildContext context) {
    RtempSelectedStore = RselectedStore;

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
                      final selected =
                          store["workPlaceId"] == selectedWorkPlaceId;

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(18),
                          onTap: () {
                            setModalState(() {
                              selectedWorkPlaceId = store["workPlaceId"];
                              RtempSelectedStore = store["name"];
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
                                    store["name"],
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
                          // 선택한 매장 저장
                          await SelectedWorkPlaceStorage.save(
                            selectedWorkPlaceId!,
                          );

                          if (!mounted || !context.mounted) {
                            return;
                          }

                          setState(() {
                            RselectedStore = RtempSelectedStore;
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

    _loadWorkPlaces();
    _loadProfileName();
    _loadNotificationSettings();
  }

  // 현재 푸시 수신 설정 조회
  Future<void> _loadNotificationSettings() async {
    try {
      final settings = await NotificationSettingsApi.getSettings();

      if (!mounted) return;

      setState(() {
        fcmPushEnabled = settings.fcmPushEnabled;
      });
    } catch (e) {
      debugPrint("알림 설정 조회 실패: $e");
    }
  }

  // 토글 탭 시 즉시 UI를 바꾸고(낙관적 업데이트), 서버 반영이 실패하면 되돌린다
  Future<void> _toggleFcmPush(bool value) async {
    setState(() {
      fcmPushEnabled = value;
    });

    try {
      await NotificationSettingsApi.updateSettings(fcmPushEnabled: value);
    } catch (e) {
      debugPrint("알림 설정 변경 실패: $e");

      if (!mounted) return;

      setState(() {
        fcmPushEnabled = !value;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("알림 설정 변경에 실패했어요. 다시 시도해주세요.")),
      );
    }
  }


  Future<void> _loadProfileName() async {
    try {
      final token = await ServerTokenManager.getAccessToken();

      if (token == null || token.isEmpty) {
        debugPrint("토큰 없음");
        return;
      }

      final response = await profileApi.getMyProfile(
        token: token,
      );

      debugPrint("===== PROFILE RESPONSE =====");
      debugPrint(response.toString());

      if (!mounted) return;

      setState(() {
        profileName = response["name"]?.toString() ?? "이름 없음";
      });
    } catch (e) {
      debugPrint("프로필 조회 실패 : $e");
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
                MaterialPageRoute(builder: (_) => const RHomePage()));
          } else if (index == 1) {
            Navigator.push(context,
                MaterialPageRoute(builder: (_) => const RCrewPage()));
          } else if (index == 2) {
            Navigator.push(context,
                MaterialPageRoute(builder: (_) => RMainSchedulePage(workPlaceId: selectedWorkPlaceId!,)));
          } else if (index == 4) {
            Navigator.push(
                context, MaterialPageRoute(builder: (_) => const RMyPage()));
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
                      _RshowStoreBottomSheet(context);
                    },
                    child: Row(
                      children: [
                        Text(
                          RselectedStore,
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
                    title: profileName,
                    onTap: () async {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const RProfileEditPage(),
                        ),
                      );

                      // 프로필 수정 후 이름 다시 로드
                      _loadProfileName();
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
                    icon: Icons.calendar_today_outlined,
                    title: "오늘 근무",
                    onTap: () {
                      if (selectedWorkPlaceId == null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("매장을 먼저 선택해주세요")),
                        );
                        return;
                      }

                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => RTodayWorkingPage(
                            workPlaceId: selectedWorkPlaceId!,
                          ),
                        ),
                      );
                    },
                  ),
                  const Divider(height: 1, color: Color(0xFFF2F2F2)),
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
                    icon: Icons.storefront_outlined,
                    title: "매장 설정",
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const RWorkPlaceSettingPage(),
                        ),
                      ).then((_) => _loadWorkPlaces());
                    },
                  ),
                  const Divider(height: 1, color: Color(0xFFF2F2F2)),
                  _buildMenuRow(
                    icon: Icons.send_outlined,
                    title: "받은 승인 내역",
                  ),
                ],
              ),

              const SizedBox(height: 32),

              /// 알림 설정
              _buildSectionTitle("알림 설정"),
              const SizedBox(height: 14),

              _buildCard(
                children: [
                  _buildSwitchRow(
                    icon: Icons.notifications_none,
                    title: "푸시 알림 받기",
                    value: fcmPushEnabled,
                    onChanged: _toggleFcmPush,
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

  /// (아이콘, 제목, 스위치) 아이템 — _buildMenuRow와 달리 탭하면 다음 화면으로 이동하는 대신
  /// 그 자리에서 값을 바로 켜고 끈다
  Widget _buildSwitchRow({
    required IconData icon,
    required String title,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 20,
        vertical: 12,
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
          Switch(
            value: value,
            activeColor: const Color(0xFF0084FF),
            onChanged: onChanged,
          ),
        ],
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
