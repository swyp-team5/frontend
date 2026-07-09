import 'package:flutter/material.dart';
import '../schedule/api/ConfirmedSchedulesApi.dart';
import '../schedule/models/ConfirmedSchedulesResponse.dart';

class RTodayWorkingPage extends StatefulWidget {
  final int workPlaceId;

  //==========================================================
  // 개발용 — 테스트하고 싶은 날짜를 지정 (null이면 실제 오늘 날짜 사용)
  //==========================================================

  // static final DateTime? debugDate = DateTime(2026, 7, 16);
  static const DateTime? debugDate = null; // 실제 오늘 날짜로 되돌릴 때는 이걸로 교체

  const RTodayWorkingPage({
    super.key,
    required this.workPlaceId,
  });

  @override
  State<RTodayWorkingPage> createState() => _RTodayWorkingPageState();
}

class _RTodayWorkingPageState extends State<RTodayWorkingPage> {
  bool _isLoading = true;
  String? _error;
  List<ConfirmedTimeDetail> _todayTimeDetails = [];

  /// timeName -> (배경색, 텍스트색) 매핑. 데이터를 불러올 때마다 생성됨.
  final Map<String, _RoleColorSet> _roleColorMap = {};

  /// 순환할 색상 팔레트. timeName 종류가 늘어나도 순서대로 배정됨.
  static const List<_RoleColorSet> _colorPalette = [
    _RoleColorSet(Color(0xFFE6F3FF), Color(0xFF0084FF)), // 파랑
    _RoleColorSet(Color(0xFFEEEBFF), Color(0xFF7D67FD)), // 보라
    _RoleColorSet(Color(0xFFD0F9D5), Color(0xFF0FA48B)), // 초록
    // _RoleColorSet(Color(0xFFFFF1D6), Color(0xFFFF9800)), // 주황
    // _RoleColorSet(Color(0xFFFFE1E6), Color(0xFFFF4D67)), // 핑크
    // _RoleColorSet(Color(0xFFE1F7FF), Color(0xFF00B6D9)), // 하늘
  ];

  @override
  void initState() {
    super.initState();
    _fetchTodaySchedule();
  }

  /// 한국(KST, UTC+9) 기준 "오늘" 날짜를 계산.
  /// debugDate가 지정되어 있으면 테스트를 위해 그 날짜를 그대로 사용.
  DateTime _todayInKorea() {
    if (RTodayWorkingPage.debugDate != null) {
      return RTodayWorkingPage.debugDate!;
    }

    final nowUtc = DateTime.now().toUtc();
    final nowKst = nowUtc.add(const Duration(hours: 9));
    return DateTime(nowKst.year, nowKst.month, nowKst.day);
  }

  /// timeDetails에 등장하는 timeName들에 순서대로 팔레트 색을 배정
  void _buildRoleColorMap(List<ConfirmedTimeDetail> details) {
    _roleColorMap.clear();
    var colorIndex = 0;

    for (final detail in details) {
      if (!_roleColorMap.containsKey(detail.timeName)) {
        _roleColorMap[detail.timeName] =
        _colorPalette[colorIndex % _colorPalette.length];
        colorIndex++;
      }
    }
  }

  Future<void> _fetchTodaySchedule() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final today = _todayInKorea();

      final result = await ConfirmedSchedulesApi.getConfirmedSchedules(
        workPlaceId: widget.workPlaceId,
        from: today,
        to: today,
      );

      final todayString =
          "${today.year.toString().padLeft(4, '0')}-"
          "${today.month.toString().padLeft(2, '0')}-"
          "${today.day.toString().padLeft(2, '0')}";

      final todayDay = result.days.firstWhere(
            (d) => d.workDate == todayString,
        orElse: () => ConfirmedScheduleDay(
          workDate: todayString,
          dayName: "",
          timeDetails: [],
        ),
      );

      if (!mounted) return;

      _buildRoleColorMap(todayDay.timeDetails);

      setState(() {
        _todayTimeDetails = todayDay.timeDetails;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  /// timeName에 따른 배경색 (매핑에 없으면 기본 회색)
  Color _roleColor(String timeName) {
    return _roleColorMap[timeName]?.background ?? const Color(0xFFF2F2F5);
  }

  /// timeName에 따른 텍스트색 (매핑에 없으면 기본 회색)
  Color _textColor(String timeName) {
    return _roleColorMap[timeName]?.text ?? Colors.grey;
  }

  String _formatTimeRange(String startTime, String closeTime) {
    // "09:00:00" -> "09:00"
    final start =
    startTime.length >= 5 ? startTime.substring(0, 5) : startTime;
    final close =
    closeTime.length >= 5 ? closeTime.substring(0, 5) : closeTime;
    return "$start - $close";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            /// 상단 헤더
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 30,
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: const Icon(
                        Icons.arrow_back_ios_new,
                        size: 22,
                        color: Colors.black,
                      ),
                    ),
                  ),
                  const Center(
                    child: Text(
                      "오늘 근무",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            Expanded(
              child: _buildBody(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              "근무 정보를 불러오지 못했어요",
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: _fetchTodaySchedule,
              child: const Text("다시 시도"),
            ),
          ],
        ),
      );
    }

    if (_todayTimeDetails.isEmpty) {
      return const Center(
        child: Text(
          "오늘 등록된 근무가 없어요",
          style: TextStyle(color: Colors.grey),
        ),
      );
    }

    return ListView.separated(
      padding: EdgeInsets.zero,
      itemCount: _todayTimeDetails.length,
      separatorBuilder: (_, __) => const Divider(
        height: 1,
        color: Color(0xFFF1F1F5),
      ),
      itemBuilder: (context, index) {
        final detail = _todayTimeDetails[index];
        final memberNames = detail.workers.map((w) => w.name).toList();

        return _WorkingSection(
          label: detail.timeName,
          labelColor: _roleColor(detail.timeName),
          textColor: _textColor(detail.timeName),
          time: _formatTimeRange(detail.startTime, detail.closeTime),
          members: memberNames,
        );
      },
    );
  }
}

class _WorkingSection extends StatelessWidget {
  final String label;
  final Color labelColor;
  final Color textColor;
  final String time;
  final List<String> members;

  const _WorkingSection({
    required this.label,
    required this.labelColor,
    required this.textColor,
    required this.time,
    required this.members,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 20,
        vertical: 20,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// 근무 타입 + 시간
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: labelColor,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  label,
                  style: TextStyle(
                    color: textColor,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),

              const SizedBox(width: 10),

              Text(
                time,
                style: const TextStyle(
                  fontSize: 15,
                  color: Color(0xFF767676),
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          /// 근무자 목록
          if (members.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: Text(
                "배정된 근무자가 없어요",
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                ),
              ),
            )
          else
            ...members.map(
                  (member) => Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
                child: Text(
                  member,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Colors.black,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// timeName별 (배경색, 텍스트색) 한 쌍을 담는 헬퍼 클래스
class _RoleColorSet {
  final Color background;
  final Color text;

  const _RoleColorSet(this.background, this.text);
}