import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'TimeInputBottomSheet.dart';
import 'widgets/ShiftTimeCard.dart';
import 'widgets/CounterBox.dart';
import 'models/ShiftInfo.dart';
import 'RStoreClosePage.dart';

class RMakingSchedulePage extends StatefulWidget {
  const RMakingSchedulePage({super.key});

  @override
  State<RMakingSchedulePage> createState() => _RMakingSchedulePageState();
}

class _RMakingSchedulePageState extends State<RMakingSchedulePage> {
  // --- 1. State Variables ---

  /// 매장 운영 시간 (기본값 00:00)
  TimeOfDay _openTime = const TimeOfDay(hour: 0, minute: 0);
  TimeOfDay _closeTime = const TimeOfDay(hour: 0, minute: 0);

  /// 인원당 근무 횟수 (초기값 1)
  int _minWork = 1;
  int _maxWork = 1;

  /// 근무 교대 횟수
  int _shiftCount = 1;

  /// 요일 설정 관련
  final List<String> _daysOfWeek = ["월", "화", "수", "목", "금", "토", "일"];
  final Set<String> _selectedDays = {};

  /// 타임 리스트 (교대 횟수 + 1)
  List<ShiftInfo> _shiftInfos = [ShiftInfo(), ShiftInfo()];

  /// 기등록된 스케줄 목록
  final List<RegisteredSchedule> _registeredSchedules = [];

  /// '등록하기' 완료 여부 (하단 '스케줄 만들기' 활성화 조건)
  bool _isRegistered = false;

  // --- 2. Lifecycle & Business Logic ---

  @override
  void initState() {
    super.initState();
    _syncShiftInfos();
  }

  /// 모든 타임 정보 입력 여부 확인
  bool get _canRegister =>
      _shiftInfos.isNotEmpty && _shiftInfos.every((e) => e.isCompleted);

  /// 근무 교대 횟수에 맞춰 상세 설정 카드 개수 동기화
  void _syncShiftInfos() {
    int targetCount = _shiftCount + 1;
    if (_shiftInfos.length < targetCount) {
      _shiftInfos.addAll(
        List.generate(targetCount - _shiftInfos.length, (_) => ShiftInfo()),
      );
    } else if (_shiftInfos.length > targetCount) {
      _shiftInfos = _shiftInfos.sublist(0, targetCount);
    }
  }

  /// TimeOfDay -> "HH:mm"
  String _formatTime(TimeOfDay time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  /// 운영 시간 선택 바텀시트 오픈
  void _openTimePicker({int initialIndex = 0}) async {
    final result = await TimeInputBottomSheet.show(
      context,
      initialOpenTime: _openTime,
      initialCloseTime: _closeTime,
      // initialIndex: initialIndex,
    );

    if (result != null) {
      setState(() {
        _openTime = result.openTime;
        _closeTime = result.closeTime;
        _isRegistered = false; // 설정 변경 시 재등록 필요
      });
    }
  }

  /// '등록하기' 버튼 클릭 시
  void _onRegisterPressed() {
    setState(() {
      _isRegistered = true;
      _registeredSchedules.add(
        RegisteredSchedule(
          days: Set.from(_selectedDays),
          shifts: _shiftInfos.map((e) => e.copyWith()).toList(),
        ),
      );
      // 입력 폼 초기화
      _selectedDays.clear();
      _shiftCount = 1;
      _shiftInfos = [ShiftInfo(), ShiftInfo()];
      _syncShiftInfos();
    });
  }

  // --- 3. Main Build Method ---

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      bottomNavigationBar: _buildBottomButton(),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 상단 헤더
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 30,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: const Icon(
                        Icons.arrow_back_ios_new,
                      ),
                    ),
                    const Text("스케줄 만들기",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight:
                        FontWeight.w700,
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        // TODO : 불러오기 기능
                      },
                      child: const Text(
                        "불러오기",
                        style: TextStyle(
                          color: Color(0xFF40A3FF),
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // 기존 body
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildOperatingHoursSection(),
                    _buildWorkCountSection(),
                    _buildRegisteredSchedulesSection(),
                    _buildDaySelectionSection(),
                    _buildShiftCountSection(),
                    _buildDetailedSettingsSection(),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // --- 4. UI Sections ---

  /// 매장 운영 시간 섹션
  Widget _buildOperatingHoursSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("매장 운영 시간",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildTimeBox(
                label: "오픈 시간",
                time: _formatTime(_openTime),
                onTap: () => _openTimePicker(initialIndex: 0),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildTimeBox(
                label: "마감 시간",
                time: _formatTime(_closeTime),
                onTap: () => _openTimePicker(initialIndex: 2),
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        const Divider(height: 1, thickness: 1, color: Color(0xFFF2F2F5)),
        const SizedBox(height: 24),
      ],
    );
  }

  /// 운영 시간 표시 박스 (Common)
  Widget _buildTimeBox({
    required String label,
    required String time,
    required VoidCallback onTap,
  }) {
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
                Text(time,
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.w500)),
                const Spacer(),
                const Icon(Icons.access_time, color: Color(0xFFAEB0B6), size: 20),
              ],
            ),
          ),
        ),
      ],
    );
  }

  /// 인원당 근무 횟수 섹션
  Widget _buildWorkCountSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("인원당 근무 횟수",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: CounterBox(
                title: "최소",
                value: _minWork,
                minValue: 1,
                onMinus: () => setState(() {
                  _minWork--;
                  _isRegistered = false;
                }),
                onPlus: () => setState(() {
                  _minWork++;
                  if (_minWork > _maxWork) _maxWork = _minWork;
                  _isRegistered = false;
                }),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: CounterBox(
                title: "최대",
                value: _maxWork,
                minValue: _minWork,
                onMinus: () => setState(() {
                  _maxWork--;
                  _isRegistered = false;
                }),
                onPlus: () => setState(() {
                  _maxWork++;
                  _isRegistered = false;
                }),
              ),
            ),
          ],
        ),
        const SizedBox(height: 32),
      ],
    );
  }

  /// 등록된 스케줄 리스트 섹션
  Widget _buildRegisteredSchedulesSection() {
    if (_registeredSchedules.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("등록된 스케줄",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        ..._registeredSchedules.asMap().entries.map((entry) {
          final int index = entry.key;
          final schedule = entry.value;

          return Container(
            margin: const EdgeInsets.only(bottom: 16),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFE8E9ED)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        _daysOfWeek
                            .where((d) => schedule.days.contains(d))
                            .join(", "),
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                    ),
                    GestureDetector(
                      onTap: () =>
                          setState(() => schedule.isExpanded = !schedule.isExpanded),
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
                  ...schedule.shifts.map((shift) => Padding(
                        padding: const EdgeInsets.only(bottom: 24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: const Color(0xFFEAF3FF),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(shift.name,
                                  style: const TextStyle(
                                      color: Color(0xFF007AFF),
                                      fontWeight: FontWeight.bold)),
                            ),
                            const SizedBox(height: 12),
                            _buildDataRow("타임 운영 시간",
                                "${_formatTime(shift.startTime)} - ${_formatTime(shift.endTime)}"),
                            const SizedBox(height: 10),
                            _buildDataRow("필요 근무자 수", "${shift.requiredWorkers}명"),
                            const SizedBox(height: 10),
                            _buildDataRow("휴게 시간", shift.breakTime),
                          ],
                        ),
                      )),
                  Center(
                    child: TextButton(
                      onPressed: () =>
                          setState(() => _registeredSchedules.removeAt(index)),
                      child: const Text("해당 타임 삭제하기 ✕",
                          style: TextStyle(
                              color: Color(0xFFAEB0B6),
                              fontWeight: FontWeight.w600)),
                    ),
                  ),
                ],
              ],
            ),
          );
        }).toList(),
        const SizedBox(height: 32),
      ],
    );
  }

  /// 상세 데이터 행 (Common)
  Widget _buildDataRow(String title, String value) {
    return Row(
      children: [
        Text(title, style: const TextStyle(color: Color(0xFF8E8E93), fontSize: 14)),
        const Spacer(),
        Text(value,
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
      ],
    );
  }

  /// 요일 선택 섹션
  Widget _buildDaySelectionSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("요일 선택",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: _daysOfWeek.map((day) {
            final bool isSelected = _selectedDays.contains(day);
            return GestureDetector(
              onTap: () => setState(() {
                isSelected ? _selectedDays.remove(day) : _selectedDays.add(day);
                _isRegistered = false;
              }),
              child: Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: isSelected
                      ? const Color(0xFF0084FF)
                      : const Color(0xFFF2F2F5),
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
            const Text("적용 요일",
                style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                    fontSize: 15)),
            const Spacer(),
            Text(
              _selectedDays.isEmpty
                  ? "없음"
                  : _daysOfWeek.where((d) => _selectedDays.contains(d)).join(", "),
              style: const TextStyle(color: Color(0xFF6C6E76), fontSize: 15),
            ),
          ],
        ),
        const SizedBox(height: 32),
      ],
    );
  }

  /// 근무 교대 횟수 섹션
  Widget _buildShiftCountSection() {
    return Column(
      children: [
        Row(
          children: [
            const Text("근무 교대 횟수",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const Spacer(),
            SizedBox(
              width: 140,
              child: CounterBox(
                value: _shiftCount,
                onMinus: () {
                  if (_shiftCount > 0) {
                    setState(() {
                      _shiftCount--;
                      _syncShiftInfos();
                      _isRegistered = false;
                    });
                  }
                },
                onPlus: () => setState(() {
                  _shiftCount++;
                  _syncShiftInfos();
                  _isRegistered = false;
                }),
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  /// 타임별 상세 설정 섹션
  Widget _buildDetailedSettingsSection() {
    if (_selectedDays.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("타임별 상세 설정",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFE8E9ED)),
          ),
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              ...List.generate(_shiftInfos.length, (index) {
                return ShiftTimeCard(
                  index: index,
                  info: _shiftInfos[index],
                  onChanged: () => setState(() => _isRegistered = false),
                );
              }),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: _canRegister ? _onRegisterPressed : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        _canRegister ? const Color(0xFF0084FF) : const Color(0xFFF2F2F5),
                    disabledBackgroundColor: const Color(0xFFF2F2F5),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)),
                  ),
                  child: Text(
                    "등록하기",
                    style: TextStyle(
                      color: _canRegister ? Colors.white : const Color(0xFF6C6E76),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// 하단 고정 버튼 (스케줄 만들기)
  Widget _buildBottomButton() {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        child: SizedBox(
          height: 56,
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _isRegistered
                ? () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const RStoreClosePage()),
                    )
                : null,
            style: ElevatedButton.styleFrom(
              backgroundColor:
                  _isRegistered ? const Color(0xFF0084FF) : const Color(0xFFA9D0FB),
              disabledBackgroundColor: const Color(0xFFA9D0FB),
              elevation: 0,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text(
              "스케줄 만들기",
              style: TextStyle(
                  color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ),
    );
  }
}

/// 기등록된 스케줄 데이터 모델
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
