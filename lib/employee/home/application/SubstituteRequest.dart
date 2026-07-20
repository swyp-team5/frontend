import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

import '../../../../common/auth/server_token_manager.dart';
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
  final Map<int, String> crewNames; // memberId -> name

  _DetailViewData({
    required this.request,
    required this.requestSide,
    required this.targetSide,
    required this.crewNames,
  });
}

class _SubstituteRequestState extends State<SubstituteRequest> {
  final _listApi = WorkChangeRequestListApi();
  final Dio _dio = Dio(BaseOptions(baseUrl: "https://chackchack.shop"));
  late Future<_DetailViewData> _future;

  // 거절 API 호출 중인지 여부 (버튼 중복 클릭 방지 및 로딩 표시용)
  bool _isRejecting = false;

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

    final crewNames = await _fetchCrewNames();

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
      crewNames: crewNames,
    );
  }

  /// memberId -> name 매핑. assignmentId 기반 조회(AssignmentResolver)는
  /// 요청이 승인되어 배정이 교체되면 실패하므로, 이름은 크루 목록에서
  /// memberId로 직접 찾는다(승인 여부와 무관하게 항상 안정적).
  Future<Map<int, String>> _fetchCrewNames() async {
    final Map<int, String> names = {};
    try {
      final token = await ServerTokenManager.getValidAccessToken();
      if (token == null) return names;

      final response = await _dio.get(
        "/api/work-places/${widget.workPlaceId}/crews",
        options: Options(
          headers: {"Authorization": "Bearer $token"},
        ),
      );

      final List list = response.data["crews"] ?? [];

      for (final e in list) {
        final crew = Map<String, dynamic>.from(e ?? {});
        final memberId = crew["memberId"] is int
            ? crew["memberId"] as int
            : int.tryParse(crew["memberId"]?.toString() ?? "");
        if (memberId == null) continue;
        names[memberId] = crew["name"]?.toString() ?? "이름 없음";
      }
    } catch (e) {
      debugPrint("[SubstituteRequest] crews 조회 실패: $e");
    }
    return names;
  }

  /// POST /api/work-places/{workPlaceId}/work-change-requests/{requestId}/reject
  /// reject는 별도 요청 바디(reason 등)가 필요 없음.
  /// 성공하면 null, 실패하면 사용자에게 보여줄 에러 메시지를 반환한다.
  Future<String?> _rejectRequest() async {
    final url =
        "/api/work-places/${widget.workPlaceId}/work-change-requests/${widget.workChangeRequestId}/reject";
    debugPrint("[SubstituteRequest] reject 요청 시작: $url");

    try {
      final token = await ServerTokenManager.getValidAccessToken();
      if (token == null) {
        debugPrint("[SubstituteRequest] reject 실패: 토큰 없음");
        return "인증이 만료되었습니다. 다시 로그인해 주세요.";
      }

      final response = await _dio.post(
        url,
        data: {},
        options: Options(
          headers: {"Authorization": "Bearer $token"},
        ),
      );

      debugPrint(
        "[SubstituteRequest] reject 응답: "
            "status=${response.statusCode}, data=${response.data}",
      );

      final success =
          response.statusCode == 200 || response.statusCode == 204;
      debugPrint("[SubstituteRequest] reject 결과: success=$success");

      return success ? null : _errorMessage(response.statusCode, null);
    } on DioException catch (e) {
      debugPrint(
        "[SubstituteRequest] reject DioException: "
            "status=${e.response?.statusCode}, data=${e.response?.data}, "
            "requestUri=${e.requestOptions.uri}",
      );

      final data = e.response?.data;
      final serverMessage = (data is Map) ? data["message"]?.toString() : null;
      return _errorMessage(e.response?.statusCode, serverMessage);
    } catch (e, st) {
      debugPrint("[SubstituteRequest] reject 실패(예상치 못한 예외): $e");
      debugPrint("$st");
      return "거절 처리에 실패했어요. 잠시 후 다시 시도해주세요.";
    }
  }

  // 서버가 내려주는 raw 메시지/코드 대신, 사용자가 이해하기 쉬운 문구로 바꿔서 보여준다.
  // (WorkChangeRequestService.rejectByTarget 기준)
  static String _errorMessage(int? statusCode, String? serverMessage) {
    switch (statusCode) {
      case 401:
        return "인증이 만료되었습니다. 다시 로그인해 주세요.";
      case 403:
        return "이 요청을 처리할 권한이 없습니다.";
      case 404:
        return "요청 정보를 찾을 수 없습니다. 새로고침 후 다시 시도해주세요.";
      case 409:
        return "이미 처리된 요청이라 거절할 수 없습니다. 새로고침 후 다시 확인해주세요.";
      default:
        return "거절 처리에 실패했어요. 잠시 후 다시 시도해주세요.";
    }
  }

  Future<void> _handleReject() async {
    if (_isRejecting) return;

    debugPrint("[SubstituteRequest] 거절 버튼 클릭됨");

    setState(() {
      _isRejecting = true;
    });

    final errorMessage = await _rejectRequest();

    if (!mounted) return;

    setState(() {
      _isRejecting = false;
    });

    if (errorMessage == null) {
      debugPrint("[SubstituteRequest] 거절 성공 → ESubstituteReject로 이동");
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => const ESubstituteReject(),
        ),
      );
    } else {
      debugPrint("[SubstituteRequest] 거절 실패 → 스낵바 표시: $errorMessage");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(errorMessage)),
      );
    }
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

    // 신청자(applicant) = 요청 보낸 사람의 이름 (크루 목록 기반, 승인 여부와 무관하게 안정적)
    final applicantName = data.crewNames[request.requesterMemberId] ??
        "멤버 #${request.requesterMemberId}";
    final targetName = widget.myName; // 오른쪽엔 항상 '나'로 고정

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
                    onPressed: _isRejecting ? null : _handleReject,
                    child: _isRejecting
                        ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.black54,
                      ),
                    )
                        : const Text(
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