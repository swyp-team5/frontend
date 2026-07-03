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
    Dio(
      BaseOptions(
        baseUrl: "https://chackchack.shop",
      ),
    ),
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

      final profile = await profileApi.getMyProfile(
        token: token,
      );

      if (!mounted) return;

      setState(() {
        myName = profile["name"] ?? "이름 없음";
        myProfileImageUrl =
        profile["profileImage"]?["imageUrl"];
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
        options: Options(
          headers: {
            "Authorization": "Bearer $token",
          },
        ),
      );

      debugPrint("========== CREWS API ==========");
      debugPrint(response.data.toString());

      final List list = response.data["crews"];

      // 서버가 내려준 원본 데이터 확인
      debugPrint("========== RAW LIST ==========");
      for (final item in list) {
        debugPrint(
          "${item["name"]} / ${item["crewRole"]}",
        );
      }

      final crewList =
      list.map((e) => ECrewModel.fromJson(e)).toList();

      // 모델 변환 후 확인
      debugPrint("========== MODEL ==========");
      for (final crew in crewList) {
        debugPrint(
          "${crew.name} / ${crew.crewRole}",
        );
      }

      final ownerExists =
      crewList.any((e) => e.crewRole == "OWNER");

      debugPrint("OWNER 존재 여부 : $ownerExists");

      if (ownerExists) {
        final owner =
        crewList.firstWhere((e) => e.crewRole == "OWNER");

        debugPrint(
          "OWNER -> ${owner.name}, ${owner.profileImageUrl}",
        );
      }

      if (!mounted) return;

      setState(() {
        crews = crewList;
      });
    } on DioException catch (e) {
      debugPrint("========== API ERROR ==========");
      debugPrint("status : ${e.response?.statusCode}");
      debugPrint("body   : ${e.response?.data}");
    } catch (e) {
      debugPrint("========== ERROR ==========");
      debugPrint(e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {

    final owner = crews.where((e) => e.crewRole == "OWNER").toList();
    final workers = crews.where((e) => e.crewRole == "WORKER").toList();


    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),

      bottomNavigationBar: BottomNavBar(
        currentIndex: 1,
        onTap: (index) {
          if (index == 0) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const EHomePage(),
              ),
            );
          } else if (index == 1) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const ECrewPage(),
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
            horizontal: 24,
            vertical: 28,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// 제목
              const Text(
                "근무자",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
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

              /// 나
              Text(
                "나",
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontSize: 14,
                ),
              ),

              const SizedBox(height: 14),

              GestureDetector(
                onTap: () async {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const EProfileEditPage(),
                    ),
                  );

                  // 프로필 수정 후 이름 다시 불러오기
                  _loadMyProfile();
                },
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 28,
                        backgroundImage:
                        (myProfileImageUrl != null &&
                            myProfileImageUrl!.isNotEmpty)
                            ? NetworkImage(myProfileImageUrl!)
                            : const AssetImage(
                            "assets/images/profile.png")
                        as ImageProvider,
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment:
                          CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "근무자",
                              style: TextStyle(
                                fontSize: 13,
                                color: Color(0xFF8E8E93),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              myName,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),

              if (owner.isNotEmpty) ...[
                const SizedBox(height: 20),

                Text(
                  "사장님",
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 14,
                  ),
                ),

                const SizedBox(height: 14),

                ECrewCard(
                  crew: owner.first,
                  showArrow: false,
                ),

                const SizedBox(height: 20),
              ],

              /// 근무자 수
              Row(
                children: [
                  const Text(
                    "근무자 ",
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    "${workers.length}",
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              /// 근무자 목록
              Column(
                children: workers
                    .where((crew) => crew.name != myName)
                    .map((crew) {
                  return ECrewCard(
                    crew: crew,
                    onTap: () {
                      // Navigator.push(
                      //   context,
                      //   MaterialPageRoute(
                      //     builder: (_) => ECrewDetailPage(
                      //       crew: crew,
                      //     ),
                      //   ),
                      // );
                    },
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