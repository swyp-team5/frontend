import 'package:chack_chack/employer/home/widgets/RWorkChangeRejectBottomSheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

import '../../schedule/api/ConfirmedSchedulesApi.dart';
import 'RWorkChangeAcceptBottomSheet.dart';
import 'RWorkChangeRequestListPage.dart' show WorkChangeRequestItem;


/// assignmentId 하나에 대응하는 근무 날짜/시간 정보
class _AssignmentTimeInfo {
  final DateTime date;
  final String dayName;
  final String timeName;
  final String startTime;
  final String closeTime;

  _AssignmentTimeInfo({
    required this.date,
    required this.dayName,
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

/// 대상 근무자가 요청을 수락하여 사장님의 최종 승인을 기다리는
/// 교대/대타 요청 상세(승인) 페이지.
///
/// RWorkChangeRequestListPage에서 status == "ACCEPTED_BY_TARGET" 인
/// 카드를 탭했을 때 이 페이지로 이동한다.
class RWorkChangeRequestDetailPage extends StatefulWidget {
  final WorkChangeRequestItem item;
  final String requesterName;
  final String? targetName;

  const RWorkChangeRequestDetailPage({
    super.key,
    required this.item,
    required this.requesterName,
    required this.targetName,
  });

  @override
  State<RWorkChangeRequestDetailPage> createState() =>
      _RWorkChangeRequestDetailPageState();
}

class _RWorkChangeRequestDetailPageState
    extends State<RWorkChangeRequestDetailPage> {
  bool _isLoadingTimes = true;

  // 조회 자체가 실패했는지 (네트워크/인증/서버 에러 등)
  bool _loadFailed = false;

  // 신청자(왼쪽) / 대상자(오른쪽) 근무 날짜·시간
  String? _applicantDate;
  String? _applicantTime;
  String? _targetDate;
  String? _targetTime;

  @override
  void initState() {
    super.initState();
    _loadAssignmentTimes();
  }

  String _typeTitle() {
    final upper = widget.item.requestType.toUpperCase();
    if (upper.contains("SUBSTITUTE")) return "대타 근무";
    if (upper.contains("SHIFT") || upper.contains("EXCHANGE")) return "교대 근무";
    return widget.item.requestType;
  }

  /// 상태값에 따른 배지 텍스트 (RWorkChangeRequestListPage의 _badgeText와 동일 규칙)
  String _statusBadgeText() {
    switch (widget.item.status.toUpperCase()) {
      case "ACCEPTED_BY_TARGET":
        return "답변 대기";
      case "APPROVED":
        return "수락 완료";
      case "REJECTED_BY_OWNER":
        return "거절 완료";
      default:
        return widget.item.status;
    }
  }

  /// 상태값에 따른 배지 색상 (RWorkChangeRequestListPage의 _badgeColor와 동일 규칙)
  Color _statusBadgeColor() {
    switch (widget.item.status.toUpperCase()) {
      case "ACCEPTED_BY_TARGET":
        return const Color(0xFF00B475);
      case "APPROVED":
        return const Color(0xFF0084FF);
      case "REJECTED_BY_OWNER":
        return const Color(0xFFFF4D4F);
      default:
        return const Color(0xFF8E8E93);
    }
  }

  /// requestAssignmentId / targetAssignmentId에 해당하는 날짜·시간을 찾기 위해
  /// 사장님(owner) 권한으로 조회 가능한 확정 근무표(ConfirmedSchedulesApi)를
  /// 조회하고 assignmentId -> 시간 정보로 매핑한다.
  ///
  /// 정확한 날짜를 미리 알 수 없으므로, 요청 생성일(createdAt) 기준
  /// 앞뒤로 넉넉한 기간을 조회한다.
  Future<void> _loadAssignmentTimes() async {
    final item = widget.item;

    // 둘 다 없으면 조회할 필요가 없다.
    if (item.requestAssignmentId == null && item.targetAssignmentId == null) {
      if (!mounted) return;
      setState(() => _isLoadingTimes = false);
      return;
    }

    try {
      // 서버 정책: from은 오늘 이전일 수 없을 가능성이 있으므로 동일하게 방어.
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final createdAt = item.createdAt ?? now;
      final createdDate =
      DateTime(createdAt.year, createdAt.month, createdAt.day);

      final from = createdDate.isBefore(today) ? today : createdDate;
      final to = from.add(const Duration(days: 60));

      final schedules = await ConfirmedSchedulesApi.getConfirmedSchedules(
        workPlaceId: item.workPlaceId,
        from: from,
        to: to,
      );

      final Map<int, _AssignmentTimeInfo> map = {};
      for (final day in schedules.days) {
        final date = DateTime.parse(day.workDate);
        for (final timeDetail in day.timeDetails) {
          for (final worker in timeDetail.workers) {
            map[worker.assignmentId] = _AssignmentTimeInfo(
              date: date,
              dayName: day.dayName,
              timeName: timeDetail.timeName,
              startTime: timeDetail.startTime,
              closeTime: timeDetail.closeTime,
            );
          }
        }
      }

      if (!mounted) return;

      final applicantInfo = item.requestAssignmentId != null
          ? map[item.requestAssignmentId]
          : null;

      // SUBSTITUTE(대타) 요청은 서로 다른 두 근무를 맞바꾸는 게 아니라
      // 신청자의 근무 하나가 그대로 대상자에게 넘어가는 방식이라
      // targetAssignmentId가 없다. 이 경우 오른쪽(대상자)에도 같은 근무
      // 정보를 보여줘야 "이 근무가 대상자에게 배정됩니다"라는 의미가 자연스럽다.
      final targetInfo = item.targetAssignmentId != null
          ? map[item.targetAssignmentId]
          : (item.requestType.toUpperCase() == "SUBSTITUTE"
          ? applicantInfo
          : null);

      setState(() {
        _applicantDate = applicantInfo?.dateLabel ?? "-";
        _applicantTime = applicantInfo?.timeLabel ?? "-";
        _targetDate = targetInfo?.dateLabel ?? "-";
        _targetTime = targetInfo?.timeLabel ?? "-";
        _isLoadingTimes = false;
        _loadFailed = false;
      });
    } catch (e, st) {
      debugPrint('[WorkChangeDetail] 조회 실패: $e');
      debugPrint('$st');

      if (!mounted) return;
      setState(() {
        _applicantDate ??= "-";
        _applicantTime ??= "-";
        _targetDate ??= "-";
        _targetTime ??= "-";
        _isLoadingTimes = false;
        _loadFailed = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final item = widget.item;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            /// 헤더
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 30,
              ),
              child: SizedBox(
                height: 24,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Positioned(
                      left: 0,
                      child: GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: () => Navigator.of(context).pop(),
                        child: const Icon(
                          Icons.chevron_left,
                          size: 28,
                        ),
                      ),
                    ),
                    const Center(
                      child: Text(
                        "받은 승인 내역",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          _typeTitle(),
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: _statusBadgeColor().withOpacity(.12),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            _statusBadgeText(),
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: _statusBadgeColor(),
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),

                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 20,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF5F5F7),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: _isLoadingTimes
                          ? const Padding(
                        padding: EdgeInsets.symmetric(vertical: 8),
                        child: Center(
                          child: SizedBox(
                            width: 20,
                            height: 20,
                            child:
                            CircularProgressIndicator(strokeWidth: 2),
                          ),
                        ),
                      )
                          : Column(
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: _ShiftSideInfo(
                                  name: widget.requesterName,
                                  date: _applicantDate ?? "-",
                                  time: _applicantTime ?? "-",
                                ),
                              ),
                              const Icon(
                                Icons.swap_horiz,
                                color: Color(0xFF8E8E93),
                              ),
                              Expanded(
                                child: _ShiftSideInfo(
                                  name: widget.targetName ?? "",
                                  date: _targetDate ?? "-",
                                  time: _targetTime ?? "-",
                                ),
                              ),
                            ],
                          ),
                          if (_loadFailed) ...[
                            const SizedBox(height: 10),
                            const Text(
                              "근무 시간 정보를 불러오지 못했습니다. "
                                  "새로고침 후 다시 시도해 주세요.",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 12,
                                color: Color(0xFFFF4D4F),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    _InfoRow(label: "교대 신청자", value: widget.requesterName),

                    if (item.reason != null && item.reason!.isNotEmpty) ...[
                      const SizedBox(height: 16),
                      _InfoRow(label: "교대 신청 사유", value: item.reason!),
                    ],

                    const Spacer(),

                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            style: OutlinedButton.styleFrom(
                              padding:
                              const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              side: const BorderSide(
                                color: Color(0xFFDADADA),
                              ),
                            ),
                            onPressed: () {
                              showModalBottomSheet(
                                context: context,
                                backgroundColor: Colors.transparent,
                                isScrollControlled: true,
                                builder: (_) => RWorkChangeRejectBottomSheet(
                                  workPlaceId: item.workPlaceId,
                                  requestId: item.workChangeRequestId,
                                  onSuccess: () {
                                    Navigator.of(context).pop("REJECTED");
                                  },
                                ),
                              );
                            },
                            child: const Text(
                              "거절",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.black,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF0084FF),
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 0,
                            ),
                            onPressed: () {
                              showModalBottomSheet(
                                context: context,
                                backgroundColor: Colors.transparent,
                                isScrollControlled: true,
                                builder: (_) => RWorkChangeAcceptBottomSheet(
                                  workPlaceId: item.workPlaceId,
                                  requestId: item.workChangeRequestId,
                                  onSuccess: () {
                                    Navigator.of(context).pop("APPROVED");
                                  },
                                ),
                              );
                            },
                            child: const Text(
                              "수락",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ],
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

class _ShiftSideInfo extends StatelessWidget {
  final String name;
  final String date;
  final String time;

  const _ShiftSideInfo({
    required this.name,
    required this.date,
    required this.time,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            name,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Color(0xFF444444),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          date,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          time,
          style: const TextStyle(
            fontSize: 13,
            color: Color(0xFF767676),
          ),
        ),
      ],
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            color: Color(0xFF767676),
          ),
        ),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.right,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}