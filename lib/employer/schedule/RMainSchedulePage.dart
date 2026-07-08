import 'package:flutter/material.dart';

import '../../common/widgets/BottomNavBar.dart';
import '../crews/RCrewPage.dart';
import '../home/RHomePage.dart';
import '../mypage/RMyPage.dart';
import 'Month/RMonthAllSchedulePage.dart';
import 'RAddSchedulePage.dart';
import 'REditSchedulePage.dart';
import 'Week/RWeekSchedulePage.dart';
import 'RYearMonthBottomSheet.dart';
import 'models/schedule_model.dart';
import 'models/ConfirmedSchedulesResponse.dart';
import 'api/ConfirmedSchedulesApi.dart'; // 실제 경로에 맞게 수정

class RMainSchedulePage extends StatefulWidget {
  final int workPlaceId;

  const RMainSchedulePage({
    super.key,
    required this.workPlaceId,
  });

  @override
  State<RMainSchedulePage> createState() => _RMainSchedulePageState();
}

class _RMainSchedulePageState extends State<RMainSchedulePage> {
  /// true = 주간, false = 월간
  bool isWeekMode = true;

  /// 현재 선택된 날짜
  DateTime selectedDate = DateTime.now();

  int selectedYear = DateTime.now().year;
  int selectedMonth = DateTime.now().month;

  List<ScheduleModel> schedules = [];

  /// 서버에서 받아온 확정 근무표
  Map<String, List<RScheduleShift>> allSchedules = {};
  Set<String> holidays = {}; // 이 API에는 휴무일 정보가 없어 우선 빈 값으로 둠

  bool isLoading = false;
  String? errorMessage;

  DateTime? _loadedFrom;
  DateTime? _loadedTo;

  /// timeName(오픈, 미들, 마감, 야간 등)에 색상 인덱스를 동적으로 배정하기 위한 캐시
  /// 색이 4개뿐이라 5번째 이름부터는 순환(rotate)해서 재사용합니다.
  final Map<String, int> _timeNameColorMap = {};
  int _nextColorIndex = 0;

  static const int _colorCount = 4; // _WorkerChip의 _bgColors/_textColors 개수와 맞춰주세요

  int _colorIndexForTimeName(String timeName) {
    if (_timeNameColorMap.containsKey(timeName)) {
      return _timeNameColorMap[timeName]!;
    }

    final assigned = _nextColorIndex % _colorCount;
    _timeNameColorMap[timeName] = assigned;
    _nextColorIndex++;

    return assigned;
  }

  @override
  void initState() {
    super.initState();

    selectedYear = selectedDate.year;
    selectedMonth = selectedDate.month;

    _loadSchedules();
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

  Map<String, List<RScheduleShift>> _mapConfirmedSchedules(
      ConfirmedSchedulesResponse response) {
    final Map<String, List<RScheduleShift>> result = {};

    for (final day in response.days) {
      final shifts = day.timeDetails.map((detail) {
        return RScheduleShift(
          startTime: _formatHHmm(detail.startTime),
          endTime: _formatHHmm(detail.closeTime),
          timeName: detail.timeName,
          breakTime: detail.restTime > 0 ? "${detail.restTime}분" : "없음",
          required: detail.workers.length,
          workers: detail.workers
              .map((w) => RScheduleWorker(name: w.name))
              .toList(),
          colorIndex: _colorIndexForTimeName(detail.timeName), // 동적 배정
        );
      }).toList();

      result[day.workDate] = shifts;
    }

    return result;
  }

  Future<void> _loadSchedules({bool force = false}) async {
    final range = _calculateRange();

    if (!force &&
        _loadedFrom == range.$1 &&
        _loadedTo == range.$2 &&
        allSchedules.isNotEmpty) {
      return; // 이미 같은 범위를 불러온 상태면 재요청 생략
    }

    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final response = await ConfirmedSchedulesApi.getConfirmedSchedules(
        workPlaceId: widget.workPlaceId,
        from: range.$1,
        to: range.$2,
      );

      if (!mounted) return;

      setState(() {
        allSchedules = _mapConfirmedSchedules(response);
        _loadedFrom = range.$1;
        _loadedTo = range.$2;
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

      bottomNavigationBar: BottomNavBar(
        currentIndex: 2,
        onTap: (index) {
          if (index == 0) {
            Navigator.push(context,
                MaterialPageRoute(builder: (_) => const RHomePage()));
          } else if (index == 1) {
            Navigator.push(context,
                MaterialPageRoute(builder: (_) => const RCrewPage()));
          } else if (index == 4) {
            Navigator.push(
                context, MaterialPageRoute(builder: (_) => const RMyPage()));
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
                            builder: (_) => const RYearMonthBottomSheet(),
                          );

                          if (result != null) {
                            setState(() {
                              selectedDate = result;
                            });
                            _loadSchedules();
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

                      IconButton(
                        onPressed: () {
                          // TODO : 필터
                        },
                        icon: const Icon(Icons.tune),
                      ),

                      PopupMenuButton<String>(
                        color: Colors.white,
                        elevation: 6,
                        splashRadius: 20,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        icon: const Icon(Icons.edit_outlined),
                        onSelected: (value) async {
                          if (value == 'edit') {
                            await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => RScheduleEditPage(
                                  selectedDate: selectedDate,
                                  schedules: allSchedules,
                                ),
                              ),
                            );

                            if (mounted) {
                              setState(() {});
                            }
                          } else if (value == 'add') {
                            final ScheduleModel? schedule =
                            await Navigator.push<ScheduleModel>(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const RAddSchedulePage(),
                              ),
                            );

                            if (schedule != null) {
                              // 서버에 새 스케줄 등록 API가 아직 없으므로
                              // 등록 후에는 서버 데이터를 다시 불러오는 것을 권장합니다.
                              // 우선 로컬 상태에도 반영해 화면에 바로 보이게 처리합니다.
                              setState(() {
                                schedules.add(schedule);

                                for (final date in schedule.dates) {
                                  final key =
                                      "${date.year.toString().padLeft(4, '0')}-"
                                      "${date.month.toString().padLeft(2, '0')}-"
                                      "${date.day.toString().padLeft(2, '0')}";

                                  allSchedules.putIfAbsent(key, () => []);

                                  allSchedules[key]!.add(
                                    RScheduleShift(
                                      startTime: schedule.startTime,
                                      endTime: schedule.endTime,
                                      timeName: schedule.workName,
                                      breakTime: schedule.breakTime,
                                      required: schedule.workers.length,
                                      workers: schedule.workers
                                          .map((name) => RScheduleWorker(name: name))
                                          .toList(),
                                      colorIndex: _colorIndexForTimeName(schedule.workName), // 동적 배정
                                    ),
                                  );
                                }
                              });
                            }
                          }
                        },
                        itemBuilder: (_) => [
                          const PopupMenuItem<String>(
                            value: 'edit',
                            padding: EdgeInsets.symmetric(horizontal: 20),
                            child: Row(
                              children: [
                                Icon(Icons.edit_outlined,
                                    size: 20, color: Colors.black),
                                SizedBox(width: 10),
                                Text(
                                  '수정',
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const PopupMenuDivider(height: 1),
                          const PopupMenuItem<String>(
                            value: 'add',
                            padding: EdgeInsets.symmetric(horizontal: 20),
                            child: Row(
                              children: [
                                Icon(Icons.add_outlined,
                                    size: 20, color: Colors.black),
                                SizedBox(width: 10),
                                Text(
                                  '추가',
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      )
                    ],
                  ),
                ),

                // ==========================
                // 내용
                // ==========================
                Expanded(
                  child: Builder(
                    builder: (_) {
                      if (isLoading && allSchedules.isEmpty) {
                        return const Center(
                          child: CircularProgressIndicator(),
                        );
                      }

                      if (errorMessage != null && allSchedules.isEmpty) {
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
                                onPressed: () => _loadSchedules(force: true),
                                child: const Text("다시 시도"),
                              ),
                            ],
                          ),
                        );
                      }

                      return AnimatedSwitcher(
                        duration: const Duration(milliseconds: 250),
                        child: isWeekMode
                            ? RWeekSchedulePage(
                          key: const ValueKey("week"),
                          selectedDate: selectedDate,
                          schedules: allSchedules,
                          holidays: holidays,
                          onDateChanged: (date) {
                            setState(() {
                              selectedDate = date;
                            });
                            _loadSchedules();
                          },
                        )
                            : RMonthAllSchedulePage(
                          key: const ValueKey("month"),
                          selectedDate: selectedDate,
                          schedules: allSchedules,
                          onDateChanged: (date) {
                            setState(() {
                              selectedDate = date;
                            });
                            _loadSchedules();
                          },
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),

            // ==========================
            // 주 / 월 토글
            // ==========================
            Positioned(
              bottom: 14,
              left: 0,
              right: 0,
              child: Center(
                child: Container(
                  width: 88,
                  height: 34,
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
                            _loadSchedules();
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
                            child: Text(
                              "주",
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
                            _loadSchedules();
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
                            child: Text(
                              "월",
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