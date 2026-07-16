import 'package:flutter/material.dart';
import '../RHomePage.dart';
import '../autoschedule/api/ScheduleConditionsApi.dart';
import 'RSubmitStatus.dart';

class RScheduleCard extends StatefulWidget {
  final HomeCardType type;
  final int daysLeft;
  final VoidCallback? onMakeScheduleTap;
  final VoidCallback? onClose;
  final int? workPlaceId;
  final int? weekScheduleId;
  final int? notSubmittedCount; // ✅ 추가: 서버에서 받아온 미제출 인원 수
  final Future<void> Function()? onResetConditions; // ✅ 추가: 조건 초기화 성공 후 부모에서 갱신하도록 알림

  const RScheduleCard({
    super.key,
    required this.type,
    required this.daysLeft,
    this.onMakeScheduleTap,
    this.onClose,
    this.workPlaceId,
    this.weekScheduleId,
    this.notSubmittedCount, // ✅ 추가
    this.onResetConditions, // ✅ 추가
  });

  @override
  State<RScheduleCard> createState() => _RScheduleCardState();
}

class _RScheduleCardState extends State<RScheduleCard> {
  bool _isResetting = false;

  String get _imagePath {
    switch (widget.type) {
      case HomeCardType.weeklySchedule:
        return "assets/images/r_weeklySchedule_card.png";

      case HomeCardType.scheduleCreationAvailable:
        return "assets/images/r_scheduleCreationAvailable_card.png";

      case HomeCardType.submissionStatus:
        return "assets/images/r_submissionStatus_card.png";

      case HomeCardType.none:
        return "";
    }
  }

  String get _buttonText {
    switch (widget.type) {
      case HomeCardType.weeklySchedule:
        return "스케줄 조건 만들기";

      case HomeCardType.scheduleCreationAvailable:
        return "자동 스케줄 생성하기";

      case HomeCardType.submissionStatus:
        return "제출 현황 보기";

      case HomeCardType.none:
        return "";
    }
  }

  String get nextWeekRange {
    final now = DateTime.now();

    DateTime nextMonday;

    if (now.weekday == DateTime.monday) {
      nextMonday = now.add(const Duration(days: 14));
    } else {
      nextMonday = now.add(
        Duration(days: 8 - now.weekday),
      );
    }

    final nextSunday = nextMonday.add(const Duration(days: 6));

    return "${nextMonday.month}월 ${nextMonday.day}일 - ${nextSunday.month}월 ${nextSunday.day}일";
  }

  Future<void> _onResetConditionsTap() async {
    if (widget.workPlaceId == null || widget.weekScheduleId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "스케줄 정보를 불러오지 못했어요. (workPlaceId 또는 weekScheduleId 없음)",
          ),
        ),
      );
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: Colors.white, // 다이얼로그 배경색 흰색
        title: const Text(
          "스케줄 조건 초기화",
          textAlign: TextAlign.center, // 제목 가운데 정렬
        ),
        content: const Text(
          "설정된 스케줄 조건을 초기화할까요?\n이 작업은 되돌릴 수 없어요.",
          textAlign: TextAlign.center, // 본문 가운데 정렬
        ),
        actionsAlignment: MainAxisAlignment.center, // 버튼들도 가운데 정렬(선택)
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
        workPlaceId: widget.workPlaceId!,
        weekScheduleId: widget.weekScheduleId!,
      );

      debugPrint("========== resetConditions 성공 ==========");

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("스케줄 조건이 초기화되었어요."),
        ),
      );

      if (widget.onResetConditions != null) {
        debugPrint("========== 부모 callback 호출 ==========");
        await widget.onResetConditions!.call();
        debugPrint("========== 부모 callback 완료 ==========");
      } else {
        debugPrint("========== 부모 callback 없음 ==========");
      }
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
    if (widget.type == HomeCardType.none) {
      return const SizedBox.shrink();
    }

    return SizedBox(
      width: double.infinity,
      child: AspectRatio(
        aspectRatio: 1080 / 693,
        child: Stack(
          children: [
            Positioned.fill(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Image.asset(
                  _imagePath,
                  fit: BoxFit.cover,
                ),
              ),
            ),

            /// 다음주 스케줄 제출
            if (widget.type == HomeCardType.weeklySchedule)
              Positioned(
                left: 20,
                bottom: 115,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFBFE1FF),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    nextWeekRange,
                    style: const TextStyle(
                      color: Color(0xFF0084FF),
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),

            /// 스케줄 생성 가능
            if (widget.type == HomeCardType.scheduleCreationAvailable)
              Positioned(
                left: 20,
                bottom: 115,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFBFE1FF),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    // notSubmittedCount가 있으면 그 값을, 없으면 로딩 중 문구
                    widget.notSubmittedCount != null
                        ? "미제출 근무자 ${widget.notSubmittedCount}명"
                        : "미제출 인원 확인 중",
                    style: const TextStyle(
                      color: Color(0xFF0084FF),
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),

            /// 제출 현황
            if (widget.type == HomeCardType.submissionStatus)
              Positioned(
                left: 20,
                bottom: 115,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFBFE1FF),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    "마감까지 ${widget.daysLeft}일",
                    style: const TextStyle(
                      color: Color(0xFF0084FF),
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),

            /// 스케줄 조건 초기화 (스케줄 만들기 버튼 바로 위, weeklySchedule 타입에서만 노출)
            if (widget.type == HomeCardType.weeklySchedule)
              Positioned(
                left: 24,
                bottom: 16 + 52 + 8, // 하단 버튼(52) + 여백(8) 위쪽
                child: TextButton(
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
              ),

            /// 하단 버튼
            Positioned(
              left: 24,
              right: 24,
              bottom: 16,
              child: SizedBox(
                height: 52,
                child: ElevatedButton(
                  onPressed: () {
                    debugPrint(
                        "[RScheduleCard] 버튼 클릭 - type=${widget.type}, workPlaceId=${widget.workPlaceId}, weekScheduleId=${widget.weekScheduleId}");

                    if (widget.type == HomeCardType.submissionStatus) {
                      if (widget.workPlaceId == null ||
                          widget.weekScheduleId == null) {
                        debugPrint(
                            "[RScheduleCard] 이동 취소 - workPlaceId 또는 weekScheduleId가 null");

                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              "스케줄 정보를 불러오지 못했어요. (workPlaceId 또는 weekScheduleId 없음)",
                            ),
                          ),
                        );
                        return;
                      }

                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => RSubmitStatusPage(
                            workPlaceId: widget.workPlaceId!,
                            weekScheduleId: widget.weekScheduleId!,
                          ),
                        ),
                      );
                    } else {
                      widget.onMakeScheduleTap?.call();
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0084FF),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: Text(
                    _buttonText,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
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