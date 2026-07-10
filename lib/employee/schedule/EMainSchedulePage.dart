import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../common/widgets/BottomNavBar.dart';
import '../crews/ECrewPage.dart';
import '../home/EHomePage.dart';
import '../mypage/EMyPage.dart';
import 'EYearMonthBottomSheet.dart';
import 'Month/AllSchedule/EMonthAllSchedulePage.dart';
import 'Month/MySchedule/EMonthMyScheduleBottomSheet.dart';
import 'Month/MySchedule/EMonthMySchedulePage.dart';
import 'Week/EWeekSchedulePage.dart';
import 'api/MyConfirmedSchedulesApi.dart';
import 'api/WeeklyWorkersApi.dart';
import 'models/MyConfirmedSchedulesResponse.dart';
import 'models/WeeklyWorkersResponse.dart';

class EMainSchedulePage extends StatefulWidget {
  const EMainSchedulePage({super.key});

  @override
  State<EMainSchedulePage> createState() => _EMainSchedulePageState();
}

class _EMainSchedulePageState extends State<EMainSchedulePage> {
  /// true = 주간, false = 월간
  bool isWeekMode = true;

  /// 현재 선택된 날짜
  DateTime selectedDate = DateTime.now();

  int selectedYear = DateTime.now().year;
  int selectedMonth = DateTime.now().month;

  /// 서버에서 받아온 내 확정 근무표 (workDate 기준으로 그룹핑)
  Map<String, List<MySchedule>> myConfirmedSchedules = {};

  bool isLoading = false;
  String? errorMessage;

  DateTime? _loadedFrom;
  DateTime? _loadedTo;

  Map<String, List<ScheduleShift>> allSchedules = {};

  final Set<String> holidays = {};

  int? selectedWorkPlaceId;

  DateTime? _loadedWeekStart;

  WeeklyWorkersResponse? weeklyWorkersResponse;

  bool isAllViewSelected = false;

  String _formatDate(DateTime date) {
    return "${date.year.toString().padLeft(4, '0')}-"
        "${date.month.toString().padLeft(2, '0')}-"
        "${date.day.toString().padLeft(2, '0')}";
  }

  @override
  void initState() {
    super.initState();

    selectedYear = selectedDate.year;
    selectedMonth = selectedDate.month;

    _initialize();
  }

  Future<void> _initialize() async {
    if (isAllViewSelected) {
      await _loadWeeklyWorkers(force: true);
    } else {
      await _loadMySchedules(force: true);
    }
  }

  /// 현재 모드(주간/월간)와 selectedDate 기준으로 조회 범위 계산
  (DateTime, DateTime) _calculateRange() {
    if (isWeekMode) {
      final monday = DateTime(
        selectedDate.year,
        selectedDate.month,
        selectedDate.day,
      ).subtract(Duration(days: selectedDate.weekday - 1));

      final sunday = monday.add(const Duration(days: 6));
      return (monday, sunday);
    } else {
      final firstDay = DateTime(selectedDate.year, selectedDate.month, 1);
      final lastDay = DateTime(selectedDate.year, selectedDate.month + 1, 0);
      return (firstDay, lastDay);
    }
  }

  String _formatHHmm(String hhmmss) {
    final parts = hhmmss.split(":");
    return "${parts[0]}:${parts[1]}";
  }

  Map<String, List<MySchedule>> _mapMySchedules(
      MyConfirmedSchedulesResponse response) {
    final Map<String, List<MySchedule>> result = {};

    for (final item in response.schedules) {
      result.putIfAbsent(item.workDate, () => []);
      result[item.workDate]!.add(
        MySchedule(
          name: item.workPlaceName,
          startTime: _formatHHmm(item.startTime),
          closeTime: _formatHHmm(item.closeTime), // endTime -> closeTime
          timeName: item.timeName,
        ),
      );
    }

    debugPrint(
      "🟢 [EMainSchedulePage] 매핑 완료 - "
          "날짜 수: ${result.length}, "
          "총 스케줄 수: ${result.values.fold<int>(0, (sum, list) => sum + list.length)}",
    );

    return result;
  }

  Future<void> _loadMySchedules({bool force = false}) async {
    final range = _calculateRange();

    if (!force &&
        _loadedFrom == range.$1 &&
        _loadedTo == range.$2 &&
        myConfirmedSchedules.isNotEmpty) {
      debugPrint(
        "⚪ [EMainSchedulePage] 동일 범위(${range.$1} ~ ${range.$2}) - 재요청 생략",
      );
      return; // 이미 같은 범위를 불러온 상태면 재요청 생략
    }

    debugPrint(
      "🔵 [EMainSchedulePage] 확정 근무표 요청 시작 - "
          "from: ${range.$1}, to: ${range.$2}, force: $force",
    );

    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final response = await MyConfirmedSchedulesApi.getMyConfirmedSchedules(
        from: range.$1,
        to: range.$2,
      );

      debugPrint(
        "🟢 [EMainSchedulePage] 확정 근무표 요청 성공 - "
            "from: ${response.from}, to: ${response.to}, "
            "schedules 수: ${response.schedules.length}",
      );

      if (!mounted) return;

      setState(() {
        myConfirmedSchedules = _mapMySchedules(response);

        if (response.schedules.isNotEmpty) {
          selectedWorkPlaceId = response.schedules.first.workPlaceId;
        }

        _loadedFrom = range.$1;
        _loadedTo = range.$2;
        isLoading = false;
      });
    } catch (e) {
      debugPrint("🔴 [EMainSchedulePage] 확정 근무표 요청 실패 - $e");

      if (!mounted) return;

      setState(() {
        isLoading = false;
        errorMessage = e.toString();
      });
    }
  }

  Future<void> _loadWeeklyWorkers({bool force = false}) async {
    if (selectedWorkPlaceId == null) return;

    final monday = DateTime(
      selectedDate.year,
      selectedDate.month,
      selectedDate.day,
    ).subtract(Duration(days: selectedDate.weekday - 1));

    if (!force &&
        _loadedWeekStart == monday &&
        weeklyWorkersResponse != null) {
      return;
    }

    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final response = await WeeklyWorkersApi.getWeeklyWorkers(
        workPlaceId: selectedWorkPlaceId!,
        weekStartDate: monday,
      );

      final Map<String, List<ScheduleShift>> map = {};

      for (final day in response.days) {
        final shifts = <ScheduleShift>[];

        for (final time in day.timeDetails) {
          shifts.add(
            ScheduleShift(
              role: time.timeName,
              startTime: _formatHHmm(time.startTime),
              closeTime: _formatHHmm(time.closeTime),
              required: time.workers.length,
              workers: time.workers
                  .map((e) => ScheduleWorker(name: e.name))
                  .toList(),
            ),
          );
        }

        map[_formatDate(day.workDate)] = shifts;
      }

      if (!mounted) return;

      setState(() {
        weeklyWorkersResponse = response;
        allSchedules = map;
        _loadedWeekStart = monday;
        isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        isLoading = false;
        errorMessage = e.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      /// 공통 BottomNavBar 적용
      bottomNavigationBar: BottomNavBar(
        currentIndex: 2,
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
        child: Stack(
          children: [
            Column(
              children: [
                // ==========================
                // Header
                // ==========================
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 14,
                  ),
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: () async {
                          final result = await showModalBottomSheet<DateTime>(
                            context: context,
                            isScrollControlled: true,
                            backgroundColor: Colors.transparent,
                            builder: (_) => const EYearMonthBottomSheet(),
                          );

                          if (result != null) {
                            setState(() {
                              selectedDate = result;
                            });

                            if (!isAllViewSelected) {
                              _loadMySchedules();
                            }
                          }
                        },
                        child: Row(
                          children: [
                            Text(
                              "${selectedDate.month}월",
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(width: 2),
                            const Icon(Icons.keyboard_arrow_down),
                          ],
                        ),
                      ),

                      const Spacer(),

                      GestureDetector(
                        onTap: () async {
                          setState(() {
                            isAllViewSelected = !isAllViewSelected;
                          });

                          if (isAllViewSelected) {
                            await _loadWeeklyWorkers();
                          } else {
                            await _loadMySchedules();
                          }
                        },
                        child: Container(
                          height: 34,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: isAllViewSelected
                                ? const Color(0xFFEEEBFF)
                                : const Color(0xFFF1F1F5),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: isAllViewSelected
                                  ? const Color(0xFF7D67FD)
                                  : const Color(0xFFE0E2E5),
                              width: 1,
                            ),
                          ),
                          child: Text(
                            "전체 보기",
                            style: TextStyle(
                              fontSize: 12,
                              color: isAllViewSelected
                                  ? const Color(0xFF7D67FD)
                                  : const Color(0xFF767676),
                            ),
                          ),
                        ),
                      ),

                      IconButton(
                        onPressed: () {
                          // TODO : 필터
                        },
                        icon: const Icon(Icons.tune),
                      ),
                    ],
                  ),
                ),

                // 내용
                Expanded(
                  child: Builder(
                    builder: (_) {
                      final showMyLoading = !isAllViewSelected &&
                          isLoading &&
                          myConfirmedSchedules.isEmpty;

                      final showMyError = !isAllViewSelected &&
                          errorMessage != null &&
                          myConfirmedSchedules.isEmpty;

                      if (showMyLoading) {
                        return const Center(
                          child: CircularProgressIndicator(),
                        );
                      }

                      if (showMyError) {
                        return Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                errorMessage!,
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  color: Colors.redAccent,
                                ),
                              ),
                              const SizedBox(height: 12),
                              TextButton(
                                onPressed: () {
                                  if (isAllViewSelected) {
                                    _loadWeeklyWorkers(force: true);
                                  } else {
                                    _loadMySchedules(force: true);
                                  }
                                },
                                child: const Text("다시 시도"),
                              ),
                            ],
                          ),
                        );
                      }

                      return AnimatedSwitcher(
                        duration: const Duration(milliseconds: 250),
                        child: isWeekMode
                            ? EWeekSchedulePage(
                          key: const ValueKey("week"),
                          selectedDate: selectedDate,
                          onDateChanged: (date) async {
                            setState(() {
                              selectedDate = date;
                            });

                            if (isAllViewSelected) {
                              await _loadWeeklyWorkers(force: true);
                            } else {
                              await _loadMySchedules(force: true);
                            }
                          },

                          /// 개인 스케줄 (API 연동)
                          monthSchedules: myConfirmedSchedules,

                          /// 전체 스케줄
                          allSchedules: allSchedules,

                          /// 휴무일
                          holidays: holidays,

                          /// 상단 토글
                          isAllView: isAllViewSelected,
                        )
                            : isAllViewSelected
                            ? EMonthAllSchedulePage(
                          key: const ValueKey("month_all"),
                          selectedDate: selectedDate,
                          schedules: allSchedules,
                          holidays: holidays,
                          onDateChanged: (date) async {
                            setState(() {
                              selectedDate = date;
                            });

                            await _loadWeeklyWorkers(force: true);
                          },
                        )
                            : EMonthMySchedulePage(
                          key: const ValueKey("month_my"),
                          selectedDate: selectedDate,
                          schedules: myConfirmedSchedules,
                          holidays: holidays,
                          onDateChanged: (date) {
                            setState(() {
                              selectedDate = date;
                            });
                            _loadMySchedules();
                          },
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),

            // 주 / 월 토글
            Positioned(
              bottom: 14, left: 0, right: 0,
              child: Center(
                child: Container(
                  width: 88, height: 34,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF2F2F5),
                    borderRadius: BorderRadius.circular(17),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              isWeekMode = true;
                            });

                            if (isAllViewSelected) {
                              _loadWeeklyWorkers(force: true);
                            } else {
                              _loadMySchedules(force: true);
                            }
                          },
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 180),
                            decoration: BoxDecoration(
                              color: isWeekMode
                                  ? const Color(0xFF3A3A3C)
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(17),
                            ),
                            alignment: Alignment.center,
                            child: Text("주",
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: isWeekMode
                                    ? Colors.white
                                    : const Color(0xFF8E8E93),
                              ),
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              isWeekMode = false;
                            });

                            if (isAllViewSelected) {
                              _loadWeeklyWorkers(force: true);
                            } else {
                              _loadMySchedules(force: true);
                            }
                          },
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 180),
                            decoration: BoxDecoration(
                              color: !isWeekMode
                                  ? const Color(0xFF3A3A3C)
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(17),
                            ),
                            alignment: Alignment.center,
                            child: Text("월",
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: !isWeekMode
                                    ? Colors.white
                                    : const Color(0xFF8E8E93),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}