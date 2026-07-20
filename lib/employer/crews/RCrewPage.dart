import 'package:chack_chack/employer/mypage/RMyPage.dart';
import 'package:chack_chack/employer/schedule/RMainSchedulePage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../mypage/api/profile_api.dart';

import '../../../common/widgets/BottomNavBar.dart';
import '../../common/workplace/selected_work_place_storage.dart';

import '../home/RHomePage.dart';
import 'RCrewInvitationHistoryPage.dart';
import 'RCrewDetailPage.dart';
import 'model/RCrewModel.dart';
import 'share/crew_invitation_share_service.dart';

import 'widgets/RCrewCard.dart';
import 'widgets/crew_invitation_share_actions.dart';

import '../../common/auth/server_token_manager.dart';
import 'package:dio/dio.dart';

class RCrewPage extends StatefulWidget {
  const RCrewPage({super.key});

  @override
  State<RCrewPage> createState() => _RCrewPageState();
}

class _RCrewPageState extends State<RCrewPage> {

  List<RCrewModel> crews = [];

  // 사장님(나) 프로필 - crews API와 별개로 독립 조회
  String ownerName = "사장님";
  String? ownerProfileImageUrl;

  int? invitationId;
  String inviteCode = "";
  String inviteShareUrl = "";
  DateTime? inviteExpiresAt;
  bool isCreatingInvitation = false;

  int? workPlaceId;

  final ProfileApi profileApi = ProfileApi(
    Dio(
      BaseOptions(
        baseUrl: "https://chackchack.shop",
      ),
    ),
  );
  final CrewInvitationShareService _invitationShareService =
      CrewInvitationShareService();

  Future<void> _copyInvitationLink() async {
    if (inviteShareUrl.isEmpty) {
      _showMessage('복사할 초대 링크가 없어요.');
      return;
    }

    await Clipboard.setData(ClipboardData(text: inviteShareUrl));
    _showMessage('초대 링크가 복사되었습니다.');
  }

  Future<void> _shareInvitationToKakao() async {
    try {
      final result = await _invitationShareService.share(
        inviteCode: inviteCode,
      );
      if (result == KakaoInvitationShareResult.unavailable) {
        _showMessage('카카오톡이 설치되어 있지 않아요.');
      }
    } catch (error) {
      debugPrint('카카오톡 초대 공유 실패: $error');
      _showMessage('카카오톡 공유를 시작하지 못했어요.');
    }
  }

  void _showMessage(String message) {
    if (!mounted) {
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  Future<void> _createCrewInvitation() async {
    try {
      setState(() {
        isCreatingInvitation = true;
      });

      final workPlaceId = await SelectedWorkPlaceStorage.load();

      if (workPlaceId == null) {
        throw Exception("workPlaceId 없음");
      }

      final token = await ServerTokenManager.getValidAccessToken();

      if (token == null) {
        throw Exception("토큰 없음");
      }

      final dio = Dio();

      final response = await dio.post(
        "https://chackchack.shop/api/work-places/$workPlaceId/crew-invitations",
        options: Options(
          headers: {
            "Authorization": "Bearer $token",
          },
        ),
      );

      debugPrint(response.data.toString());

      final data = response.data;

      setState(() {
        invitationId = data["invitationId"];
        inviteCode = data["inviteCode"] ?? "";
        inviteShareUrl = data["inviteShareUrl"] ?? "";
        inviteExpiresAt = data["expiresAt"] != null
            ? DateTime.tryParse(data["expiresAt"])
            : null;
      });
    } on DioException catch (e) {
      debugPrint(e.response?.data.toString());

      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            e.response?.data["message"] ?? "초대 생성 실패",
          ),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          isCreatingInvitation = false;
        });
      }
    }
  }

  void _showInviteBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) {
        return SafeArea(
          top: false,
          child: Container(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
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
                  width: 44,
                  height: 5,
                  decoration: BoxDecoration(
                    color: Color(0xFFD9D9D9),
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),

                const SizedBox(height: 24),

                /// 제목 + 닫기 버튼
                Stack(
                  alignment: Alignment.center,
                  children: [
                    const Center(
                      child: Text(
                        "크루 초대",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),

                    Positioned(
                      right: 0,
                      child: GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Container(
                          width: 34,
                          height: 34,
                          decoration: const BoxDecoration(
                            color: Color(0xFFF2F2F6),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.close,
                            color: Color(0xFF767676),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                const Text(
                  "초대 링크 공유를 통해 근무자들을 초대하세요",
                  style: TextStyle(
                    fontSize: 14,
                    color: Color(0xFF767676),
                  ),
                ),

                const SizedBox(height: 20),

                Container(
                  width: double.infinity,
                  height: 1,
                  color: const Color(0xFFE5E5E5),
                ),

                const SizedBox(height: 20),

                // /// 초대 링크
                // const Align(
                //   alignment: Alignment.centerLeft,
                //   child: Text(
                //     "초대 링크",
                //     style: TextStyle(
                //       fontSize: 15,
                //       fontWeight: FontWeight.w600,
                //       color: Colors.grey,
                //     ),
                //   ),
                // ),
                //
                // const SizedBox(height: 10),
                //
                // Container(
                //   width: double.infinity,
                //   padding: const EdgeInsets.symmetric(
                //     horizontal: 16,
                //     vertical: 18,
                //   ),
                //   decoration: BoxDecoration(
                //     color: const Color(0xFFF5F5F7),
                //     borderRadius: BorderRadius.circular(14),
                //   ),
                //   child: Text(
                //     inviteShareUrl,
                //     style: const TextStyle(
                //       fontSize: 15,
                //       color: Colors.black54,
                //     ),
                //   ),
                // ),
                //
                // const SizedBox(height: 20),
                //
                // /// 초대 코드
                // const Align(
                //   alignment: Alignment.centerLeft,
                //   child: Text(
                //     "초대 코드",
                //     style: TextStyle(
                //       fontSize: 15,
                //       fontWeight: FontWeight.w600,
                //       color: Colors.grey,
                //     ),
                //   ),
                // ),
                //
                // const SizedBox(height: 10),
                //
                // Container(
                //   width: double.infinity,
                //   padding: const EdgeInsets.symmetric(
                //     horizontal: 16,
                //     vertical: 18,
                //   ),
                //   decoration: BoxDecoration(
                //     color: const Color(0xFFF5F5F7),
                //     borderRadius: BorderRadius.circular(14),
                //   ),
                //   child: Text(
                //     inviteCode,
                //     style: const TextStyle(
                //       fontSize: 15,
                //       color: Colors.black54,
                //     ),
                //   ),
                // ),
                //
                // const SizedBox(height: 28),

                CrewInvitationShareActions(
                  onCopyLink: _copyInvitationLink,
                  onShareToKakao: _shareInvitationToKakao,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();
    _loadWorkPlaceId();
    _loadCrews();
    _loadOwnerProfile();
  }

  Future<void> _loadWorkPlaceId() async {
    final id = await SelectedWorkPlaceStorage.load();
    if (!mounted) return;
    setState(() {
      workPlaceId = id;
    });
  }

  /// 사장님(나) 프로필 조회 - crews API 성공 여부와 무관하게 독립적으로 동작
  Future<void> _loadOwnerProfile() async {
    try {
      final token = await ServerTokenManager.getValidAccessToken();

      if (token == null) {
        debugPrint("토큰 없음");
        return;
      }

      final profile = await profileApi.getMyProfile(token: token);

      debugPrint("===== OWNER PROFILE =====");
      debugPrint(profile.toString());

      if (!mounted) return;

      setState(() {
        ownerName = profile["name"]?.toString() ?? "이름 없음";
        ownerProfileImageUrl = profile["profileImage"]?["imageUrl"];
      });
    } catch (e) {
      debugPrint("사장님 프로필 조회 실패 : $e");
    }
  }

  Future<void> _loadCrews() async {
    try {
      final workPlaceId =
      await SelectedWorkPlaceStorage.load();

      if (workPlaceId == null) {
        debugPrint("workPlaceId 없음");
        return;
      }

      final token =
      await ServerTokenManager.getValidAccessToken();

      if (token == null) {
        debugPrint("토큰 없음");
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



      debugPrint("===== [RCrewPage] crews 응답 전체 =====");
      debugPrint(response.data.toString());

      final List list = response.data["crews"];

      debugPrint("===== [RCrewPage] crews 개수: ${list.length} =====");
      for (final e in list) {
        debugPrint(
            "crewId: ${e['crewId']}, name: '${e['name']}', crewRole raw: '${e['crewRole']}'");
      }

      setState(() {
        crews =
            list.map((e) => RCrewModel.fromJson(e)).toList();
      });
    } on DioException catch (e) {
      debugPrint("status=${e.response?.statusCode}");
      debugPrint("body=${e.response?.data}");
    }
  }


  @override
  Widget build(BuildContext context) {

    final workers =
    crews.where((e) => e.crewRole == "WORKER").toList();

    return Scaffold(
      backgroundColor:
      const Color(0xFFF5F5F5),

      /// 공통 BottomNavBar 적용
      bottomNavigationBar: BottomNavBar(
        currentIndex: 1,
        onTap: (index) {
          if (index == 0) {
            Navigator.push(context,
                MaterialPageRoute(builder: (_) => const RHomePage()));
          } else if (index == 1) {
            Navigator.push(context,
                MaterialPageRoute(builder: (_) => const RCrewPage()));
          } else if (index == 2) {
            Navigator.push(context,
                MaterialPageRoute(builder: (_) => RMainSchedulePage(workPlaceId: workPlaceId!)));
          } else if (index == 3) {
            Navigator.push(
                context, MaterialPageRoute(builder: (_) => const RMyPage()));
          }
        },
      ),

      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// 헤더
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "근무자",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Row(
                    children: [
                      IconButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                              const RCrewInvitationHistoryPage(),
                            ),
                          );
                        },
                        icon: const Icon(
                          Icons.history,
                          size: 28,
                        ),
                      ),
                      IconButton(
                        onPressed: () async {
                          await _createCrewInvitation();

                          if (!mounted || !context.mounted) {
                            return;
                          }

                          if (inviteCode.isNotEmpty) {
                            _showInviteBottomSheet(context);
                          }
                        },
                        icon: const Icon(
                          Icons.person_add_alt_1,
                          size: 30,
                        ),
                      ),
                    ],
                  ),
                ],
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

              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 28,
                      backgroundImage: (ownerProfileImageUrl != null &&
                          ownerProfileImageUrl!.isNotEmpty)
                          ? NetworkImage(ownerProfileImageUrl!)
                          : const AssetImage("assets/images/profile.png")
                      as ImageProvider,
                    ),

                    const SizedBox(width: 16),

                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "사장님",
                            style: TextStyle(
                              fontSize: 13,
                              color: Color(0xFF8E8E93),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            ownerName,
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

              const SizedBox(height: 20),

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

              if (crews.isNotEmpty)
                Column(
                  children: workers.map((crew) {
                    return RCrewCard(
                      crew: crew,
                      onTap: () async {
                        final result = await Navigator.push<dynamic>(
                          context,
                          MaterialPageRoute(
                            builder: (_) => RCrewDetailPage(crew: crew),
                          ),
                        );

                        if (!mounted) {
                          return;
                        }

                        if (result == true) {
                          await _loadCrews();
                        } else if (result is RCrewModel) {
                          setState(() {
                            final index = crews.indexOf(crew);
                            if (index != -1) {
                              crews[index] = result;
                            }
                          });
                        }
                      },
                    );
                  }).toList(),
                )
              else
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 60),
                  child: Center(
                    child: Column(
                      children: [
                        const Text(
                          "아직 등록된 근무자가 없습니다.",
                          style: TextStyle(
                            fontSize: 16,
                            color: Color(0xFF767676),
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          "우측 상단의 초대 버튼으로\n근무자를 초대해보세요.",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Color(0xFF9A9A9A),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

Widget _RCrewTile({
  required String role,
  required String name,
  required List<String> tags,
  bool showArrow = true,
}) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 20),
    child: Row(
      children: [
        /// 프로필
        Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            image: const DecorationImage(
              image: AssetImage("assets/images/profile.png"),
              fit: BoxFit.cover,
            ),
          ),
        ),

        const SizedBox(width: 14),

        /// 정보
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                role,
                style: const TextStyle(
                  fontSize: 12,
                  color: Color(0xFF8E8E93),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                name,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),

        /// 화살표
        if (showArrow)
          const Icon(
            Icons.chevron_right,
            color: Color(0xFFB8B8BE),
            size: 28,
          ),
      ],
    ),
  );
}
