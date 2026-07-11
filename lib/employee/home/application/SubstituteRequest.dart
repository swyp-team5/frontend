import 'package:flutter/material.dart';

import '../../../common/employee/EExchangeReject.dart';
import '../../../common/employee/ESubstituteReject.dart';
import '../../crews/model/WorkChangeRequestResponse.dart';
import '../api/WorkChangeRequestListApi.dart';
import '../model/AssignmentResolver.dart';
import 'ExAcceptionBottomSheet.dart';
import 'SubAcceptionBottomSheet.dart';

class SubstituteRequest extends StatefulWidget {
  const SubstituteRequest({
    super.key,
    required this.workPlaceId,
    required this.workChangeRequestId,
    this.myName = "나",
  });

  final int workPlaceId;
  final int workChangeRequestId;
  final String myName;

  @override
  State<SubstituteRequest> createState() => _SubstituteRequestState();
}

class _DetailViewData {
  final WorkChangeRequestResponse request;
  final ResolvedAssignment? requestSide; // requestAssignmentId 근무 정보
  final ResolvedAssignment? targetSide; // targetAssignmentId 근무 정보 (SWAP일 때만)

  _DetailViewData({
    required this.request,
    required this.requestSide,
    required this.targetSide,
  });
}

class _SubstituteRequestState extends State<SubstituteRequest> {
  final _listApi = WorkChangeRequestListApi();
  late Future<_DetailViewData> _future;

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  Future<_DetailViewData> _load() async {
    final request = await _listApi.fetchRequestById(
      workPlaceId: widget.workPlaceId,
      workChangeRequestId: widget.workChangeRequestId,
      scope: "RECEIVED",
    );

    if (request == null) {
      throw Exception("요청 정보를 찾을 수 없어요.");
    }

    final createdAt = DateTime.parse(request.createdAt);
    final (fromDate, toDate) = AssignmentResolver.defaultRangeAround(createdAt);

    final assignmentMap = await AssignmentResolver.buildAssignmentMap(
      workPlaceId: widget.workPlaceId,
      fromDate: fromDate,
      toDate: toDate,
    );

    final requestSide = request.requestAssignmentId != null
        ? assignmentMap[request.requestAssignmentId]
        : null;

    // SUBSTITUTE: targetAssignmentId가 없으니 같은 근무(requestSide)를 그대로 사용
    // SHIFT_SWAP: targetAssignmentId가 따로 있으니 그걸로 조회
    final targetSide = request.targetAssignmentId != null
        ? assignmentMap[request.targetAssignmentId]
        : requestSide;

    return _DetailViewData(
      request: request,
      requestSide: requestSide,
      targetSide: targetSide,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
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
                        onTap: () => Navigator.pop(context),
                        child: const Icon(Icons.arrow_back_ios_new, size: 22),
                      ),
                    ),
                    const Center(
                      child: Text(
                        "대타 신청 내역",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              child: FutureBuilder<_DetailViewData>(
                future: _future,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    return Center(child: Text("불러오지 못했어요: ${snapshot.error}"));
                  }
                  return _buildContent(context, snapshot.data!);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context, _DetailViewData data) {
    final request = data.request;

    // 신청자(applicant) = 요청 보낸 사람의 근무 정보 쪽에서 이름 추출
    // (근무자 이름을 못 찾으면 memberId로 표시)
    final applicantName =
        data.requestSide?.workerName ?? "멤버 #${request.requesterMemberId}";
    final targetName = request.targetMemberId != null
        ? (data.targetSide?.workerName ?? "멤버 #${request.targetMemberId}")
        : widget.myName;

    final applicantDate = data.requestSide?.dateLabel ?? "-";
    final applicantTime = data.requestSide?.timeLabel ?? "-";
    final targetDate = data.targetSide?.dateLabel ?? applicantDate;
    final targetTime = data.targetSide?.timeLabel ?? applicantTime;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 30),
      child: Column(
        children: [
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 30),
            decoration: BoxDecoration(
              color: const Color(0xffF5F5F9),
              borderRadius: BorderRadius.circular(22),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: _WorkInfo(
                    name: applicantName,
                    badgeColor: Colors.white,
                    textColor: const Color(0xff00315F),
                    date: applicantDate,
                    time: applicantTime,
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 14),
                  child: Icon(
                    Icons.arrow_forward,
                    color: Color(0xff8F8F8F),
                    size: 34,
                  ),
                ),
                Expanded(
                  child: _WorkInfo(
                    name: targetName,
                    badgeColor: const Color(0xffE6F3FF),
                    textColor: const Color(0xff0063BF),
                    date: targetDate,
                    time: targetTime,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 30),
          _InfoRow(title: "대타 신청자", value: applicantName),
          const SizedBox(height: 30),
          _InfoRow(title: "대타 신청 사유", value: request.reason),
          const Spacer(),
          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 55,
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(side: BorderSide.none),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const ESubstituteReject(),
                        ),
                      );
                    },
                    child: const Text(
                      "거절",
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                flex: 1,
                child: SizedBox(
                  height: 55,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      elevation: 0,
                      backgroundColor: const Color(0xff0084FF),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onPressed: () {
                      showModalBottomSheet(
                        context: context,
                        backgroundColor: Colors.transparent,
                        isScrollControlled: true,
                        builder: (_) => SubAcceptionBottomSheet(
                          workPlaceId: widget.workPlaceId,
                          workChangeRequestId: widget.workChangeRequestId,
                          onAccept: () {
                            Navigator.pop(context);
                          },
                        ),
                      );
                    },
                    child: const Text(
                      "수락",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}

class _WorkInfo extends StatelessWidget {
  const _WorkInfo({
    required this.name,
    required this.badgeColor,
    required this.textColor,
    required this.date,
    required this.time,
  });

  final String name;
  final Color badgeColor;
  final Color textColor;
  final String date;
  final String time;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
          decoration: BoxDecoration(
            color: badgeColor,
            borderRadius: BorderRadius.circular(4),
          ),
          child: Text(
            name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: textColor,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        const SizedBox(height: 12),
        Text(
          date,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 16,
            color: Colors.black,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          time,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 14,
            color: Color(0xFF505050),
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.title, required this.value});

  final String title;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            color: Color(0xff505050),
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            value,
            textAlign: TextAlign.end,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          ),
        ),
      ],
    );
  }
}