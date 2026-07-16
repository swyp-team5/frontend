import 'package:flutter/material.dart';
import 'package:flutter/material.dart' show TimeOfDay;

import 'api/ScheduleApiService.dart';
import 'models/LatestScheduleCondition.dart';
import 'RStoreClosePage.dart';
import 'RMakingSchedulePage.dart'; // RegisteredSchedule
import 'models/ShiftInfo.dart';

class RRecentSchedulePage extends StatefulWidget {
  final int workPlaceId;

  const RRecentSchedulePage({super.key, required this.workPlaceId});

  @override
  State<RRecentSchedulePage> createState() => _RRecentSchedulePageState();
}

class _RRecentSchedulePageState extends State<RRecentSchedulePage> {
  LatestScheduleResponse? recentSchedule;
  bool isLoading = true;
  bool isDeleting = false;
  String? errorMessage;

  static const _engToKor = {
    "MONDAY": "월", "TUESDAY": "화", "WEDNESDAY": "수", "THURSDAY": "목",
    "FRIDAY": "금", "SATURDAY": "토", "SUNDAY": "일",
  };

  @override
  void initState() {
    super.initState();
    _loadRecentSchedule();
  }

  Future<void> _loadRecentSchedule() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final result = await ScheduleApiService.getLatestScheduleConditions(
        workPlaceId: widget.workPlaceId,
      );

      debugPrint("========== 최근 스케줄 조회 ==========");
      debugPrint(result == null ? "저장된 스케줄 없음" : "weekScheduleId=${result.weekScheduleId}");
      debugPrint("=====================================");

      setState(() {
        recentSchedule = result;
        isLoading = false;
      });
      if (result != null) {
        for (final g in result.groups) {
          for (final td in g.timeDetails) {
            debugPrint("👀 timeName=${td.timeName}, restMinutes=${td.restMinutes}");
          }
        }
      }

    } catch (e) {
      debugPrint("최근 스케줄 조회 실패: $e");
      setState(() {
        errorMessage = e.toString();
        isLoading = false;
      });
    }
  }

  /// 삭제 확인 다이얼로그 → API 호출
  Future<void> _deleteSchedule() async {
    final schedule = recentSchedule;
    if (schedule == null || isDeleting) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("스케줄 삭제"),
        content: const Text("이 스케줄을 정말 삭제하시겠어요?\n삭제 후에는 복구할 수 없어요."),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("취소"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text(
              "삭제",
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    setState(() {
      isDeleting = true;
    });

    try {
      await ScheduleApiService.deleteScheduleCondition(
        workPlaceId: widget.workPlaceId,
        weekScheduleId: schedule.weekScheduleId,
      );

      if (!mounted) return;

      setState(() {
        recentSchedule = null;
        isDeleting = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("스케줄이 삭제되었어요.")),
      );
    } catch (e) {
      debugPrint("스케줄 삭제 실패: $e");
      if (!mounted) return;

      setState(() {
        isDeleting = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("삭제 중 오류가 발생했어요.\n$e")),
      );
    }
  }

  String _korDays(List<String> dayNames) {
    return dayNames.map((d) => _engToKor[d] ?? d).join(", ");
  }

  String _hhmm(String time) {
    // "09:00:00" -> "09:00"
    final parts = time.split(":");
    return "${parts[0]}:${parts[1]}";
  }

  TimeOfDay _parseTime(String time) {
    final parts = time.split(":");
    return TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
  }

  Widget _buildInfoRow(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 15,
              color: Color(0xFF767676),
            ),
          ),
          const Spacer(),
          Text(
            value,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildShift(LatestTimeDetail shift) {
    return Padding(
      padding: const EdgeInsets.only(top: 18, bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 6,
            ),
            decoration: BoxDecoration(
              color: const Color(0xFFE6F3FF),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              shift.timeName,
              style: const TextStyle(
                color: Color(0xFF0084FF),
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
            ),
          ),

          const SizedBox(height: 14),

          Container(
            padding: const EdgeInsets.only(left: 12),
            decoration: const BoxDecoration(
              border: Border(
                left: BorderSide(
                  color: Color(0xFFE5E5E5),
                  width: 3,
                ),
              ),
            ),
            child: Column(
              children: [
                _buildInfoRow(
                  "타임 운영 시간",
                  "${_hhmm(shift.startTime)} - ${_hhmm(shift.closeTime)}",
                ),
                _buildInfoRow(
                  "필요 근무자 수",
                  "${shift.workerCount}명",
                ),
                _buildInfoRow(
                  "휴게 시간",
                  "${shift.restMinutes}분",
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// 불러온 데이터를 다음 화면(RStoreClosePage)에서 쓸 형태로 변환
  void _goToStoreClosePage() {
    final schedule = recentSchedule;
    if (schedule == null || schedule.groups.isEmpty) return;

    final firstGroup = schedule.groups.first;

    final registeredSchedules = schedule.groups.map((group) {
      return RegisteredSchedule(
        days: group.dayNames.map((d) => _engToKor[d] ?? d).toSet(),
        shifts: group.timeDetails.map((td) {
          return ShiftInfo(
            name: td.timeName,
            startTime: _parseTime(td.startTime),
            endTime: _parseTime(td.closeTime),
            breakTime: "${td.restMinutes}분",
            requiredWorkers: td.workerCount,
          );
        }).toList(),
      );
    }).toList();

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => RStoreClosePage(
          workPlaceId: widget.workPlaceId,
          openTime: _parseTime(firstGroup.workPlaceOpenTime),
          closeTime: _parseTime(firstGroup.workPlaceCloseTime),
          minWork: firstGroup.minPersonalWorkCount,
          maxWork: firstGroup.maxPersonalWorkCount,
          registeredSchedules: registeredSchedules,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),

      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 28,
              ),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: const Icon(Icons.arrow_back_ios_new),
                  ),
                  const Expanded(
                    child: Center(
                      child: Text(
                        "최근 설정",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  // 데이터가 있을 때만 삭제 버튼 노출
                  if (recentSchedule != null)
                    GestureDetector(
                      onTap: isDeleting ? null : _deleteSchedule,
                      child: isDeleting
                          ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                          : const Icon(
                        Icons.delete_outline,
                        color: Colors.redAccent,
                      ),
                    )
                  else
                    const SizedBox(width: 24),
                ],
              ),
            ),

            if (errorMessage != null)
              Expanded(
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Text(
                      "불러오는 중 오류가 발생했어요\n$errorMessage",
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 15,
                        color: Color(0xFF999999),
                      ),
                    ),
                  ),
                ),
              )
            else if (recentSchedule == null)
              const Expanded(
                child: Center(
                  child: Text(
                    "최근에 저장된\n기록이 없어요",
                    style: TextStyle(
                      fontSize: 18,
                      color: Color(0xFF999999),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              )
            else
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    children: [
                      Expanded(
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: SingleChildScrollView(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Center(
                                  child: Text(
                                    recentSchedule!.weekScheduleName,
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),

                                const SizedBox(height: 24),

                                ...recentSchedule!.groups.map((group) {
                                  return Padding(
                                    padding: const EdgeInsets.only(bottom: 20),
                                    child: Column(
                                      crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          _korDays(group.dayNames),
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                          ),
                                        ),

                                        const SizedBox(height: 8),

                                        _buildInfoRow(
                                          "가게 운영 시간",
                                          "${_hhmm(group.workPlaceOpenTime)} - ${_hhmm(group.workPlaceCloseTime)}",
                                        ),
                                        _buildInfoRow(
                                          "인원 당 근무 횟수",
                                          "최소 ${group.minPersonalWorkCount}, 최대 ${group.maxPersonalWorkCount}",
                                        ),

                                        const SizedBox(height: 12),
                                        const Divider(color: Color(0xFFE5E5EC)),

                                        ...group.timeDetails
                                            .map((td) => _buildShift(td)),
                                      ],
                                    ),
                                  );
                                }),
                              ],
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),

                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton(
                          onPressed: _goToStoreClosePage,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF0084FF),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: const Text(
                            "불러오기",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}