import 'package:flutter/material.dart';

import 'RWorkChangeRequestListPage.dart'
    show WorkChangeRequestItem;

/// 대상 근무자가 요청을 수락하여 사장님의 최종 승인을 기다리는
/// 교대/대타 요청 상세(승인) 페이지.
///
/// RWorkChangeRequestListPage에서 status == "ACCEPTED_BY_TARGET" 인
/// 카드를 탭했을 때 이 페이지로 이동한다.
class RWorkChangeRequestDetailPage extends StatelessWidget {
  final WorkChangeRequestItem item;
  final String requesterName;
  final String? targetName;

  const RWorkChangeRequestDetailPage({
    super.key,
    required this.item,
    required this.requesterName,
    required this.targetName,
  });

  String _typeTitle() {
    final upper = item.requestType.toUpperCase();
    if (upper.contains("SUBSTITUTE")) return "대타 근무";
    if (upper.contains("SHIFT") || upper.contains("EXCHANGE")) return "교대 근무";
    return item.requestType;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          "받은 승인 내역",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
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
                      color: const Color(0xFF00B475).withOpacity(.12),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text(
                      "답변 대기",
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF00B475),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // TODO: 실제 근무 일자/시간은 requestAssignmentId, targetAssignmentId로
              // 근무 스케줄 상세 API를 조회해서 채워야 함(현재 모델엔 없음).
              // 우선 화면 레이아웃만 이미지와 동일하게 구성해 둠.
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 20,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFF5F5F7),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: _ShiftSideInfo(
                        name: requesterName,
                        date: "-", // TODO: 신청자 근무 일자 연동
                        time: "-", // TODO: 신청자 근무 시간 연동
                      ),
                    ),
                    const Icon(
                      Icons.swap_horiz,
                      color: Color(0xFF8E8E93),
                    ),
                    Expanded(
                      child: _ShiftSideInfo(
                        name: targetName ?? "",
                        date: "-", // TODO: 대상자 근무 일자 연동
                        time: "-", // TODO: 대상자 근무 시간 연동
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              _InfoRow(label: "교대 신청자", value: requesterName),

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
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        side: const BorderSide(color: Color(0xFFDADADA)),
                      ),
                      onPressed: () {
                        // TODO: 사장님 거절 API 연동 (owner reject)
                        Navigator.of(context).pop("REJECTED");
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
                    flex: 2,
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
                        // TODO: 사장님 승인 API 연동 (owner approve)
                        Navigator.of(context).pop("APPROVED");
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
            ],
          ),
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