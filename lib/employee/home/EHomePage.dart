import 'package:chack_chack/employee/crews/ECrewFirstPage.dart';
import 'package:chack_chack/employee/home/schedule/ESubmitSchedulePage.dart';
import 'package:chack_chack/employee/home/schedule/api/CalendarActivateApi.dart';
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

class EHomePage extends ConsumerStatefulWidget {
  const EHomePage({super.key});

  @override
  ConsumerState<EHomePage> createState() => _EHomePageState();
}

class _EHomePageState extends ConsumerState<EHomePage> {
  DateTime focusedDay = DateTime.now();
  DateTime? selectedDay;

  String workPlaceName = "";
  int? workPlaceId;
  String? accessToken; // 배너용 accessToken 상태 추가

  String? dueDate;

  /// ✅ 매장 변경 바텀시트에 표시할 전체 매장 목록
  List<Map<String, dynamic>> stores = [];

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

  /// 카드 타입별로 "닫았을 때의 식별값"을 저장 (SharedPreferences에 문자열로 영속화)
  final Map<HomeCardType, String?> _hiddenCardKeys = {};

  String _hiddenCardPrefKey(HomeCardType type) => 'hiddenHomeCard_${type.name}';

  /// 앱 재시작/페이지 재생성 이후에도 "닫힘" 상태를 복원
  Future<void> _loadHiddenCardKeys() async {
    final prefs = await SharedPreferences.getInstance();
    final Map<HomeCardType, String?> loaded = {};

    for (final type in _allCardTypes) {
      final saved = prefs.getString(_hiddenCardPrefKey(type));
      if (saved != null) {
        loaded[type] = saved;
      }
    }

    if (!mounted) return;
    setState(() {
      _hiddenCardKeys
        ..clear()
        ..addAll(loaded);
    });
  }

  /// 카드를 닫을 때 호출: 현재 식별값을 "닫힘"으로 기록하고 영속화
  Future<void> _hideCard(HomeCardType type, dynamic key) async {
    final str = key?.toString();

    setState(() {
      _hiddenCardKeys[type] = str;
      if (_currentSchedulePage > 0) {
        _currentSchedulePage = 0;
      }
    });

    final prefs = await SharedPreferences.getInstance();
    if (str == null) {
      await prefs.remove(_hiddenCardPrefKey(type));
    } else {
      await prefs.setString(_hiddenCardPrefKey(type), str);
    }
  }

  /// 정렬/식별용: 교대·대타 요청이 "언제" 생성됐는지
  DateTime? _shiftRequestCreatedAt;
  DateTime? _substituteRequestCreatedAt;

  Set<DateTime> workedDates = {};

  /// 슬라이드 카드용 컨트롤러 & 현재 페이지 인덱스
  final PageController _scheduleCardPageController = PageController();
  int _currentSchedulePage = 0;

  /// 공통 Dio 인스턴스 (여러 위젯에서 재사용)
  final Dio _dio = ServerTokenManager.authorizedDio;

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

      final loadedStores = List<Map<String, dynamic>>.from(workPlaces);

      if (workPlaces.isEmpty) {
        debugPrint("workPlaces empty");
        if (mounted) {
          setState(() {
            stores = loadedStores;
          });
        }
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
        stores = loadedStores; // ✅ 매장 변경 바텀시트용 목록 저장
      });

      debugPrint("근무지 로딩 성공: $id / $name");

      // ✅ workPlaceId가 확정된 뒤에 요청 카드 / 근무 일정을 함께 로딩한다.
      // (initState에서 _loadConfirmedSchedules()를 병렬로 호출하면
      //  이 시점보다 먼저 실행되어 workPlaceId가 아직 null인 채로
      //  스킵되는 경쟁 조건이 있었음 — 그래서 여기서 명시적으로 호출)
      await _loadCalendarActivate();
      await _loadWorkChangeRequestCards(id);
      await _loadConfirmedSchedules();
    } catch (e) {
      debugPrint("workPlace 로딩 실패: $e");
    }
  }

  Future<void> _loadCalendarActivate() async {
    if (workPlaceId == null) return;

    try {
      final result = await CalendarActivateApi.getCalendarActivate(
        workPlaceId: workPlaceId!,
      );

      if (!mounted) return;

      setState(() {
        dueDate = result.dueDate;
      });

      debugPrint("마감일 : ${result.dueDate}");
    } catch (e) {
      debugPrint("CalendarActivate 조회 실패 : $e");
    }
  }

  /// ✅ 헤더에서 매장명을 탭했을 때 뜨는 매장 변경 바텀시트
  /// (RHomePage / EMyPage와 동일한 UI 패턴)
  void _EshowStoreBottomSheet(BuildContext context) {
    if (stores.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("매장 목록을 불러오는 중입니다. 잠시 후 다시 시도해주세요.")),
      );
      return;
    }

    int? tempWorkPlaceId = workPlaceId;

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

                    /// 매장 목록
                    ...stores.map((store) {
                      final selected =
                          store["workPlaceId"] == tempWorkPlaceId;

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(18),
                          onTap: () {
                            setModalState(() {
                              tempWorkPlaceId = store["workPlaceId"];
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
                                    store["name"] ?? "",
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
                          final selectedStore = stores.firstWhere(
                                (e) => e["workPlaceId"] == tempWorkPlaceId,
                          );

                          final int newWorkPlaceId =
                          selectedStore["workPlaceId"];
                          final String newWorkPlaceName =
                              selectedStore["name"] ?? "";

                          // ✅ 다른 화면(EMyPage 등)도 참조하는 값이므로
                          // SharedPreferences를 즉시 갱신
                          final prefs = await SharedPreferences.getInstance();
                          await prefs.setInt(
                            "selectedWorkPlaceId",
                            newWorkPlaceId,
                          );
                          await prefs.setString(
                            "selectedWorkPlaceName",
                            newWorkPlaceName,
                          );

                          if (!mounted || !context.mounted) return;

                          setState(() {
                            workPlaceId = newWorkPlaceId;
                            workPlaceName = newWorkPlaceName;

                            // 매장이 바뀌었으니 이전 매장 기준으로 불러온
                            // 요청 카드 데이터는 일단 초기화
                            substituteWorkChangeRequestId = null;
                            shiftWorkChangeRequestId = null;
                            substituteDateLabel = null;
                            substituteTimeLabel = null;
                            applicantDateLabel = null;
                            applicantTimeLabel = null;
                            myDateLabel = null;
                            myTimeLabel = null;
                          });

                          Navigator.pop(context);

                          // ✅ 새 매장 기준으로 요청 카드 / 근무 일정을 즉시 다시 조회
                          await _loadCalendarActivate();
                          await _loadWorkChangeRequestCards(newWorkPlaceId);
                          await _loadConfirmedSchedules();
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

      final pendingSubstituteList = result.content
          .where((e) => e.requestType == "SUBSTITUTE" && e.status == "REQUESTED")
          .toList();

      final pendingShiftSwapList = result.content
          .where((e) => e.requestType == "SHIFT_SWAP" && e.status == "REQUESTED")
          .toList();

      // ✅ 리스트 정렬 순서에 의존하지 않고, createdAt 기준으로 가장 최근 것을 직접 선택
      //    (홈카드 정렬/재노출 판단에 createdAt을 쓰므로, "가장 최근"의 기준을 여기서도
      //     동일하게 맞춰야 함)
      DateTime? _parseCreatedAt(dynamic e) =>
          DateTime.tryParse(e.createdAt as String);

      dynamic _latest(List<dynamic> list) {
        if (list.isEmpty) return null;
        final sorted = [...list]..sort((a, b) {
          final ta = _parseCreatedAt(a);
          final tb = _parseCreatedAt(b);
          if (ta == null && tb == null) return 0;
          if (ta == null) return 1;
          if (tb == null) return -1;
          return tb.compareTo(ta); // 최신이 먼저
        });
        return sorted.first;
      }

      final latestSubstitute = _latest(pendingSubstituteList);
      final latestShiftSwap = _latest(pendingShiftSwapList);

      if (!mounted) return;

      setState(() {
        substituteWorkChangeRequestId = latestSubstitute?.workChangeRequestId;
        shiftWorkChangeRequestId = latestShiftSwap?.workChangeRequestId;

        // ✅ 정렬 / 카드 재노출 판단(같은 건인지 비교)에 쓸 생성 시각 저장
        _substituteRequestCreatedAt =
        latestSubstitute != null ? _parseCreatedAt(latestSubstitute) : null;
        _shiftRequestCreatedAt =
        latestShiftSwap != null ? _parseCreatedAt(latestShiftSwap) : null;

        // 요청이 바뀌었으니 이전 카드에 남아있던 날짜/시간 라벨은 일단 초기화
        substituteDateLabel = null;
        substituteTimeLabel = null;
        applicantDateLabel = null;
        applicantTimeLabel = null;
        myDateLabel = null;
        myTimeLabel = null;
      });

      debugPrint(
        "[EHomePage] 대타 요청 카드용 id 로딩 성공: $substituteWorkChangeRequestId "
            "(createdAt: $_substituteRequestCreatedAt)",
      );
      debugPrint(
        "[EHomePage] 교대 요청 카드용 id 로딩 성공: $shiftWorkChangeRequestId "
            "(createdAt: $_shiftRequestCreatedAt)",
      );

      /// 대타 요청 카드에 표시할 실제 근무 날짜/시간 조회
      if (latestSubstitute != null) {
        _loadSubstituteScheduleLabels(
          workPlaceId: workPlaceId,
          request: latestSubstitute,
        );
      }

      /// 교대 요청 카드에 표시할 실제 근무 날짜/시간 조회
      if (latestShiftSwap != null) {
        _loadShiftScheduleLabels(
          workPlaceId: workPlaceId,
          request: latestShiftSwap,
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
    // ✅ 현재 선택된 매장이 없으면 조회하지 않음
    if (workPlaceId == null) {
      debugPrint("[EHomePage] workPlaceId가 없어서 근무 일정 조회 스킵");
      return;
    }

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

      // ✅ 응답에는 이 계정의 모든 매장 스케줄이 섞여 있을 수 있으므로,
      // 현재 선택된 매장(workPlaceId) 기준으로만 걸러서 캘린더에 반영한다.
      setState(() {
        workedDates = result.schedules
            .where((e) => e.workPlaceId == workPlaceId)
            .map(
              (e) => DateTime(
            e.workDate.year,
            e.workDate.month,
            e.workDate.day,
          ),
        )
            .toSet();
      });

      debugPrint(
        "근무 날짜 (workPlaceId: $workPlaceId) : $workedDates",
      );
    } catch (e) {
      debugPrint("근무 일정 조회 실패 : $e");
    }
  }

  @override
  void initState() {
    super.initState();

    _loadHiddenCardKeys();

    // ✅ _loadConfirmedSchedules()는 여기서 별도로 호출하지 않는다.
    // workPlaceId가 확정된 뒤 _loadMyWorkPlace() 내부에서 호출되므로,
    // 여기서 동시에 호출하면 workPlaceId가 아직 null인 상태로 스킵되는
    // 경쟁 조건이 발생한다. (다른 페이지에서 돌아와 EHomePage가 새로
    // 생성될 때마다 캘린더가 비어 보이던 원인이었음)
    _loadMyWorkPlace();

    // 홈 진입 시 알림함을 한 번 조회해서, 종 아이콘에 미확인 배지를 띄울 수 있게 한다.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(alarmListProvider.notifier).fetchFirstPage();
    });
  }

  @override
  void dispose() {
    _scheduleCardPageController.dispose();
    super.dispose();
  }

  /// 월요일~일요일 기준 남은 일수
  int get daysLeft {
    if (dueDate == null || dueDate!.isEmpty) {
      return 0;
    }

    try {
      final deadline = DateTime.parse(dueDate!);

      final today = DateTime.now();

      final now = DateTime(
        today.year,
        today.month,
        today.day,
      );

      final end = DateTime(
        deadline.year,
        deadline.month,
        deadline.day,
      );

      final diff = end.difference(now).inDays;

      return diff < 0 ? 0 : diff;
    } catch (_) {
      return 0;
    }
  }

  //==========================================================
  // 개발용: 6개 HomeCardType(=none 제외) 전부 렌더링
  //==========================================================
  static const List<HomeCardType> _allCardTypes = [
    HomeCardType.shiftRequest,
    HomeCardType.substituteRequest,
    HomeCardType.weeklySchedule,
    HomeCardType.scheduleCompleted,
    HomeCardType.scheduleChanged,
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
    final alarms = ref.watch(alarmListProvider.select((s) => s.alarms));

    debugPrint("alarms count: ${alarms.length}");
    for (final a in alarms) {
      debugPrint("alarm: type=${a.notificationType}, createdAt=${a.createdAt} (${a.createdAt.runtimeType})");
    }

    // ✅ 알림 타입별 "가장 최근 도착 시각"을 구한다.
    // ⚠️ Alarm 모델에 시각 필드가 createdAt(String or DateTime)이 맞는지 확인 필요.
    DateTime? _latestAlarmTime(String notificationType) {
      DateTime? latest;
      for (final a in alarms) {
        if (a.notificationType != notificationType) continue;

        final dynamic raw = a.createdAt;
        DateTime? t;
        if (raw is DateTime) {
          t = raw;
        } else if (raw is String) {
          t = DateTime.tryParse(raw);
        }

        if (t == null) continue;

        final DateTime? current = latest; // ✅ 로컬 변수에 담아 promotion 가능하게 만듦
        if (current == null || t.isAfter(current)) {
          latest = t;
        }
      }
      return latest;
    }

    final weeklyScheduleTime = _latestAlarmTime('SCHEDULE_CONDITION_CREATED');
    final scheduleCompletedTime = _latestAlarmTime('SCHEDULE_CONFIRMED');
    final scheduleChangedTime = _latestAlarmTime('SCHEDULE_UPDATED');
    final workChangeRequestedTime = _latestAlarmTime('WORK_CHANGE_REQUESTED');

    final hasScheduleConditionCreated = weeklyScheduleTime != null;
    final hasScheduleConfirmed = scheduleCompletedTime != null;
    final hasScheduleUpdated = scheduleChangedTime != null;

    debugPrint("scheduleCompletedTime: $scheduleCompletedTime");
    debugPrint("hasScheduleConfirmed: $hasScheduleConfirmed");
    debugPrint("hiddenKey: ${_hiddenCardKeys[HomeCardType.scheduleCompleted]}");

    // ✅ 카드별 "현재 식별값" (닫기 상태 비교용)
    final currentKeys = <HomeCardType, dynamic>{
      // ✅ id + WORK_CHANGE_REQUESTED 알림 시각을 합쳐서 식별값으로 사용.
      // 같은 요청이어도 새 알림이 오면 값이 달라져 닫아뒀던 카드가 다시 노출됨.
      HomeCardType.shiftRequest:
      '$shiftWorkChangeRequestId|$workChangeRequestedTime',
      HomeCardType.substituteRequest:
      '$substituteWorkChangeRequestId|$workChangeRequestedTime',
      HomeCardType.weeklySchedule: weeklyScheduleTime,
      HomeCardType.scheduleCompleted: scheduleCompletedTime,
      HomeCardType.scheduleChanged: scheduleChangedTime,
    };

    // ✅ 카드별 "정렬 기준 시각"
    DateTime? _laterOf(DateTime? a, DateTime? b) {
      if (a == null) return b;
      if (b == null) return a;
      return a.isAfter(b) ? a : b;
    }

    final currentTimes = <HomeCardType, DateTime?>{
      HomeCardType.shiftRequest:
      _laterOf(_shiftRequestCreatedAt, workChangeRequestedTime),
      HomeCardType.substituteRequest:
      _laterOf(_substituteRequestCreatedAt, workChangeRequestedTime),
      HomeCardType.weeklySchedule: weeklyScheduleTime,
      HomeCardType.scheduleCompleted: scheduleCompletedTime,
      HomeCardType.scheduleChanged: scheduleChangedTime,
    };

    final visibleCardTypes = _allCardTypes.where((type) {
      final meetsCondition = switch (type) {
        HomeCardType.weeklySchedule => hasScheduleConditionCreated,
        HomeCardType.scheduleCompleted => hasScheduleConfirmed,
        HomeCardType.scheduleChanged => hasScheduleUpdated,
        HomeCardType.shiftRequest =>
        (shiftWorkChangeRequestId != null || workChangeRequestedTime != null) &&
            shiftWorkChangeRequestId != null &&
            applicantDateLabel != null &&
            applicantDateLabel!.isNotEmpty &&
            myDateLabel != null &&
            myDateLabel!.isNotEmpty,
        HomeCardType.substituteRequest =>
        (substituteWorkChangeRequestId != null || workChangeRequestedTime != null) &&
            substituteWorkChangeRequestId != null &&
            substituteDateLabel != null &&
            substituteDateLabel!.isNotEmpty,
        _ => true,
      };
      if (!meetsCondition) return false;

      // ✅ 닫은 적이 있고, 그때 닫았던 건과 지금 건이 같으면 계속 숨김.
      // 새로운 요청/알림이 들어와 식별값이 바뀌면 다시 노출된다.
      final hiddenKey = _hiddenCardKeys[type];
      final key = currentKeys[type]?.toString();
      if (hiddenKey != null && hiddenKey == key) return false;

      return true;
    }).toList();

    // ✅ 알림/요청이 최근에 온 순서대로 앞에 배치 (최신이 먼저)
    visibleCardTypes.sort((a, b) {
      final ta = currentTimes[a];
      final tb = currentTimes[b];
      if (ta == null && tb == null) return 0;
      if (ta == null) return 1;
      if (tb == null) return -1;
      return tb.compareTo(ta);
    });

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
                    onStoreTap: () {
                      _EshowStoreBottomSheet(context);
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
              if (workPlaceId != null && accessToken != null)
                ENoticeBanner(
                  key: ValueKey('notice-$workPlaceId'),
                  workPlaceId: workPlaceId!,
                  accessToken: accessToken!,
                  dio: _dio,
                )
              else
                const SizedBox.shrink(),
              const SizedBox(height: 20),

              /// Schedule Cards
              if (visibleCardTypes.isNotEmpty) ...[
                SizedBox(
                  height: 140,
                  child: PageView.builder(
                    key: ValueKey('schedule-pageview-$workPlaceId'),
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
                          key: ValueKey('$type-$workPlaceId'),
                          type: type,
                          daysLeft: daysLeft,
                          workPlaceId: workPlaceId,
                          workChangeRequestId: _workChangeRequestIdFor(type),
                          substituteDateLabel: type == HomeCardType.substituteRequest
                              ? substituteDateLabel
                              : null,
                          substituteTimeLabel: type == HomeCardType.substituteRequest
                              ? substituteTimeLabel
                              : null,
                          applicantDateLabel: type == HomeCardType.shiftRequest
                              ? applicantDateLabel
                              : null,
                          applicantTimeLabel: type == HomeCardType.shiftRequest
                              ? applicantTimeLabel
                              : null,
                          myDateLabel:
                          type == HomeCardType.shiftRequest ? myDateLabel : null,
                          myTimeLabel:
                          type == HomeCardType.shiftRequest ? myTimeLabel : null,
                          onDetailTap: () => _handleDetailTap(type),
                          onClose: () {
                            _hideCard(type, currentKeys[type]);
                          },
                        ),
                      );
                    },
                  ),
                ),

                const SizedBox(height: 10),

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