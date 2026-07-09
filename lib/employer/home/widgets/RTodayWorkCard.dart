import 'package:flutter/material.dart';
import '../../mypage/RTodayWorkingPage.dart';
import '../../schedule/api/ConfirmedSchedulesApi.dart';
import '../../schedule/models/ConfirmedSchedulesResponse.dart';

class RTodayWorkCard extends StatefulWidget {
  final int workPlaceId;
  final VoidCallback? onDetailTap;

  //==========================================================
  // 개발용 — 테스트하고 싶은 날짜를 지정 (null이면 실제 오늘 날짜 사용)
  //==========================================================

  // static final DateTime? debugDate = DateTime(2026, 7, 16);
  static const DateTime? debugDate = null; // 실제 오늘 날짜로 되돌릴 때는 이걸로 교체

  const RTodayWorkCard({
    super.key,
    required this.workPlaceId,
    this.onDetailTap,
  });

  @override
  State<RTodayWorkCard> createState() => _RTodayWorkCardState();
}

class _RTodayWorkCardState extends State<RTodayWorkCard> {
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
    if (RTodayWorkCard.debugDate != null) {
      return RTodayWorkCard.debugDate!;
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
    final start = startTime.length >= 5 ? startTime.substring(0, 5) : startTime;
    final close = closeTime.length >= 5 ? closeTime.substring(0, 5) : closeTime;
    return "$start-$close";
  }

  /// "자세히 보기" 탭 시 RTodayWorkingPage로 이동.
  /// widget.onDetailTap이 별도로 주어졌다면 이동 후(또는 이동과 별개로) 함께 호출.
  void _handleDetailTap() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => RTodayWorkingPage(
          workPlaceId: widget.workPlaceId,
        ),
      ),
    );

    widget.onDetailTap?.call();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        children: [
          Row(
            children: const [
              Text(
                "오늘 근무",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),

          const SizedBox(height: 18),

          if (_isLoading)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 24),
              child: CircularProgressIndicator(),
            )
          else if (_error != null)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 24),
              child: Text(
                "근무 정보를 불러오지 못했어요",
                style: TextStyle(color: Colors.grey),
              ),
            )
          else if (_todayTimeDetails.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 24),
                child: Text(
                  "오늘 등록된 근무가 없어요",
                  style: TextStyle(color: Colors.grey),
                ),
              )
            else
              Column(
                children: List.generate(_todayTimeDetails.length, (index) {
                  final detail = _todayTimeDetails[index];
                  final employeeNames =
                  detail.workers.map((w) => w.name).join(", ");

                  return Column(
                    children: [
                      _workRow(
                        role: detail.timeName,
                        roleColor: _roleColor(detail.timeName),
                        textColor: _textColor(detail.timeName),
                        time: _formatTimeRange(
                            detail.startTime, detail.closeTime),
                        employee: employeeNames,
                      ),
                      if (index != _todayTimeDetails.length - 1)
                        const Divider(
                          height: 40,
                          thickness: 1,
                          color: Color(0xFFF2F2F5),
                        ),
                    ],
                  );
                }),
              ),

          const SizedBox(height: 18),

          InkWell(
            onTap: _handleDetailTap,
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "자세히 보기",
                  style: TextStyle(
                    color: Colors.grey,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(width: 4),
                Icon(
                  Icons.chevron_right,
                  color: Colors.grey,
                  size: 18,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _workRow({
    required String role,
    required Color roleColor,
    required Color textColor,
    required String time,
    required String employee,
  }) {
    return Row(
      children: [
        Container(
          width: 52,
          alignment: Alignment.center,
          padding: const EdgeInsets.symmetric(
            vertical: 6,
          ),
          decoration: BoxDecoration(
            color: roleColor,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            role,
            style: TextStyle(
              color: textColor,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),

        const SizedBox(width: 12),

        SizedBox(
          width: 95,
          child: Text(
            time,
            style: const TextStyle(
              fontWeight: FontWeight.w500,
            ),
          ),
        ),

        Expanded(
          child: Text(
            employee,
            textAlign: TextAlign.end,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}

/// timeName별 (배경색, 텍스트색) 한 쌍을 담는 헬퍼 클래스
class _RoleColorSet {
  final Color background;
  final Color text;

  const _RoleColorSet(this.background, this.text);
}