import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'TimeInputBottomSheet.dart';
import 'widgets/ShiftTimeCard.dart';
import 'widgets/CounterBox.dart';
import 'models/ShiftInfo.dart';

class RMakingSchedulePage extends StatefulWidget {
  const RMakingSchedulePage({super.key});

  @override
  State<RMakingSchedulePage> createState() => _RMakingSchedulePageState();
}

class _RMakingSchedulePageState extends State<RMakingSchedulePage> {
  /// 매장 운영 시간 - 기본값을 00:00으로 설정
  TimeOfDay openTime = const TimeOfDay(hour: 0, minute: 0);
  TimeOfDay closeTime = const TimeOfDay(hour: 0, minute: 0);

  /// 인원당 근무 횟수 - 1로 초기화
  int minWork = 1;
  int maxWork = 1;

  /// 근무 교대 횟수
  int shiftCount = 1;

  /// 요일 설정
  final List<String> days = ["월", "화", "수", "목", "금", "토", "일"];
  
  /// 요일 선택 - 기본적으로 아무것도 선택하지 않음
  final Set<String> selectedDays = {};

  /// 타임 리스트
  List<ShiftInfo> shiftInfos = [
    ShiftInfo(name: ""),
    ShiftInfo(name: ""),
  ];

  /// '등록하기' 버튼 클릭 여부
  bool _isRegistered = false;

  /// 타임별 상세 설정 정보가 모두 입력되었는지 확인
  bool get canRegister {
    return shiftInfos.isNotEmpty &&
        shiftInfos.every((e) => e.isCompleted);
  }

  /// 등록된 스케줄 펼쳐보이기
  bool _isScheduleExpanded = true;

  /// 등록된 스케줄 목록
  List<RegisteredSchedule> registeredSchedules = [];

  @override
  void initState() {
    super.initState();
    _syncShiftInfos();
  }

  void _syncShiftInfos() {
    // 근무 교대 횟수 N이면 N+1개의 타임이 필요함
    int targetCount = shiftCount + 1;
    if (shiftInfos.length < targetCount) {
      for (int i = shiftInfos.length; i < targetCount; i++) {
        shiftInfos.add(ShiftInfo(name: ""));
      }
    } else if (shiftInfos.length > targetCount) {
      shiftInfos = shiftInfos.sublist(0, targetCount);
    }
  }

  String formatTime(TimeOfDay time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          "스케줄 만들기",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 18),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          TextButton(
            onPressed: () {},
            child: const Text(
              "불러오기",
              style: TextStyle(color: Color(0xFF2F80FF), fontWeight: FontWeight.bold, fontSize: 16),
            ),
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: SizedBox(
            height: 56,
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _isRegistered ? () {
                // 스케줄 만들기 처리
              } : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: _isRegistered ? const Color(0xFF007AFF) : const Color(0xFFA9D0FB),
                disabledBackgroundColor: const Color(0xFFA9D0FB),
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text(
                "스케줄 만들기",
                style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 10),
            const Text("매장 운영 시간", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildTimeSelector(
                    label: "오픈 시간",
                    time: formatTime(openTime),
                    onTap: () => _openTimePicker(initialIndex: 0),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildTimeSelector(
                    label: "마감 시간",
                    time: formatTime(closeTime),
                    onTap: () => _openTimePicker(initialIndex: 2),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            const Divider(height: 1, thickness: 1, color: Color(0xFFF2F2F5)),
            const SizedBox(height: 24),
            const Text("인원당 근무 횟수", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: CounterBox(
                    title: "최소",
                    value: minWork,
                    onMinus: () {
                      if (minWork > 1) {
                        setState(() {
                          minWork--;
                        });
                      }
                    },
                    onPlus: () {
                      setState(() {
                        minWork++;
                        if (minWork > maxWork) {
                          maxWork = minWork;
                        }
                      });
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: CounterBox(
                    title: "최대",
                    value: maxWork,
                    onMinus: () {
                      if (maxWork > minWork) {
                        setState(() {
                          maxWork--;
                        });
                      }
                    },
                    onPlus: () {
                      setState(() {
                        maxWork++;
                      });
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),
            if (registeredSchedules.isNotEmpty) ...[
              const SizedBox(height: 32),

              const Text(
                "등록된 스케줄",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 16),

              ...List.generate(registeredSchedules.length, (index) {
                final schedule = registeredSchedules[index];

                return Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: const Color(0xFFE8E9ED),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      /// 헤더
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              days
                                  .where((d) => schedule.days.contains(d))
                                  .join(", "),
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                schedule.isExpanded = !schedule.isExpanded;
                              });
                            },
                            child: Icon(
                              schedule.isExpanded
                                  ? Icons.keyboard_arrow_up
                                  : Icons.keyboard_arrow_down,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),

                      if (schedule.isExpanded) ...[
                        const SizedBox(height: 16),
                        const Divider(),

                        ...schedule.shifts.map((shift) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 24),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFEAF3FF),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Text(
                                    shift.name,
                                    style: const TextStyle(
                                      color: Color(0xFF007AFF),
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),

                                const SizedBox(height: 12),

                                _scheduleRow(
                                  "타임 운영 시간",
                                  "${formatTime(shift.startTime)} - ${formatTime(shift.endTime)}",
                                ),

                                const SizedBox(height: 10),

                                _scheduleRow(
                                  "필요 근무자 수",
                                  "${shift.requiredWorkers}명",
                                ),

                                const SizedBox(height: 10),

                                _scheduleRow(
                                  "휴게 시간",
                                  shift.breakTime,
                                ),
                              ],
                            ),
                          );
                        }).toList(),

                        Center(
                          child: TextButton(
                            onPressed: () {
                              setState(() {
                                registeredSchedules.removeAt(index);
                              });
                            },
                            child: const Text(
                              "해당 타임 삭제하기 ✕",
                              style: TextStyle(
                                color: Color(0xFFAEB0B6),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                );
              }),

              const SizedBox(height: 32),
            ],
            const Text("요일 선택", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: days.map((day) {
                bool isSelected = selectedDays.contains(day);
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      if (isSelected) {
                        selectedDays.remove(day);
                      } else {
                        selectedDays.add(day);
                      }
                    });
                  },
                  child: Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: isSelected ? const Color(0xFF5B96F4) : const Color(0xFFF2F2F5),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: Text(
                        day,
                        style: TextStyle(
                          color: isSelected ? Colors.white : const Color(0xFFAEB0B6),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                const Text("적용 요일", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 15)),
                const Spacer(),
                Text(
                  selectedDays.isEmpty 
                      ? "없음" 
                      : days.where((d) => selectedDays.contains(d)).join(", "),
                  style: const TextStyle(color: Color(0xFF6C6E76), fontSize: 15),
                ),
              ],
            ),
            const SizedBox(height: 32),
            Row(
              children: [
                const Text("근무 교대 횟수", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                const Spacer(),
                SizedBox(
                  width: 140,
                  child: CounterBox(
                    value: shiftCount,
                    onMinus: () {
                      if (shiftCount > 0) {
                        setState(() {
                          shiftCount--;
                          _syncShiftInfos();
                        });
                      }
                    },
                    onPlus: () {
                      setState(() {
                        shiftCount++;
                        _syncShiftInfos();
                      });
                    },
                  ),
                ),
              ],
            ),
            if (selectedDays.isNotEmpty) ...[
              const SizedBox(height: 24),
              const Text(
                "타임별 상세 설정",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: const Color(0xFFE8E9ED),
                  ),
                ),
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    ...List.generate(shiftInfos.length, (index) {
                      return ShiftTimeCard(
                        index: index,
                        info: shiftInfos[index],
                        onChanged: () {
                          setState(() {
                          });
                        },
                      );
                    }),
                    const SizedBox(height: 8),
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        onPressed: canRegister
                            ? () {
                          setState(() {
                            // 등록 상태
                            _isRegistered = true;

                            // 현재 입력값 저장
                            registeredSchedules.add(
                              RegisteredSchedule(
                                days: Set.from(selectedDays),
                                shifts: shiftInfos
                                    .map(
                                      (e) => e.copyWith(
                                    title: e.title,
                                    name: e.name,
                                    startTime: e.startTime,
                                    endTime: e.endTime,
                                    breakTime: e.breakTime,
                                    requiredWorkers: e.requiredWorkers,
                                  ),
                                )
                                    .toList(),
                              ),
                            );

                            // 입력 폼 초기화
                            selectedDays.clear();

                            shiftCount = 1;
                            shiftInfos = [
                              ShiftInfo(),
                              ShiftInfo(),
                            ];

                            _syncShiftInfos();
                          });
                        }
                            : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: canRegister
                              ? const Color(0xFF007AFF) // 활성화 시 파란색
                              : const Color(0xFFF2F2F5), // 기본 회색
                          disabledBackgroundColor: const Color(0xFFF2F2F5),
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: Text(
                          "등록하기",
                          style: TextStyle(
                            color: canRegister
                                ? Colors.white
                                : const Color(0xFF6C6E76),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 40),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildTimeSelector({required String label, required String time, required VoidCallback onTap}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Color(0xFF6C6E76), fontSize: 13)),
        const SizedBox(height: 8),
        InkWell(
          onTap: onTap,
          child: Container(
            height: 52,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFF5B96F4)),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Text(time, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                const Spacer(),
                const Icon(Icons.access_time, color: Color(0xFFAEB0B6), size: 20),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _scheduleRow(String title, String value) {
    return Row(
      children: [
        Text(
          title,
          style: const TextStyle(
            color: Color(0xFF8E8E93),
            fontSize: 14,
          ),
        ),
        const Spacer(),
        Text(
          value,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 15,
          ),
        ),
      ],
    );
  }

  void _openTimePicker({int initialIndex = 0}) async {
    final result = await TimeInputBottomSheet.show(
      context,
      initialOpenTime: openTime,
      initialCloseTime: closeTime,
    );
    if (result != null) {
      setState(() {
        openTime = result.openTime;
        closeTime = result.closeTime;
      });
    }
  }
}

class RegisteredSchedule {
  final Set<String> days;
  final List<ShiftInfo> shifts;

  bool isExpanded;

  RegisteredSchedule({
    required this.days,
    required this.shifts,
    this.isExpanded = true,
  });
}
