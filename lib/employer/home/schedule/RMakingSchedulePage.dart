import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

import 'RRecentSchedulePage.dart';
import 'TimeInputBottomSheet.dart';
import 'widgets/ShiftTimeCard.dart';
import 'widgets/CounterBox.dart';
import 'models/ShiftInfo.dart';
import 'RStoreClosePage.dart';

class RMakingSchedulePage extends StatefulWidget {
  final int workPlaceId;
  const RMakingSchedulePage({super.key, required this.workPlaceId});

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

  /// 이미 "등록하기"로 확정되어 _registeredSchedules에 포함된 요일들.
  /// 이 요일들은 요일 선택 섹션에서 다시 선택하지 못하도록 비활성화한다.
  Set<String> get _registeredDays =>
      _registeredSchedules.expand((s) => s.days).toSet();

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

  /// TimeOfDay를 하루 중 분 단위 정수로 변환 (시간 비교용)
  int _toMinutes(TimeOfDay time) => time.hour * 60 + time.minute;

  /// 운영 시간 선택 바텀시트 오픈
  void _openTimePicker({int initialIndex = 0}) async {
    final result = await TimeInputBottomSheet.show(
      context,
      initialOpenTime: _openTime,
      initialCloseTime: _closeTime,
      // initialIndex: initialIndex,
    );

    if (result != null) {
      // 오픈 시간이 마감 시간보다 늦거나 같으면 안내하고 반영하지 않는다.
      // (서버 검증 5번: "가게 오픈 시간은 마감 시간보다 빨라야 합니다.")
      if (_toMinutes(result.openTime) >= _toMinutes(result.closeTime)) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("가게 오픈 시간은 마감 시간보다 빨라야 합니다."),
          ),
        );
        return;
      }

      setState(() {
        _openTime = result.openTime;
        _closeTime = result.closeTime;
        _isRegistered = false; // 설정 변경 시 재등록 필요
      });
    }
  }

  /// '등록하기' 버튼 클릭 전, 서버로 보내기 전에 미리 검증해서
  /// 아래 조건 중 하나라도 어긋나면 등록을 막고 안내 메시지를 반환한다.
  ///
  /// - (5) 오픈 시간 < 마감 시간
  /// - (6) 최소 근무 횟수 <= 최대 근무 횟수
  /// - 요일 미선택 (안전장치)
  /// - (11) 각 타임의 시작 시간 < 종료 시간
  /// - (12) 각 타임이 매장 운영 시간 범위 안에 있는지
  /// - (13) 같은 교대 안에서 타임끼리 겹치지 않는지
  String? _validateBeforeRegister() {
    // 5. 오픈 시간 < 마감 시간
    if (_toMinutes(_openTime) >= _toMinutes(_closeTime)) {
      return "가게 오픈 시간은 마감 시간보다 빨라야 합니다.";
    }

    // 6. 최소 근무 횟수 <= 최대 근무 횟수 (CounterBox의 minValue로도 막고 있지만 이중 안전장치)
    if (_minWork > _maxWork) {
      return "최소 근무 횟수는 최대 근무 횟수보다 클 수 없습니다.";
    }

    // 요일이 선택되지 않은 경우 (이 섹션 자체가 UI상 필수 흐름이므로 안전장치로 추가)
    if (_selectedDays.isEmpty) {
      return "요일을 선택해주세요.";
    }

    // 타임별 상세 설정 검증
    for (final shift in _shiftInfos) {
      final startM = _toMinutes(shift.startTime);
      final endM = _toMinutes(shift.endTime);

      // 11. 시작 시간 < 종료 시간
      if (startM >= endM) {
        return "근무 시작 시간은 종료 시간보다 빨라야 합니다.";
      }

      // 12. 근무 시간은 매장 운영 시간(오픈~마감) 범위 안에 있어야 함
      if (startM < _toMinutes(_openTime) || endM > _toMinutes(_closeTime)) {
        return "근무 시간은 가게 운영 시간 안에 있어야 합니다.";
      }
    }

    // 13. 같은 교대(등록 단위) 내 타임끼리 서로 겹치지 않는지 확인
    for (int i = 0; i < _shiftInfos.length; i++) {
      for (int j = i + 1; j < _shiftInfos.length; j++) {
        final a = _shiftInfos[i];
        final b = _shiftInfos[j];

        final aStart = _toMinutes(a.startTime);
        final aEnd = _toMinutes(a.endTime);
        final bStart = _toMinutes(b.startTime);
        final bEnd = _toMinutes(b.endTime);

        final overlaps = aStart < bEnd && bStart < aEnd;

        if (overlaps) {
          return "교대 시간이 겹칩니다. "
              "(${_formatTime(a.startTime)}~${_formatTime(a.endTime)} / "
              "${_formatTime(b.startTime)}~${_formatTime(b.endTime)})";
        }
      }
    }

    return null; // 문제 없음
  }

  /// '등록하기' 버튼 클릭 시
  void _onRegisterPressed() {
    final errorMessage = _validateBeforeRegister();

    if (errorMessage != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(errorMessage)),
      );
      return; // 조건을 만족하지 못하면 등록하지 않음
    }

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

  Future<void> _saveRecentSchedule() async {
    final prefs = await SharedPreferences.getInstance();

    final data = {
      "openTime": _formatTime(_openTime),
      "closeTime": _formatTime(_closeTime),
      "minWork": _minWork,
      "maxWork": _maxWork,
      "registeredSchedules": _registeredSchedules.map((schedule) {
        return {
          "days": schedule.days.toList(),
          "shifts": schedule.shifts.map((shift) {
            return {
              "name": shift.name,
              "startTime": _formatTime(shift.startTime),
              "endTime": _formatTime(shift.endTime),
              "breakTime": shift.breakTime,
              "requiredWorkers": shift.requiredWorkers,
            };
          }).toList(),
        };
      }).toList(),
    };

    await prefs.setString(
      "recent_schedule",
      jsonEncode(data),
    );
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
                child: SizedBox(
                  height: 30,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      /// 가운데 제목
                      const Center(
                        child: Text(
                          "스케줄 만들기",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),

                      /// 왼쪽 뒤로가기
                      Align(
                        alignment: Alignment.centerLeft,
                        child: GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: const Icon(
                            Icons.arrow_back_ios_new,
                          ),
                        ),
                      ),

                      /// 오른쪽 불러오기
                      Align(
                        alignment: Alignment.centerRight,
                        child: GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => RRecentSchedulePage(
                                  workPlaceId:widget.workPlaceId,
                                ),
                              ),
                            );
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
                      ),
                    ],
                  ),
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
            final bool isAlreadyRegistered = _registeredDays.contains(day);

            return GestureDetector(
              // 이미 등록된(확정된) 요일은 탭해도 반응하지 않도록 비활성화
              onTap: isAlreadyRegistered
                  ? null
                  : () => setState(() {
                isSelected ? _selectedDays.remove(day) : _selectedDays.add(day);
                _isRegistered = false;
              }),
              child: Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: isAlreadyRegistered
                      ? const Color(0xFFF2F2F5) // 비활성 배경 (선택 불가)
                      : isSelected
                      ? const Color(0xFF0084FF)
                      : const Color(0xFFF2F2F5),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(
                    day,
                    style: TextStyle(
                      color: isAlreadyRegistered
                          ? const Color(0xFFD0D3DA) // 비활성 텍스트 (더 옅은 회색)
                          : isSelected
                          ? Colors.white
                          : const Color(0xFFAEB0B6),
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
                ? () async {
              await _saveRecentSchedule();

              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => RStoreClosePage(
                    workPlaceId: widget.workPlaceId, // 생성자에 추가 필요
                    openTime: _openTime,
                    closeTime: _closeTime,
                    minWork: _minWork,
                    maxWork: _maxWork,
                    registeredSchedules: _registeredSchedules,
                  ),
                ),
              );
            }
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