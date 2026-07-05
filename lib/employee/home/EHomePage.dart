import 'package:chack_chack/employee/crews/ECrewFirstPage.dart';
import 'package:chack_chack/employee/home/schedule/ESubmitSchedulePage.dart';
import 'package:chack_chack/employee/home/widgets/ECheckInCard.dart';
import 'package:chack_chack/employee/home/widgets/EHomeCalendar.dart';
import 'package:chack_chack/employee/home/widgets/EHomeHeader.dart';
import 'package:chack_chack/employee/home/widgets/ENoticeBanner.dart';
import 'package:chack_chack/employee/home/widgets/EScheduleCard.dart';
import 'package:chack_chack/employee/mypage/EMyPage.dart';
import 'package:chack_chack/employee/schedule/EMainSchedulePage.dart';
import 'package:flutter/material.dart';

import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../common/auth/server_token_manager.dart';
import '../../common/widgets/BottomNavBar.dart';
import '../crews/ECrewPage.dart';

enum HomeCardType {
  none,

  /// 스케줄
  weeklySchedule,
  scheduleCompleted,
  scheduleChanged,

  /// 요청
  shiftRequest,
  substituteRequest,
  ownerWorkRequest,
}

class EHomePage extends StatefulWidget {
  const EHomePage({super.key});

  @override
  State<EHomePage> createState() => _EHomePageState();
}

class _EHomePageState extends State<EHomePage> {
  DateTime focusedDay = DateTime.now();
  DateTime? selectedDay;
  bool isCardVisible = true;

  String workPlaceName = "";
  int? workPlaceId;
  String? accessToken; // ✅ 배너용 accessToken 상태 추가

  // ✅ 공통 Dio 인스턴스 (여러 위젯에서 재사용)
  final Dio _dio = Dio(
    BaseOptions(baseUrl: "https://chackchack.shop"),
  );

  Future<void> _loadMyWorkPlace() async {
    try {
      final token = await ServerTokenManager.getValidAccessToken();
      if (token == null) return;

      final response = await _dio.get(
        "/api/work-places/me",
        options: Options(
          headers: {
            "Authorization": "Bearer $token",
          },
        ),
      );

      final List workPlaces = response.data["workPlaces"] ?? [];

      if (workPlaces.isEmpty) {
        debugPrint("workPlaces empty");
        return;
      }

      final workPlace = workPlaces.first;

      final int? id = workPlace["workPlaceId"];
      final String name = (workPlace["name"] ?? "").toString();

      if (id == null) {
        debugPrint("workPlaceId null");
        return;
      }

      final prefs = await SharedPreferences.getInstance();

      await prefs.setInt("selectedWorkPlaceId", id);
      await prefs.setString("selectedWorkPlaceName", name);

      if (!mounted) return;

      setState(() {
        workPlaceId = id;
        workPlaceName = name;
        accessToken = token; // ✅ 배너에 넘길 토큰 저장
      });

      debugPrint("근무지 로딩 성공: $id / $name");
    } catch (e) {
      debugPrint("workPlace 로딩 실패: $e");
    }
  }

  @override
  void initState() {
    super.initState();
    _checkTokens();
    _loadMyWorkPlace();
  }

  /// 토큰 저장 여부 확인 로그
  Future<void> _checkTokens() async {
    try {
      final access = await ServerTokenManager.getAccessToken();
      final refresh = await ServerTokenManager.getRefreshToken();

      debugPrint("==============================");
      debugPrint("EHomePage TOKEN CHECK");
      debugPrint("ACCESS  : $access");
      debugPrint("REFRESH : $refresh");
      debugPrint("==============================");
    } catch (e) {
      debugPrint("토큰 확인 중 오류: $e");
    }
  }

  /// 월요일~일요일 기준 남은 일수
  int get daysLeft {
    final now = DateTime.now();
    return 8 - now.weekday;
  }

  static const HomeCardType? debugCardType = HomeCardType.weeklySchedule;

  HomeCardType get cardType {
    if (debugCardType != null) {
      return debugCardType!;
    }
    return HomeCardType.none;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F7),
      bottomNavigationBar: BottomNavBar(
        currentIndex: 0,
        onTap: (index) {
          if (index == 1) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ECrewPage()),
            );
          } else if (index == 2) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const EMainSchedulePage()),
            );
          } else if (index == 4) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const EMyPage()),
            );
          }
        },
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 30,
          ),
          child: Column(
            children: [
              /// Header
              EHomeHeader(
                workPlaceName: workPlaceName,
              ),
              const SizedBox(height: 20),

              /// Notice
              if (workPlaceId != null && accessToken != null)
                ENoticeBanner(
                  workPlaceId: workPlaceId!,
                  accessToken: accessToken!,
                  dio: _dio,
                )
              else
                const SizedBox.shrink(), // 로딩 전엔 배너 숨김 (필요 시 스켈레톤으로 교체 가능)
              const SizedBox(height: 16),

              /// Schedule Card
              if (isCardVisible)
                EScheduleCard(
                  type: cardType,
                  daysLeft: daysLeft,
                  onClose: () {
                    setState(() {
                      isCardVisible = false;
                    });
                  },
                  onDetailTap: () {
                    switch (cardType) {
                      case HomeCardType.weeklySchedule:
                        if (workPlaceId == null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text("근무지 정보를 불러오는 중입니다. 잠시 후 다시 시도해주세요.")),
                          );
                          break;
                        }
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => ESubmitSchedulePage(workPlaceId: workPlaceId!),
                          ),
                        );
                        break;
                      default:
                        break;
                    }
                  },
                ),
              const SizedBox(height: 14),

              /// CheckIn Card
              const ECheckInCard(),
              const SizedBox(height: 14),

              /// Calendar
              EHomeCalendar(
                focusedDay: focusedDay,
                selectedDay: selectedDay,
                onDaySelected: (selected, focused) {
                  setState(() {
                    selectedDay = selected;
                    focusedDay = focused;
                  });
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}