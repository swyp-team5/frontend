import 'package:flutter/material.dart';
import '../../schedule/EMainSchedulePage.dart';
import '../EHomePage.dart';
import '../application/ExchangeRequest.dart';
import '../application/SubstituteRequest.dart';
import '../application/SentWorkChangeRequestsPage.dart';

class EScheduleCard extends StatelessWidget {
  final HomeCardType type;
  final int daysLeft;
  final VoidCallback? onClose;
  final VoidCallback? onDetailTap;

  /// substituteRequest / shiftRequest 타입 카드에서 상세 화면으로 이동할 때 필요
  final int? workPlaceId;
  final int? workChangeRequestId;

  /// substituteRequest 타입 카드에서 실제 대타 근무 날짜/시간을 표시하기 위해 필요.
  /// SubstituteRequest 상세 화면의 targetDate / targetTime과 동일한 포맷의
  /// 문자열을 그대로 받는다. (예: "6월 27일", "16:00~20:00")
  /// 부모 위젯(EHomePage)에서 AssignmentResolver 등으로 미리 조회해서 넘겨줘야 한다.
  final String? substituteDateLabel;
  final String? substituteTimeLabel;

  /// shiftRequest 타입 카드에서 실제 교대 근무 날짜/시간을 표시하기 위해 필요.
  /// ExchangeRequest 상세 화면의 _applicantDate/_applicantTime, _myDate/_myTime과
  /// 동일한 값을 그대로 받는다.
  /// 부모 위젯(EHomePage)에서 미리 조회해서 넘겨줘야 한다.
  final String? applicantDateLabel;
  final String? applicantTimeLabel;
  final String? myDateLabel;
  final String? myTimeLabel;

  const EScheduleCard({
    super.key,
    required this.type,
    required this.daysLeft,
    this.onClose,
    this.onDetailTap,
    this.workPlaceId,
    this.workChangeRequestId,
    this.substituteDateLabel,
    this.substituteTimeLabel,
    this.applicantDateLabel,
    this.applicantTimeLabel,
    this.myDateLabel,
    this.myTimeLabel,
  });

  //-----------------------------------------
  // 카드에 필요한 실제 데이터가 있는지 여부
  //-----------------------------------------

  /// shiftRequest / substituteRequest 타입은 실제 날짜 데이터가 없으면
  /// (즉, 아직 로딩 전이거나 조회 실패 상태라면) 카드를 아예 표시하지 않는다.
  /// 그 외 타입은 별도의 필수 데이터가 없으므로 항상 표시 대상으로 본다.
  bool get _hasRequiredData {
    switch (type) {
      case HomeCardType.shiftRequest:
        return applicantDateLabel != null &&
            applicantDateLabel!.isNotEmpty &&
            myDateLabel != null &&
            myDateLabel!.isNotEmpty;

      case HomeCardType.substituteRequest:
        return substituteDateLabel != null &&
            substituteDateLabel!.isNotEmpty;

      case HomeCardType.weeklySchedule:
      case HomeCardType.scheduleCompleted:
      case HomeCardType.scheduleChanged:
      case HomeCardType.ownerWorkRequest:
      case HomeCardType.none:
        return true;
    }
  }

  //-----------------------------------------
  // 이미지
  //-----------------------------------------

  String get imagePath {
    switch (type) {
      case HomeCardType.weeklySchedule:
        return "assets/images/e_weeklySchedule_card.png";

      case HomeCardType.scheduleCompleted:
        return "assets/images/e_scheduleCompleted_card.png";

      case HomeCardType.scheduleChanged:
        return "assets/images/e_scheduleChanged_card.png";

      case HomeCardType.shiftRequest:
        return "assets/images/e_shiftRequest_card.png";

      case HomeCardType.substituteRequest:
        return "assets/images/e_substituteRequest_card.png";

      case HomeCardType.ownerWorkRequest:
        return "assets/images/e_ownerWorkRequest_card.png";

      case HomeCardType.none:
        return "";
    }
  }

  //-----------------------------------------
  // 다음주 기간
  //-----------------------------------------

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

    final nextSunday = nextMonday.add(
      const Duration(days: 6),
    );

    return "${nextMonday.month}월 ${nextMonday.day}일 - "
        "${nextSunday.month}월 ${nextSunday.day}일";
  }

  //-----------------------------------------
  // 교대 요청 - 실제 데이터 기반
  //-----------------------------------------

  /// 실제 교대 신청 날짜.
  /// _hasRequiredData 체크를 통과한 경우에만 build()에서 사용되므로
  /// 이 시점에는 applicantDateLabel / myDateLabel이 항상 유효한 값을 가진다.
  String get shiftDateText {
    final applicant = applicantDateLabel ?? "-";
    final mine = myDateLabel ?? "-";
    return "$applicant ↔ $mine";
  }

  //-----------------------------------------
  // 대타 요청 - 실제 데이터 기반
  //-----------------------------------------

  /// 실제 요청받은 근무 날짜/시간.
  /// _hasRequiredData 체크를 통과한 경우에만 build()에서 사용되므로
  /// 이 시점에는 substituteDateLabel이 항상 유효한 값을 가진다.
  String get substituteDateTime {
    final date = substituteDateLabel;
    final time = substituteTimeLabel;

    if (date == null || date.isEmpty) {
      return "-";
    }

    if (time == null || time.isEmpty) {
      return date;
    }

    return "$date $time";
  }

  //-----------------------------------------
  // Chip 글자
  //-----------------------------------------

  String get chipText {
    switch (type) {
      case HomeCardType.weeklySchedule:
        return "마감까지 ${daysLeft}일";

      case HomeCardType.scheduleCompleted:
      case HomeCardType.scheduleChanged:
      case HomeCardType.ownerWorkRequest:
        return nextWeekRange;

      case HomeCardType.shiftRequest:
        return shiftDateText;

      case HomeCardType.substituteRequest:
        return substituteDateTime;

      case HomeCardType.none:
        return "";
    }
  }

  //-----------------------------------------
  // Chip 배경
  //-----------------------------------------

  Color get chipBackground {
    switch (type) {
      case HomeCardType.weeklySchedule:
      case HomeCardType.ownerWorkRequest:
        return const Color(0xFFBFE1FF);

      case HomeCardType.scheduleCompleted:
      case HomeCardType.scheduleChanged:
        return const Color(0xFFD3F0D5);

      case HomeCardType.shiftRequest:
      case HomeCardType.substituteRequest:
        return const Color(0xFFDDD7FE);

      case HomeCardType.none:
        return Colors.transparent;
    }
  }

  //-----------------------------------------
  // Chip 글자색
  //-----------------------------------------

  Color get chipTextColor {
    switch (type) {
      case HomeCardType.weeklySchedule:
      case HomeCardType.ownerWorkRequest:
        return const Color(0xFF0084FF);

      case HomeCardType.scheduleCompleted:
      case HomeCardType.scheduleChanged:
        return const Color(0xFF00B475);

      case HomeCardType.shiftRequest:
      case HomeCardType.substituteRequest:
        return const Color(0xFF7D67FD);

      case HomeCardType.none:
        return Colors.transparent;
    }
  }

  //-----------------------------------------
  // 자세히보기 색
  //-----------------------------------------

  Color get detailColor {
    switch (type) {
      case HomeCardType.weeklySchedule:
      case HomeCardType.ownerWorkRequest:
        return const Color(0xFF004A8F);

      case HomeCardType.scheduleCompleted:
      case HomeCardType.scheduleChanged:
        return const Color(0xFF007360);

      case HomeCardType.shiftRequest:
      case HomeCardType.substituteRequest:
        return const Color(0xFF6450D4);

      case HomeCardType.none:
        return Colors.transparent;
    }
  }

  @override
  Widget build(BuildContext context) {
    debugPrint(
      "[EScheduleCard] build - type: $type, workPlaceId: $workPlaceId, "
          "workChangeRequestId: $workChangeRequestId",
    );

    if (type == HomeCardType.none) {
      return const SizedBox.shrink();
    }

    if (!_hasRequiredData) {
      debugPrint(
        "[EScheduleCard] 필요한 데이터(날짜/시간)가 없어 카드를 표시하지 않습니다. "
            "type: $type, applicantDateLabel: $applicantDateLabel, "
            "myDateLabel: $myDateLabel, substituteDateLabel: $substituteDateLabel",
      );
      return const SizedBox.shrink();
    }

    return SizedBox(
      width: double.infinity,
      child: AspectRatio(
        aspectRatio: 1059 / 414,
        child: Stack(
          children: [
            Positioned.fill(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Image.asset(
                  imagePath,
                  fit: BoxFit.cover,
                ),
              ),
            ),

            /// 닫기 버튼
            Positioned(
              top: 16,
              right: 16,
              child: GestureDetector(
                onTap: onClose,
                child: Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(.25),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.close,
                    size: 18,
                    color: Colors.grey,
                  ),
                ),
              ),
            ),

            /// 하단 UI
            Positioned(
              left: 20,
              bottom: 18,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: chipBackground,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      chipText,
                      style: TextStyle(
                        color: chipTextColor,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),

                  const SizedBox(height: 18),

                  Padding(
                    padding: const EdgeInsets.only(left: 5),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        TextButton(
                          onPressed: () {
                            switch (type) {
                              case HomeCardType.shiftRequest:
                                debugPrint(
                                  "[EScheduleCard] 자세히 보기 tap (shiftRequest) - "
                                      "workPlaceId: $workPlaceId, "
                                      "workChangeRequestId: $workChangeRequestId",
                                );

                                if (workPlaceId == null || workChangeRequestId == null) {
                                  debugPrint(
                                    "[EScheduleCard] id가 없어 이동을 취소합니다. "
                                        "-> 이 카드를 생성하는 부모 위젯(EHomePage 등)에서 "
                                        "workPlaceId/workChangeRequestId(교대용)를 넘기고 있는지 확인하세요.",
                                  );
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text("요청 정보를 불러올 수 없어요."),
                                    ),
                                  );
                                  return;
                                }

                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => ExchangeRequest(
                                      workPlaceId: workPlaceId!,
                                      workChangeRequestId: workChangeRequestId!,
                                    ),
                                  ),
                                );
                                break;

                              case HomeCardType.scheduleCompleted:
                              case HomeCardType.scheduleChanged:
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => const EMainSchedulePage(),
                                  ),
                                );
                                break;

                              case HomeCardType.substituteRequest:
                                debugPrint(
                                  "[EScheduleCard] 자세히 보기 tap - "
                                      "workPlaceId: $workPlaceId, "
                                      "workChangeRequestId: $workChangeRequestId",
                                );

                                if (workPlaceId == null ||
                                    workChangeRequestId == null) {
                                  debugPrint(
                                    "[EScheduleCard] id가 없어 이동을 취소합니다. "
                                        "-> 이 카드를 생성하는 부모 위젯(EHomePage 등)에서 "
                                        "workPlaceId/workChangeRequestId를 넘기고 있는지 확인하세요.",
                                  );
                                  // 필요한 id가 없으면 이동하지 않고 안내만 표시
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text("요청 정보를 불러올 수 없어요."),
                                    ),
                                  );
                                  return;
                                }

                                debugPrint(
                                  "[EScheduleCard] SubstituteRequest로 이동 - "
                                      "workPlaceId: $workPlaceId, "
                                      "workChangeRequestId: $workChangeRequestId",
                                );

                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => SubstituteRequest(
                                      workPlaceId: workPlaceId!,
                                      workChangeRequestId: workChangeRequestId!,
                                    ),
                                  ),
                                );
                                break;

                              default:
                                onDetailTap?.call();
                            }
                          },
                          style: TextButton.styleFrom(
                            padding: EdgeInsets.zero,
                            minimumSize: Size.zero,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            alignment: Alignment.centerLeft,
                            foregroundColor: detailColor,
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                "자세히 보기",
                                style: TextStyle(
                                  color: detailColor,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(width: 2),
                              Icon(
                                Icons.chevron_right,
                                size: 18,
                                color: detailColor,
                              ),
                            ],
                          ),
                        ),

                        /// 보낸 요청(SENT) 목록으로 이동하는 버튼
                        if (type == HomeCardType.substituteRequest ||
                            type == HomeCardType.shiftRequest) ...[
                          const SizedBox(width: 8),
                          TextButton(
                            onPressed: () {
                              if (workPlaceId == null) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text("근무지 정보를 불러오는 중입니다."),
                                  ),
                                );
                                return;
                              }
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => SentWorkChangeRequestsPage(
                                    workPlaceId: workPlaceId!,
                                  ),
                                ),
                              );
                            },
                            style: TextButton.styleFrom(
                              padding: EdgeInsets.zero,
                              minimumSize: Size.zero,
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              alignment: Alignment.centerLeft,
                              foregroundColor: detailColor,
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  "내가 보낸 요청 보기",
                                  style: TextStyle(
                                    color: detailColor,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(width: 2),
                                Icon(
                                  Icons.chevron_right,
                                  size: 18,
                                  color: detailColor,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}