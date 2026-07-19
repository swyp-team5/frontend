import 'package:flutter/material.dart';

import 'api/CrewsApi.dart';
import 'api/ScheduleConditionsApi.dart';
import 'api/ScheduleGenerationRunApi.dart'; // NoScheduleCandidateException 사용
import 'models/ScheduleConditionsLatestResponse.dart';
import 'models/SchedulePreviewResponse.dart';
import 'models/ScheduleScenario.dart';
import 'models/ShiftCount.dart';
import 'widgets/RWeekCalendar.dart';

class RSelectAutoSchedulePage extends StatefulWidget {
  final SchedulePreviewResponse preview;

  const RSelectAutoSchedulePage({
    super.key,
    required this.preview,
  });

  @override
  State<RSelectAutoSchedulePage> createState() =>
      _RSelectAutoSchedulePageState();
}

class _RSelectAutoSchedulePageState extends State<RSelectAutoSchedulePage> {
  int selectedScenario = 0;

  bool _isLoading = true;
  bool _isResetting = false;
  String? _error;
  List<ScheduleScenario> scenarios = [];

  late final List<DateTime> weekDays;

  @override
  void initState() {
    super.initState();

    final now = DateTime.now();
    final nextMonday = DateTime(now.year, now.month, now.day)
        .add(Duration(days: 8 - now.weekday));
    weekDays = List.generate(7, (i) => nextMonday.add(Duration(days: i)));

    _load();
  }

  // weekday(1=월 ~ 7=일) -> 서버가 쓰는 dayName 문자열로 변환
  String _dayName(DateTime d) {
    const names = [
      "MONDAY", "TUESDAY", "WEDNESDAY", "THURSDAY",
      "FRIDAY", "SATURDAY", "SUNDAY",
    ];
    return names[d.weekday - 1];
  }

  Future<void> _load() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      // 1) 최근 스케줄 조건 조회 (그룹 단위: dayNames + timeDetails)
      final latest = await ScheduleConditionsApi.getLatest(
        workPlaceId: widget.preview.workPlaceId,
      );

      // 2) dayName("MONDAY" 등) -> 해당 그룹의 timeDetails 매핑
      final timeDetailsByDayName = <String, List<OwnerTimeDetail>>{};
      for (final group in latest.groups) {
        for (final dayName in group.dayNames) {
          timeDetailsByDayName[dayName] = group.timeDetails;
        }
      }

      // 3) 이번 주 7일(월~일)을 dayName으로 변환해 매칭
      //    (해당 dayName이 어떤 그룹에도 없으면 = 휴무일 -> 빈 리스트)
      final dayTemplates = weekDays
          .map((date) =>
      timeDetailsByDayName[_dayName(date)] ?? <OwnerTimeDetail>[])
          .toList();

      // 4) 직원 목록 조회 (memberId -> name)
      final crewsRes = await CrewsApi.getCrews(
        workPlaceId: widget.preview.workPlaceId,
      );
      final nameByMemberId = <int, String>{
        for (final c in crewsRes.crews) c.memberId: c.name,
      };

      // 5) 행(타임명) 순서 결정
      //    타임이 가장 많은 날을 기준으로 순서를 잡고,
      //    다른 날에만 있는 타임명이 있으면 뒤에 추가
      final baseDay = dayTemplates.reduce(
            (a, b) => a.length >= b.length ? a : b,
      );
      final rowTitles = <String>[for (final td in baseDay) td.timeName];
      for (final details in dayTemplates) {
        for (final td in details) {
          if (!rowTitles.contains(td.timeName)) {
            rowTitles.add(td.timeName);
          }
        }
      }

      // 6) 시안(candidate)별로 rows 구성
      //    ⚠️ candidate.days[].timeDetails[].timeDetailId는 "이번 주 실제 생성된"
      //       time_detail 행의 ID라서 요일마다 값이 다르다. 반면 dayTemplates
      //       (스케줄 조건 템플릿)의 timeDetailId는 같은 요일 그룹이면 전부 동일한
      //       값을 공유한다 — 서로 다른 ID 체계라 timeDetailId로는 매칭이 안 된다.
      //       대신 "같은 요일 안에서 몇 번째 타임인지"(순서)로 매칭한다. candidate.days는
      //       월~일 순서로, 각 날의 timeDetails는 dayTemplates와 같은 순서(조건
      //       템플릿을 그대로 기반으로 생성)라는 전제로 동작한다.
      final builtScenarios = widget.preview.candidates.map((candidate) {
        final rows = rowTitles.map((rowTitle) {
          final counts = List.generate(7, (dayIndex) {
            // 이 요일에서 rowTitle(타임 이름)이 조건 템플릿의 몇 번째 항목인지 찾는다.
            final templateDetails = dayTemplates[dayIndex];
            final position =
                templateDetails.indexWhere((td) => td.timeName == rowTitle);

            // 이 날짜엔 해당 타임 자체가 없음 (휴무 슬롯)
            if (position == -1) {
              return const ShiftCount(required: 0, isOff: true);
            }

            final matched = templateDetails[position];

            // candidate의 같은 요일 + 같은 순서(position)의 timeDetail에서
            // 실제 배정된 근무자를 찾는다 (timeDetailId 매칭 아님).
            final candidateDay = dayIndex < candidate.days.length
                ? candidate.days[dayIndex]
                : null;

            final memberIds = (candidateDay != null &&
                    position < candidateDay.timeDetails.length)
                ? candidateDay.timeDetails[position].workerMemberIds
                : <int>[];

            final workerNames = memberIds
                .map((id) => nameByMemberId[id] ?? "이름없음(#$id)")
                .toList();

            return ShiftCount(
              required: matched.workerCount,
              workers: workerNames,
              isOff: false,
              startTime: matched.startTime,
              closeTime: matched.closeTime,
            );
          });

          return ShiftRowData(title: rowTitle, counts: counts);
        }).toList();

        return ScheduleScenario(
          candidateNo: candidate.candidateNo,
          title: "시안 ${candidate.candidateNo}",
          rows: rows,
        );
      }).toList();

      if (!mounted) return;
      setState(() {
        scenarios = builtScenarios;
        _isLoading = false;
      });
    } on NoScheduleCandidateException catch (e) {
      // 서버가 조건 불일치(409 / code 4005)로 후보를 만들지 못한 경우
      // guidanceText: 서버 message + 상황별 액션 가이드 문구
      debugPrint("스케줄 시안 구성 실패(후보 없음): ${e.guidanceText}");
      if (!mounted) return;
      setState(() {
        _error = e.guidanceText;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint("스케줄 시안 구성 실패: $e");
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _onResetConditionsTap() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("스케줄 조건 초기화"),
        content: const Text("설정된 스케줄 조건을 초기화할까요?\n이 작업은 되돌릴 수 없어요."),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("취소"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text(
              "초기화",
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );

    if (confirmed != true) return;
    if (!mounted) return;

    setState(() => _isResetting = true);

    try {
      await ScheduleConditionsApi.resetConditions(
        workPlaceId: widget.preview.workPlaceId,
        weekScheduleId: widget.preview.weekScheduleId,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("스케줄 조건이 초기화되었어요.")),
      );

      // 초기화 후에는 이 미리보기 화면에 머무를 이유가 없으므로 홈으로 돌아간다.
      // (RAutoSchedulingPage가 pushReplacement로 이 화면을 열었기 때문에,
      //  루트 네비게이터에서 한 번만 pop하면 바로 홈이 나온다.)
      Navigator.of(context, rootNavigator: true).pop();
    } catch (e) {
      debugPrint("스케줄 조건 초기화 실패: $e");
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))),
      );
    } finally {
      if (mounted) setState(() => _isResetting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final nextMonday = weekDays.first;
    final nextSunday = weekDays.last;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 30, 20, 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "스케줄 선택",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  TextButton(
                    onPressed: _isResetting ? null : _onResetConditionsTap,
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.zero,
                      minimumSize: const Size(0, 0),
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: _isResetting
                        ? const SizedBox(
                      width: 14,
                      height: 14,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.red,
                      ),
                    )
                        : const Text(
                      "스케줄 조건 초기화",
                      style: TextStyle(
                        color: Colors.red,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 18),

            Center(
              child: Text(
                "${nextMonday.month}월 ${nextMonday.day}일 - "
                    "${nextSunday.month}월 ${nextSunday.day}일",
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),

            const SizedBox(height: 16),

            Container(
              margin: const EdgeInsets.symmetric(horizontal: 90),
              padding: const EdgeInsets.symmetric(vertical: 5),
              decoration: BoxDecoration(
                color: const Color(0xFFF1F1F5),
                borderRadius: BorderRadius.circular(4),
              ),
              child: const Center(
                child: Text(
                  "스케줄 시안 중 1개를 선택해주세요",
                  style: TextStyle(
                    color: Color(0xFF767676),
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),

            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
              child: Row(
                children: [
                  const SizedBox(width: 50),
                  ...const [
                    "월", "화", "수", "목", "금", "토", "일",
                  ].map(
                        (day) => Expanded(
                      child: Center(
                        child: Text(
                          day,
                          style: const TextStyle(
                            color: Color(0xFF767676),
                            fontSize: 12,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const Divider(height: 10),

            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _error != null
                  ? Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Text(
                    "스케줄 시안을 불러오지 못했어요\n$_error",
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Color(0xFF999999)),
                  ),
                ),
              )
                  : RWeekCalendar(
                scenarios: scenarios,
                selectedIndex: selectedScenario,
                preview: widget.preview,
                onSelect: (index) {
                  setState(() => selectedScenario = index);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}