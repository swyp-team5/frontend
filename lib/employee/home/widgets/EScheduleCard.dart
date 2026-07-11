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

  /// substituteRequest 타입 카드에서 상세 화면으로 이동할 때 필요
  final int? workPlaceId;
  final int? workChangeRequestId;

  const EScheduleCard({
    super.key,
    required this.type,
    required this.daysLeft,
    this.onClose,
    this.onDetailTap,
    this.workPlaceId,
    this.workChangeRequestId,
  });

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
  // 더미 데이터
  //-----------------------------------------

  DateTime get myScheduleDate => DateTime(2026, 6, 25);

  DateTime get otherScheduleDate => DateTime(2026, 6, 27);

  String get shiftDateText =>
      "${myScheduleDate.month}월 ${myScheduleDate.day}일 ↔ "
          "${otherScheduleDate.month}월 ${otherScheduleDate.day}일";

  DateTime get substituteDate => DateTime(2026, 6, 27);

  String get substituteTime => "16:00 - 20:00";

  String get substituteDateTime =>
      "${substituteDate.month}월 ${substituteDate.day}일 $substituteTime";

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