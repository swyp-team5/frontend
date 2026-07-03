import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dio/dio.dart';

import '../../../common/widgets/BottomNavBar.dart';
import '../../common/auth/server_token_manager.dart';
import '../../employer/mypage/api/profile_api.dart';
import '../home/EHomePage.dart';
import '../mypage/EMyPage.dart';
import '../mypage/EProfileEditPage.dart';
import 'EApplicationFormPage.dart';
import 'ECrewDetailPage.dart';
import 'model/ECrewModel.dart';
import 'widgets/ECrewCard.dart';

class ECrewPage extends StatefulWidget {
  const ECrewPage({super.key});

  @override
  State<ECrewPage> createState() => _ECrewPageState();
}

class _ECrewPageState extends State<ECrewPage> {
  List<ECrewModel> crews = [];

  String myName = "";
  String? myProfileImageUrl;

  final ProfileApi profileApi = ProfileApi(
    Dio(BaseOptions(baseUrl: "https://chackchack.shop")),
  );

  @override
  void initState() {
    super.initState();
    _loadMyProfile();
    _loadCrews();
  }

  Future<void> _loadMyProfile() async {
    try {
      final token = await ServerTokenManager.getValidAccessToken();
      if (token == null) return;

      final profile = await profileApi.getMyProfile(token: token);

      if (!mounted) return;

      setState(() {
        myName = profile["name"]?.toString() ?? "이름 없음";
        myProfileImageUrl =
            profile["profileImage"]?["imageUrl"]?.toString();
      });
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  Future<void> _loadCrews() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final workPlaceId = prefs.getInt("selectedWorkPlaceId");

      if (workPlaceId == null) {
        debugPrint("❌ workPlaceId 없음");
        return;
      }

      final token = await ServerTokenManager.getValidAccessToken();
      if (token == null) {
        debugPrint("❌ 토큰 없음");
        return;
      }

      final dio = Dio();

      final response = await dio.get(
        "https://chackchack.shop/api/work-places/$workPlaceId/crews",
        options: Options(headers: {"Authorization": "Bearer $token"}),
      );

      final List list = (response.data["crews"] ?? []) as List;

      final crewList = list.map((e) {
        return ECrewModel.fromJson(Map<String, dynamic>.from(e ?? {}));
      }).toList();

      if (!mounted) return;

      setState(() {
        crews = crewList;
      });
    } catch (e) {
      debugPrint("ERROR: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    // "나" 섹션에 이미 표시되므로, 아래 근무자 리스트에서는 본인을 제외한다.
    // ⚠️ 이름으로 비교 중이라 동명이인이 있으면 문제가 될 수 있습니다.
    //    ECrewModel에 고유 id(memberId 등)가 있다면 그걸로 비교하는 것을 권장합니다.
    final others = crews.where((c) => c.name != myName).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),

      bottomNavigationBar: BottomNavBar(
        currentIndex: 1,
        onTap: (index) {
          if (index == 0) {
            Navigator.push(context,
                MaterialPageRoute(builder: (_) => const EHomePage()));
          } else if (index == 1) {
            Navigator.push(context,
                MaterialPageRoute(builder: (_) => const ECrewPage()));
          } else if (index == 4) {
            Navigator.push(context,
                MaterialPageRoute(builder: (_) => const EMyPage()));
          }
        },
      ),

      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "근무자",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 22),

              /// 교대 근무 신청 카드
              InkWell(
                onTap: () {},
                borderRadius: BorderRadius.circular(18),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: Color(0xFFEEEBFF),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.calendar_today_outlined,
                        color: Color(0xFF7D67FD),
                        size: 20,
                      ),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Text(
                          "교대 근무 신청하기",
                          style: TextStyle(
                            color: Color(0xFF7D67FD),
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      IconButton(
                        icon: Icon(
                          Icons.chevron_right,
                          color: Colors.grey.shade500,
                          size: 22,
                        ),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(
                          minWidth: 24,
                          minHeight: 24,
                        ),
                        splashRadius: 18,
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const EApplicationFormPage(),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              const Text("나",
                  style: TextStyle(color: Colors.grey, fontSize: 14)),

              const SizedBox(height: 14),

              /// 내 프로필 (아래 근무자 카드와 동일한 스타일)
              Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: (myProfileImageUrl != null &&
                        myProfileImageUrl!.isNotEmpty)
                        ? Image.network(
                      myProfileImageUrl!,
                      width: 56,
                      height: 56,
                      fit: BoxFit.cover,
                    )
                        : Image.asset(
                      "assets/images/profile.png",
                      width: 56,
                      height: 56,
                      fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "근무자",
                        style: TextStyle(color: Colors.grey, fontSize: 13),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        myName,
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 24),

              /// 근무자 수 (본인 제외 전체 인원)
              Row(
                children: [
                  const Text("근무자 ",
                      style: TextStyle(color: Colors.grey)),
                  Text("${others.length}",
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                ],
              ),

              const SizedBox(height: 16),

              /// 근무자 목록 (본인 제외, API 응답 순서 그대로)
              Column(
                children: others.map((crew) {
                  return ECrewCard(
                    crew: crew,
                    showArrow: true,
                  );
                }).toList(),
              )
            ],
          ),
        ),
      ),
    );
  }
}