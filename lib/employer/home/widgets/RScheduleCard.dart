import 'package:flutter/material.dart';
import '../RHomePage.dart';
import 'RSubmitStatus.dart';

class RScheduleCard extends StatefulWidget {
  final HomeCardType type;
  final int daysLeft;
  final VoidCallback? onMakeScheduleTap;
  final VoidCallback? onClose;
  final int? workPlaceId;
  final int? weekScheduleId;
  final int? notSubmittedCount; // ✅ 추가: 서버에서 받아온 미제출 인원 수

  const RScheduleCard({
    super.key,
    required this.type,
    required this.daysLeft,
    this.onMakeScheduleTap,
    this.onClose,
    this.workPlaceId,
    this.weekScheduleId,
    this.notSubmittedCount, // ✅ 추가
  });

  @override
  State<RScheduleCard> createState() => _RScheduleCardState();
}

class _RScheduleCardState extends State<RScheduleCard> {
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