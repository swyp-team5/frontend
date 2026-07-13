import 'package:chack_chack/employee/crews/ECrewFirstPage.dart';
import 'package:chack_chack/employee/home/schedule/ESubmitSchedulePage.dart';
import 'package:chack_chack/employee/home/widgets/ECheckInCard.dart';
import 'package:chack_chack/employee/home/widgets/EHomeCalendar.dart';
import 'package:chack_chack/employee/home/widgets/EHomeHeader.dart';
import 'package:chack_chack/employee/home/widgets/ENoticeBanner.dart';
import 'package:chack_chack/employee/home/widgets/EScheduleCard.dart';
import 'package:chack_chack/employee/mypage/EMyPage.dart';
import 'package:chack_chack/employee/schedule/EMainSchedulePage.dart';
import 'package:chack_chack/common/fcm/AlarmListPage.dart';
import 'package:chack_chack/common/fcm/providers/AlarmProvider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../common/auth/server_token_manager.dart';
import '../../common/widgets/BottomNavBar.dart';
import '../crews/ECrewPage.dart';
import '../crews/model/ConfirmedSchedule.dart';
import '../crews/api/WorkChangeTargetsApi.dart';
import 'api/WorkChangeRequestListApi.dart';
import 'model/AssignmentResolver.dart';

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

  String workPlaceName = "";
  int? workPlaceId;
  String? accessToken; // 배너용 accessToken 상태 추가

  /// 대타 신청 카드용 id (requestType == SUBSTITUTE)
  int? substituteWorkChangeRequestId;

  /// 교대 신청 카드용 id (requestType == SHIFT_SWAP)
  int? shiftWorkChangeRequestId;

  /// 대타 신청 카드에 표시할 실제 근무 날짜/시간
  // (SubstituteRequest 상세 화면의 targetDate/targetTime과 동일한 값)
  String? substituteDateLabel;
  String? substituteTimeLabel;

  /// 교대 신청 카드에 표시할 실제 근무 날짜/시간
  // (ExchangeRequest 상세 화면의 _applicantDate/_applicantTime, _myDate/_myTime과 동일한 값)
  String? applicantDateLabel;
  String? applicantTimeLabel;
  String? myDateLabel;
  String? myTimeLabel;

  /// 카드별로 닫혔는지 여부 (개발용: 6개 타입 전부 보여주기 위해 단일 bool 대신 Set 사용)
  final Set<HomeCardType> hiddenCardTypes = {};

  Set<DateTime> workedDates = {};

  /// 슬라이드 카드용 컨트롤러 & 현재 페이지 인덱스
  final PageController _scheduleCardPageController = PageController();
  int _currentSchedulePage = 0;

  /// 공통 Dio 인스턴스 (여러 위젯에서 재사용)
  final Dio _dio = Dio(
    BaseOptions(baseUrl: "https://chackchack.shop"),
  );

  final WorkChangeRequestListApi _workChangeRequestApi =
  WorkChangeRequestListApi();

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

      /// 이 계정이 소속된 근무지 전체 목록을 확인하기 위한 로그
      debugPrint(
        "[EHomePage] /api/work-places/me 응답 workPlaces(${workPlaces.length}개): "
            "$workPlaces",
      );

      if (workPlaces.isEmpty) {
        debugPrint("workPlaces empty");
        return;
      }

      /// 근무지가 여러 개일 수 있으므로, 무조건 first를 쓰지 않고
      //    이전에 선택해둔 근무지(selectedWorkPlaceId)가 있으면 그걸 우선 사용한다.
      final prefs = await SharedPreferences.getInstance();
      final int? savedWorkPlaceId = prefs.getInt("selectedWorkPlaceId");

      debugPrint(
        "[EHomePage] SharedPreferences에 저장된 selectedWorkPlaceId: $savedWorkPlaceId",
      );

      Map<String, dynamic> workPlace;

      if (savedWorkPlaceId != null) {
        final matched = workPlaces.firstWhere(
              (w) => w["workPlaceId"] == savedWorkPlaceId,
          orElse: () => null,
        );

        if (matched != null) {
          workPlace = matched as Map<String, dynamic>;
          debugPrint(
            "[EHomePage] 저장된 workPlaceId($savedWorkPlaceId)와 일치하는 근무지를 사용합니다.",
          );
        } else {
          // 저장된 id가 더 이상 이 계정의 근무지 목록에 없으면 첫 번째로 폴백
          workPlace = workPlaces.first as Map<String, dynamic>;
          debugPrint(
            "[EHomePage] 저장된 workPlaceId($savedWorkPlaceId)가 목록에 없어 "
                "첫 번째 근무지로 대체합니다.",
          );
        }
      } else {
        workPlace = workPlaces.first as Map<String, dynamic>;
        debugPrint("[EHomePage] 저장된 선택값이 없어 첫 번째 근무지를 사용합니다.");
      }

      final int? id = workPlace["workPlaceId"];
      final String name = (workPlace["name"] ?? "").toString();

      if (id == null) {
        debugPrint("workPlaceId null");
        return;
      }

      await prefs.setInt("selectedWorkPlaceId", id);
      await prefs.setString("selectedWorkPlaceName", name);

      if (!mounted) return;

      setState(() {
        workPlaceId = id;
        workPlaceName = name;
        accessToken = token; // 배너에 넘길 토큰 저장
      });

      debugPrint("근무지 로딩 성공: $id / $name");

      // workPlaceId가 확정된 뒤에 요청 카드용 데이터도 로딩
      _loadWorkChangeRequestCards(id);
    } catch (e) {
      debugPrint("workPlace 로딩 실패: $e");
    }
  }

  /// 홈 카드(교대 신청 / 대타 신청)에 표시할 workChangeRequestId를 가져옵니다.
  /// 아직 처리되지 않은(REQUESTED) 요청 목록을 한 번 조회한 뒤,
  /// SHIFT_SWAP과 SUBSTITUTE 타입별로 가장 최근 것을 각각 골라 저장합니다.
  Future<void> _loadWorkChangeRequestCards(int workPlaceId) async {
    try {
      // 이 카드들은 수락/거절 액션(RECEIVED)으로 이어지는 카드라서
      // "내가 받은 요청" 기준으로 조회합니다.
      final result = await _workChangeRequestApi.fetchRequests(
        workPlaceId: workPlaceId,
        scope: "RECEIVED",
        page: 0,
        size: 20,
      );

      debugPrint(
        "[EHomePage] work-change-requests 응답 ${result.content.length}건 "
            "(workPlaceId: $workPlaceId, scope: RECEIVED)",
      );

      final pendingSubstitute = result.content.where(
            (e) => e.requestType == "SUBSTITUTE" && e.status == "REQUESTED",
      );

      final pendingShiftSwap = result.content.where(
            (e) => e.requestType == "SHIFT_SWAP" && e.status == "REQUESTED",
      );

      if (!mounted) return;

      setState(() {
        substituteWorkChangeRequestId = pendingSubstitute.isNotEmpty
            ? pendingSubstitute.first.workChangeRequestId
            : null;
        shiftWorkChangeRequestId = pendingShiftSwap.isNotEmpty
            ? pendingShiftSwap.first.workChangeRequestId
            : null;

        // 요청이 바뀌었으니 이전 카드에 남아있던 날짜/시간 라벨은 일단 초기화
        substituteDateLabel = null;
        substituteTimeLabel = null;
        applicantDateLabel = null;
        applicantTimeLabel = null;
        myDateLabel = null;
        myTimeLabel = null;
      });

      debugPrint(
        "[EHomePage] 대타 요청 카드용 id 로딩 성공: $substituteWorkChangeRequestId",
      );
      debugPrint(
        "[EHomePage] 교대 요청 카드용 id 로딩 성공: $shiftWorkChangeRequestId",
      );

      /// 대타 요청 카드에 표시할 실제 근무 날짜/시간 조회
      if (pendingSubstitute.isNotEmpty) {
        _loadSubstituteScheduleLabels(
          workPlaceId: workPlaceId,
          request: pendingSubstitute.first,
        );
      }

      /// 교대 요청 카드에 표시할 실제 근무 날짜/시간 조회
      if (pendingShiftSwap.isNotEmpty) {
        _loadShiftScheduleLabels(
          workPlaceId: workPlaceId,
          request: pendingShiftSwap.first,
        );
      }
    } catch (e) {
      debugPrint("[EHomePage] 요청 카드 로딩 실패: $e");
    }
  }

  /// SubstituteRequest 상세 화면(_load)과 동일한 방식으로,
  /// 대타 요청의 실제 근무 날짜/시간을 조회해 EScheduleCard에 표시할
  /// substituteDateLabel/substituteTimeLabel을 채운다.
  ///
  /// SUBSTITUTE 타입은 targetAssignmentId가 없으므로 requestAssignmentId(대타 근무 자체)를
  /// 그대로 사용한다. (SubstituteRequest._load()의 targetSide 로직과 동일)
  Future<void> _loadSubstituteScheduleLabels({
    required int workPlaceId,
    required dynamic request,
  }) async {
    try {
      final createdAt = DateTime.parse(request.createdAt as String);
      final (fromDate, toDate) =
      AssignmentResolver.defaultRangeAround(createdAt);

      final assignmentMap = await AssignmentResolver.buildAssignmentMap(
        workPlaceId: workPlaceId,
        fromDate: fromDate,
        toDate: toDate,
      );

      final requestSide = request.requestAssignmentId != null
          ? assignmentMap[request.requestAssignmentId]
          : null;

      final targetSide = request.targetAssignmentId != null
          ? assignmentMap[request.targetAssignmentId]
          : requestSide;

      if (!mounted) return;

      setState(() {
        substituteDateLabel = targetSide?.dateLabel ?? requestSide?.dateLabel;
        substituteTimeLabel = targetSide?.timeLabel ?? requestSide?.timeLabel;
      });

      debugPrint(
        "[EHomePage] 대타 카드 날짜/시간 로딩 성공: "
            "$substituteDateLabel $substituteTimeLabel",
      );
    } catch (e) {
      debugPrint("[EHomePage] 대타 카드 날짜/시간 로딩 실패: $e");
    }
  }

  /// ExchangeRequest 상세 화면(_fetchAssignmentTimes)과 동일한 방식으로,
  /// 교대 요청의 신청자 근무 / 내 근무 날짜·시간을 조회해 EScheduleCard에 표시할
  /// applicantDateLabel/applicantTimeLabel, myDateLabel/myTimeLabel을 채운다.
  ///
  /// SHIFT_SWAP은 requestAssignmentId(신청자 근무)와 targetAssignmentId(내 근무)가
  /// 서로 다른 두 근무이므로 각각 별도로 매핑한다.
  Future<void> _loadShiftScheduleLabels({
    required int workPlaceId,
    required dynamic request,
  }) async {
    try {
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final createdAt =
          DateTime.tryParse(request.createdAt as String) ?? now;
      final createdDate =
      DateTime(createdAt.year, createdAt.month, createdAt.day);

      final fromDate = createdDate.isBefore(today) ? today : createdDate;
      final toDate = fromDate.add(const Duration(days: 60));

      final targets = await WorkChangeTargetsApi.fetchWorkers(
        workPlaceId: workPlaceId,
        fromDate: _formatDate(fromDate),
        toDate: _formatDate(toDate),
      );

      final Map<int, _AssignmentTimeInfo> assignmentMap = {};
      for (final day in targets.days) {
        for (final timeDetail in day.timeDetails) {
          for (final worker in timeDetail.workers) {
            assignmentMap[worker.assignmentId] = _AssignmentTimeInfo(
              date: day.workDate,
              timeName: timeDetail.timeName,
              startTime: timeDetail.startTime,
              closeTime: timeDetail.closeTime,
            );
          }
        }
      }

      final applicantInfo = request.requestAssignmentId != null
          ? assignmentMap[request.requestAssignmentId]
          : null;

      // SUBSTITUTE와 달리 SHIFT_SWAP은 서로 다른 근무를 맞바꾸는 것이므로
      // targetAssignmentId가 없는 경우에는 폴백하지 않고 그대로 null 처리한다.
      final myInfo = request.targetAssignmentId != null
          ? assignmentMap[request.targetAssignmentId]
          : null;

      if (!mounted) return;

      setState(() {
        applicantDateLabel = applicantInfo?.dateLabel;
        applicantTimeLabel = applicantInfo?.timeLabel;
        myDateLabel = myInfo?.dateLabel;
        myTimeLabel = myInfo?.timeLabel;
      });

      debugPrint(
        "[EHomePage] 교대 카드 날짜/시간 로딩 성공: "
            "신청자=$applicantDateLabel $applicantTimeLabel, "
            "나=$myDateLabel $myTimeLabel",
      );
    } catch (e) {
      debugPrint("[EHomePage] 교대 카드 날짜/시간 로딩 실패: $e");
    }
  }

  String _formatDate(DateTime date) {
    final y = date.year.toString().padLeft(4, '0');
    final m = date.month.toString().padLeft(2, '0');
    final d = date.day.toString().padLeft(2, '0');
    return "$y-$m-$d";
  }

  Future<void> _loadConfirmedSchedules() async {
    try {
      final token = await ServerTokenManager.getValidAccessToken();
      if (token == null) return;

      final now = focusedDay;

      final from =
          "${now.year}-${now.month.toString().padLeft(2, '0')}-01";

      final lastDay =
          DateTime(now.year, now.month + 1, 0).day;

      final to =
          "${now.year}-${now.month.toString().padLeft(2, '0')}-${lastDay.toString().padLeft(2, '0')}";

      final response = await _dio.get(
        "/api/me/confirmed-schedules",
        queryParameters: {
          "from": from,
          "to": to,
        },
        options: Options(
          headers: {
            "Authorization": "Bearer $token",
          },
        ),
      );

      final result = ConfirmedScheduleResponse.fromJson(response.data);

      if (!mounted) return;

      setState(() {
        workedDates = result.schedules
            .map(
              (e) => DateTime(
            e.workDate.year,
            e.workDate.month,
            e.workDate.day,
          ),
        )
            .toSet();
      });

      debugPrint("근무 날짜 : $workedDates");
    } catch (e) {
      debugPrint("근무 일정 조회 실패 : $e");
    }
  }

  @override
  void initState() {
    super.initState();

    _checkTokens();
    _loadMyWorkPlace();
    _loadConfirmedSchedules();

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

  //==========================================================
  // 개발용: 6개 HomeCardType(=none 제외) 전부 렌더링
  //==========================================================
  static const List<HomeCardType> _allCardTypes = [
    HomeCardType.weeklySchedule,
    HomeCardType.scheduleCompleted,
    HomeCardType.scheduleChanged,
    HomeCardType.shiftRequest,
    HomeCardType.substituteRequest,
    HomeCardType.ownerWorkRequest,
  ];

  /// 카드 타입에 맞는 workChangeRequestId를 반환합니다.
  /// shiftRequest -> 교대(SHIFT_SWAP)용 id, substituteRequest -> 대타(SUBSTITUTE)용 id,
  /// 그 외 타입은 workChangeRequestId가 필요 없으므로 null.
  int? _workChangeRequestIdFor(HomeCardType type) {
    switch (type) {
      case HomeCardType.shiftRequest:
        return shiftWorkChangeRequestId;
      case HomeCardType.substituteRequest:
        return substituteWorkChangeRequestId;
      default:
        return null;
    }
  }

  void _handleDetailTap(HomeCardType type) {
    switch (type) {
      case HomeCardType.weeklySchedule:
        if (workPlaceId == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("근무지 정보를 불러오는 중입니다. 잠시 후 다시 시도해주세요."),
            ),
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
  }

  @override
  Widget build(BuildContext context) {
    /// 실제로 화면에 보여줄 카드 타입들 (닫힌 카드는 제외)
    final visibleCardTypes = _allCardTypes.where((type) {
      if (hiddenCardTypes.contains(type)) return false;

      /// 교대/대타 신청 카드는 실제 요청(id)이 있을 때만 슬라이드에 포함
      //    (값이 없으면 리스트에서 아예 제외해 빈 슬라이드가 보이지 않도록 함)
      if (type == HomeCardType.shiftRequest) {
        return shiftWorkChangeRequestId != null;
      }
      if (type == HomeCardType.substituteRequest) {
        return substituteWorkChangeRequestId != null;
      }

      return true;
    }).toList();

    /// 카드가 닫혀서 개수가 줄었을 때 PageView 인덱스가 범위를 벗어나지 않도록 보정
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
              MaterialPageRoute(builder: (_) => const ECrewPage()),
            );
          } else if (index == 2) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const EMainSchedulePage()),
            );
          } else if (index == 3) {
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
              Consumer(
                builder: (context, ref, _) {
                  final hasUnread = ref.watch(
                    alarmListProvider.select((s) => s.hasUnread),
                  );
                  return EHomeHeader(
                    workPlaceName: workPlaceName,
                    hasUnread: hasUnread,
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
              if (workPlaceId != null && accessToken != null)
                ENoticeBanner(
                  workPlaceId: workPlaceId!,
                  accessToken: accessToken!,
                  dio: _dio,
                )
              else
                const SizedBox.shrink(), // 로딩 전엔 배너 숨김 (필요 시 스켈레톤으로 교체 가능)
              const SizedBox(height: 20),

              /// Schedule Cards (한 위치에서 좌우로 넘기는 슬라이드 형식)
              if (visibleCardTypes.isNotEmpty) ...[
                SizedBox(
                  // EScheduleCard의 실제 디자인 높이에 맞춰 이 값을 조정
                  height: 140,
                  child: PageView.builder(
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
                        child: EScheduleCard(
                          type: type,
                          daysLeft: daysLeft,
                          workPlaceId: workPlaceId,
                          workChangeRequestId: _workChangeRequestIdFor(type),
                          substituteDateLabel:
                          type == HomeCardType.substituteRequest
                              ? substituteDateLabel
                              : null,
                          substituteTimeLabel:
                          type == HomeCardType.substituteRequest
                              ? substituteTimeLabel
                              : null,
                          applicantDateLabel: type == HomeCardType.shiftRequest
                              ? applicantDateLabel
                              : null,
                          applicantTimeLabel: type == HomeCardType.shiftRequest
                              ? applicantTimeLabel
                              : null,
                          myDateLabel: type == HomeCardType.shiftRequest
                              ? myDateLabel
                              : null,
                          myTimeLabel: type == HomeCardType.shiftRequest
                              ? myTimeLabel
                              : null,
                          onClose: () {
                            setState(() {
                              hiddenCardTypes.add(type);

                              // 마지막 카드를 닫은 경우 인덱스가 범위를 벗어나지 않도록 보정
                              final remaining = visibleCardTypes.length - 1;
                              if (_currentSchedulePage > remaining - 1 &&
                                  _currentSchedulePage > 0) {
                                _currentSchedulePage--;
                              }
                            });
                          },
                          onDetailTap: () => _handleDetailTap(type),
                        ),
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

                const SizedBox(height: 20),
              ],

              // /// CheckIn Card
              // const ECheckInCard(),
              // const SizedBox(height: 14),

              /// Calendar
              EHomeCalendar(
                focusedDay: focusedDay,
                selectedDay: selectedDay,
                workedDates: workedDates,
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

/// assignmentId 하나에 대응하는 근무 날짜/시간 정보
/// (ExchangeRequest.dart의 _AssignmentTimeInfo와 동일한 역할, EHomePage 전용)
class _AssignmentTimeInfo {
  final DateTime date;
  final String timeName;
  final String startTime;
  final String closeTime;

  _AssignmentTimeInfo({
    required this.date,
    required this.timeName,
    required this.startTime,
    required this.closeTime,
  });

  String get dateLabel => "${date.month}월 ${date.day}일";

  String get timeLabel {
    final start = _trimSeconds(startTime);
    final close = _trimSeconds(closeTime);
    return "$timeName $start~$close";
  }

  static String _trimSeconds(String t) => t.length >= 5 ? t.substring(0, 5) : t;
}