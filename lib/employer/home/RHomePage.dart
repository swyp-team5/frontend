import 'dart:convert';

import 'package:chack_chack/common/employer/RAutoScheduling.dart';
import 'package:chack_chack/common/fcm/AlarmListPage.dart';
import 'package:chack_chack/common/fcm/providers/AlarmProvider.dart';
import 'package:chack_chack/employer/home/notification/RNotificationPage.dart';
import 'package:chack_chack/employer/home/schedule/RMakingSchedulePage.dart';
import 'package:chack_chack/employer/home/schedule/RRecentSchedulePage.dart';
import 'package:chack_chack/employer/home/schedule/api/ScheduleApiService.dart';
import 'package:chack_chack/employer/home/widgets/RAutoScheduleBottomSheet.dart';
import 'package:chack_chack/employer/home/widgets/RHomeHeader.dart';
import 'package:chack_chack/employer/home/widgets/RNoticeBanner.dart';
import 'package:chack_chack/employer/home/widgets/RNoticeWriteCard.dart';
import 'package:chack_chack/employer/home/widgets/RRequestListCard.dart';
import 'package:chack_chack/employer/home/widgets/RScheduleCard.dart';
import 'package:chack_chack/employer/home/widgets/RTodayWorkCard.dart';
import 'package:chack_chack/employer/home/widgets/RWorkChangeRequestListPage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import '../../common/auth/server_token_manager.dart';
import '../../common/workplace/selected_work_place_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../common/widgets/BottomNavBar.dart';
import '../crews/RCrewPage.dart';
import '../mypage/RMyPage.dart';
import '../mypage/RTodayWorkingPage.dart';
import '../mypage/RWorkPlaceSettingPage.dart';
import '../schedule/RMainSchedulePage.dart';
import 'api/SubmitStatusApi.dart';

enum HomeCardType {
  none,

  /// 스케줄
  weeklySchedule,
  scheduleCreationAvailable,
  submissionStatus,
}

class RHomePage extends StatefulWidget {
  const RHomePage({super.key});

  @override
  State<RHomePage> createState() => _RHomePageState();
}

class _RHomePageState extends State<RHomePage> {
  /// 카드별로 닫힘 여부를 관리 (여러 장 동시 표시를 위해 Set으로 관리)
  final Set<HomeCardType> closedCardTypes = {};

  List<Map<String, dynamic>> stores = [];

  int? selectedWorkPlaceId;
  String selectedStoreName = "";
  String? accessToken;

  /// schedule-conditions POST 성공 시 저장된 활성 weekScheduleId
  int? weekScheduleId;

  int? notSubmittedCount;

  DateTime? dueDate;

  // 슬라이드 카드용 컨트롤러 & 현재 페이지 인덱스
  final PageController _scheduleCardPageController = PageController();
  int _currentSchedulePage = 0;

  // 공통 Dio 인스턴스 (baseUrl 지정 필수)
  Dio get _dio => ServerTokenManager.authorizedDio;

  /// 카드에서 사용할 남은 일수
  int get daysLeft {
    if (dueDate == null) return 0;

    final now = DateTime.now();

    final today = DateTime(now.year, now.month, now.day);
    final end = DateTime(
      dueDate!.year,
      dueDate!.month,
      dueDate!.day,
    );

    final diff = end.difference(today).inDays;

    return diff < 0 ? 0 : diff;
  }

  void _RshowStoreBottomSheet(BuildContext context) {
    int? tempSelectedWorkPlaceId = selectedWorkPlaceId;

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
                    /// 핸들
                    Container(
                      width: 42,
                      height: 5,
                      decoration: BoxDecoration(
                        color: const Color(0xFFD9D9D9),
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

                    ...stores.map((store) {
                      final selected =
                          store["workPlaceId"] == tempSelectedWorkPlaceId;

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(18),
                          onTap: () {
                            setModalState(() {
                              tempSelectedWorkPlaceId =
                              store["workPlaceId"];
                            });
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 22,
                            ),
                            decoration: BoxDecoration(
                              color: selected
                                  ? const Color(0xFFE6F3FF)
                                  : const Color(0xFFF5F5F7),
                              borderRadius: BorderRadius.circular(12),
                              border: selected
                                  ? Border.all(
                                color: const Color(0xFF0084FF),
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

                    /// 매장 설정 이동 버튼
                    Align(
                      alignment: Alignment.center,
                      child: GestureDetector(
                        onTap: () {
                          Navigator.pop(context);
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const RWorkPlaceSettingPage(),
                            ),
                          );
                        },
                        child: const Padding(
                          padding: EdgeInsets.symmetric(vertical: 4),
                          child: Text(
                            "매장 설정 >",
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: Color(0xFF767676),
                            ),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 12),

                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: () async {
                          final selectedStore = stores.firstWhere(
                                (e) =>
                            e["workPlaceId"] ==
                                tempSelectedWorkPlaceId,
                          );

                          await SelectedWorkPlaceStorage.save(
                            selectedStore["workPlaceId"],
                          );

                          // ✅ 추가: 다른 화면(RNotificationPage 등)이 SharedPreferences로
                          // workPlaceId를 직접 읽기 때문에 이 키도 함께 갱신해야
                          // 다른 페이지를 들르지 않아도 즉시 반영됨
                          final prefs = await SharedPreferences.getInstance();
                          await prefs.setInt(
                            "selectedWorkPlaceId",
                            selectedStore["workPlaceId"],
                          );

                          if (!mounted || !context.mounted) {
                            return;
                          }

                          setState(() {
                            selectedWorkPlaceId =
                            selectedStore["workPlaceId"];
                            selectedStoreName =
                            selectedStore["name"];
                          });

                          Navigator.pop(context);

                          // 매장이 바뀌었으니 해당 매장의 weekScheduleId, 제출 현황도 다시 조회
                          // (대표 공지는 RNoticeBanner가 workPlaceId 변경을 감지해 자동으로 다시 불러옴)
                          await _loadWeekScheduleId();
                          await _loadSubmitStatus(); // ✅ 추가
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                          const Color(0xFF0084FF),
                          shape: RoundedRectangleBorder(
                            borderRadius:
                            BorderRadius.circular(8),
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

  //==========================================================
  // 개발용
  //==========================================================

  /// 여러 장을 동시에 보여주고 싶은 카드 타입 목록
  static const List<HomeCardType> debugCardTypes = [
    HomeCardType.weeklySchedule,
    HomeCardType.scheduleCreationAvailable,
    HomeCardType.submissionStatus,
  ];

  // static const List<HomeCardType> debugCardTypes = [];

  //==========================================================
  // 실제 카드 타입 (모두 표시)
  //==========================================================

  List<HomeCardType> get cardTypes {
    if (debugCardTypes.isNotEmpty) {
      return debugCardTypes;
    }

    /// TODO : API 연결

    return [];
  }

  /// RMakingSchedulePage로 이동 후 돌아오면 weekScheduleId를 다시 조회
  Future<void> _goToMakingSchedule() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => RMakingSchedulePage(
          workPlaceId: selectedWorkPlaceId!,
        ),
      ),
    );

    await _loadWeekScheduleId();
  }

  /// RRecentSchedulePage로 이동 후 돌아오면 weekScheduleId를 다시 조회
  Future<void> _goToRecentSchedule() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => RRecentSchedulePage(
          workPlaceId: selectedWorkPlaceId!,
        ),
      ),
    );

    await _loadWeekScheduleId();
  }

  /// 제출 현황(미제출 인원 수) 조회
  Future<void> _loadSubmitStatus() async {
    if (selectedWorkPlaceId == null || weekScheduleId == null) {
      debugPrint("[_loadSubmitStatus] workPlaceId 또는 weekScheduleId가 없어서 조회 스킵");
      return;
    }

    try {
      final status = await SubmitStatusApi.getStatus(
        workPlaceId: selectedWorkPlaceId!,
        weekScheduleId: weekScheduleId!,
      );

      if (!mounted) return;

      setState(() {
        notSubmittedCount = status.notSubmittedCount;
      });

      debugPrint("notSubmittedCount = $notSubmittedCount");
    } catch (e) {
      debugPrint("[_loadSubmitStatus] 조회 실패: $e");
    }
  }

  void _showScheduleBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) {
        return SafeArea(
          child: Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Center(
                  child: Container(
                    width: 48,
                    height: 5,
                    decoration: BoxDecoration(
                      color: const Color(0xFFD9D9D9),
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                const Column(
                  children: [
                    Text(
                      "최근 기록 불러오기",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      "최근에 작성했던 스케줄 상세 내용을\n불러올 수 있어요",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF767676),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 32),

                /// 불러오기 버튼
                SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      _goToRecentSchedule();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0084FF),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: const Text(
                      "불러오기",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                /// 직접 만들기 버튼
                SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: OutlinedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      _goToMakingSchedule();
                    },
                    style: OutlinedButton.styleFrom(
                      backgroundColor: Colors.white,
                      side: const BorderSide(
                        color: Color(0xFFE0E0E0),
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: const Text(
                      "직접 만들기",
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
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
  }

  Future<void> _loadWorkPlaces() async {
    try {
      final token = await ServerTokenManager.getValidAccessToken();
      debugPrint("HOME TOKEN = $token");
      if (token == null || token.isEmpty) {
        debugPrint("토큰 없음");
        return;
      }

      final response = await _dio.get("/api/work-places/me");

      debugPrint("========== /work-places/me ==========");
      debugPrint("statusCode = ${response.statusCode}");
      debugPrint(const JsonEncoder.withIndent("  ").convert(response.data));
      debugPrint("=====================================");

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
        accessToken = token;

        if (selectedStore != null) {
          selectedWorkPlaceId = selectedStore["workPlaceId"];
          selectedStoreName = selectedStore["name"];

          debugPrint("selectedWorkPlaceId = $selectedWorkPlaceId");
          debugPrint("selectedStoreName = $selectedStoreName");
        }
      });

      // ✅ 최초 로드된 근무지도 SharedPreferences에 반영
      // (RNotificationPage 등 다른 화면에서 SharedPreferences로 workPlaceId를 읽기 때문)
      if (selectedWorkPlaceId != null) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setInt("selectedWorkPlaceId", selectedWorkPlaceId!);
        debugPrint("SharedPreferences에 selectedWorkPlaceId 저장 완료: $selectedWorkPlaceId");
      }
    } on DioException catch (e) {
      debugPrint("===== DioException =====");
      debugPrint("status = ${e.response?.statusCode}");
      debugPrint("body = ${e.response?.data}");
    } catch (e, stackTrace) {
      debugPrint("===== Exception =====");
      debugPrint(e.toString());
      debugPrint(stackTrace.toString());
    }
  }

  /// schedule-conditions POST 성공 시 SharedPreferences에 저장해둔
  /// 활성 weekScheduleId를 불러온다.
  Future<void> _loadWeekScheduleId() async {
    if (selectedWorkPlaceId == null) {
      debugPrint("[_loadWeekScheduleId] selectedWorkPlaceId가 없어서 조회 스킵");
      return;
    }

    try {
      final latest =
      await ScheduleApiService.getLatestScheduleConditions(
        workPlaceId: selectedWorkPlaceId!,
      );

      setState(() {
        weekScheduleId = latest?.weekScheduleId;

        if (latest?.dueDate != null) {
          dueDate = DateTime.parse(latest!.dueDate);
        } else {
          dueDate = null;
        }
      });

      debugPrint("weekScheduleId (API) = $weekScheduleId");
    } catch (e) {
      debugPrint("[_loadWeekScheduleId] 조회 실패: $e");
    }
  }

  @override
  void initState() {
    super.initState();
    _init();

    // 홈 진입 시 알림함을 한 번 조회해서, 종 아이콘에 미확인 배지를 띄울 수 있게 한다.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ProviderScope.containerOf(context, listen: false)
          .read(alarmListProvider.notifier)
          .fetchFirstPage();
    });
  }

  @override
  void dispose() {
    _scheduleCardPageController.dispose();
    super.dispose();
  }

  /// ✅ _init()은 이 하나만 유지 (중복 제거)
  Future<void> _init() async {
    final access = await ServerTokenManager.getAccessToken();
    final refresh = await ServerTokenManager.getRefreshToken();

    debugPrint("===============");
    debugPrint("ACCESS = $access");
    debugPrint("REFRESH = $refresh");
    debugPrint("===============");

    await _loadWorkPlaces();
    await _loadWeekScheduleId();
    await _loadSubmitStatus();
  }

  /// 특정 타입의 카드 onMakeScheduleTap 처리
  void _onMakeScheduleTap(HomeCardType type) {
    switch (type) {
    /// 제출 기간 (최근 기록 불러오기 BottomSheet)
      case HomeCardType.weeklySchedule:
        _showScheduleBottomSheet(context);
        break;

    /// 제출 완료 → 자동 스케줄 안내 BottomSheet
      case HomeCardType.scheduleCreationAvailable:
        if (selectedWorkPlaceId == null || weekScheduleId == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                "스케줄 정보를 불러오는 중입니다. 잠시 후 다시 시도해주세요.",
              ),
            ),
          );
          break;
        }

        showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
          builder: (_) => RAutoScheduleBottomSheet(
            workPlaceId: selectedWorkPlaceId!,
            weekScheduleId: weekScheduleId!,
          ),
        );
        break;

    /// 제출 현황 — RScheduleCard 내부에서
    /// workPlaceId/weekScheduleId로 RSubmitStatusPage 이동 처리
      case HomeCardType.submissionStatus:
        break;

      case HomeCardType.none:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    /// 실제로 화면에 보여줄 카드 타입들 (닫힌 카드는 제외)
    final visibleCardTypes = cardTypes
        .where((type) =>
    type != HomeCardType.none && !closedCardTypes.contains(type))
        .toList();

    // ✅ 카드가 닫혀서 개수가 줄었을 때 PageView 인덱스가 범위를 벗어나지 않도록 보정
    if (visibleCardTypes.isNotEmpty &&
        _currentSchedulePage > visibleCardTypes.length - 1) {
      _currentSchedulePage = visibleCardTypes.length - 1;
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F7),

      bottomNavigationBar: BottomNavBar(
        currentIndex: 0,
        onTap: (index) {
          if (index == 1) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const RCrewPage(),
              ),
            );
          } else if (index == 2) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => RMainSchedulePage(
                  workPlaceId: selectedWorkPlaceId!,),
              ),
            );
          } else if (index == 3) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const RMyPage(),
              ),
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
              Consumer(
                builder: (context, ref, _) {
                  final hasUnread = ref.watch(
                    alarmListProvider.select((s) => s.hasUnread),
                  );
                  return RHomeHeader(
                    storeName: selectedStoreName,
                    hasUnread: hasUnread,
                    onStoreTap: () {
                      _RshowStoreBottomSheet(context);
                    },
                    onNotificationTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const AlarmListPage(),
                        ),
                      );
                    },
                  );
                },
              ),

              const SizedBox(height: 20),

              /// Notice
              if (selectedWorkPlaceId != null && accessToken != null)
                RNoticeBanner(
                  // ✅ workPlaceId가 바뀌면 위젯을 새로 생성해 즉시 재조회되도록 보강
                  key: ValueKey('notice-$selectedWorkPlaceId'),
                  workPlaceId: selectedWorkPlaceId!,
                  accessToken: accessToken!,
                  dio: _dio,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => RNotificationPage(
                          workPlaceId: selectedWorkPlaceId!,
                        ),
                      ),
                    );
                  },
                )
              else
                const SizedBox.shrink(),

              const SizedBox(height: 16),

              /// Schedule Cards (한 위치에서 좌우로 넘기는 슬라이드 형식)
              if (visibleCardTypes.isNotEmpty) ...[
                SizedBox(
                  // RScheduleCard의 실제 디자인 높이에 맞춰 이 값을 조정
                  height: 230,
                  child: PageView.builder(
                    // ✅ workPlaceId가 바뀌면 PageView 전체를 새로 생성해
                    // 내부 카드들의 데이터를 즉시 갱신
                    key: ValueKey('schedule-pageview-$selectedWorkPlaceId'),
                    controller: _scheduleCardPageController,
                    itemCount: visibleCardTypes.length,
                    onPageChanged: (index) {
                      setState(() {
                        _currentSchedulePage = index;
                      });
                    },
                    itemBuilder: (context, index) {
                      final type = visibleCardTypes[index];
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 2),
                        child: RScheduleCard(
                          key: ValueKey('$type-$selectedWorkPlaceId'),
                          type: type,
                          daysLeft: daysLeft,
                          workPlaceId: selectedWorkPlaceId,
                          weekScheduleId: weekScheduleId,
                          notSubmittedCount: notSubmittedCount,

                          onClose: () {
                            setState(() {
                              closedCardTypes.add(type);

                              final remaining = visibleCardTypes.length - 1;

                              if (_currentSchedulePage > remaining - 1 &&
                                  _currentSchedulePage > 0) {
                                _currentSchedulePage--;
                              }
                            });
                          },

                          onMakeScheduleTap: () => _onMakeScheduleTap(type),
                        )
                      );
                    },
                  ),
                ),

                const SizedBox(height: 10),

                /// 페이지 인디케이터 (카드가 2장 이상일 때만 표시)
                if (visibleCardTypes.length > 1)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(visibleCardTypes.length, (index) {
                      final isActive = index == _currentSchedulePage;
                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        margin: const EdgeInsets.symmetric(horizontal: 3),
                        width: isActive ? 18 : 6,
                        height: 6,
                        decoration: BoxDecoration(
                          color: isActive
                              ? const Color(0xFF0084FF)
                              : const Color(0xFFD9D9D9),
                          borderRadius: BorderRadius.circular(999),
                        ),
                      );
                    }),
                  ),

                const SizedBox(height: 14),
              ],

              /// Notice Write
              RNoticeWriteCard(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => RNotificationPage(
                        workPlaceId: selectedWorkPlaceId!,
                      ),
                    ),
                  );
                },
              ),

              const SizedBox(height: 14),

              /// Today Work
              if (selectedWorkPlaceId != null)
                RTodayWorkCard(
                  // ✅ workPlaceId가 바뀌면 위젯을 새로 생성해 즉시 재조회되도록 보강
                  key: ValueKey('today-work-$selectedWorkPlaceId'),
                  workPlaceId: selectedWorkPlaceId!,
                  onDetailTap: () {
                    // Navigator.push(
                    //   context,
                    //   MaterialPageRoute(
                    //     builder: (_) => RTodayWorkingPage(
                    //       workPlaceId: selectedWorkPlaceId!,
                    //     ),
                    //   ),
                    // );
                  },
                )
              else
                const SizedBox.shrink(),
            ],
          ),
        ),
      ),
    );
  }
}