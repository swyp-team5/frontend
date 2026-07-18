import 'package:flutter/material.dart';

import '../../../common/employee/EExchangeReject.dart';
import '../../../employer/crews/model/RCrewModel.dart';
import '../../crews/model/WorkChangeRequestResponse.dart';
import '../api/WorkChangeRequestListApi.dart';
import 'ExAcceptionBottomSheet.dart';
import 'package:dio/dio.dart';
import '../../../../common/auth/server_token_manager.dart';

// TODO: 모델 파일 경로가 다르면 확인 후 수정하세요.
import '../../crews/api/WorkChangeTargetsApi.dart';
import '../../crews/model/WorkChangeTargetsResponse.dart';

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

class ExchangeRequest extends StatefulWidget {
  final int workPlaceId;
  final int workChangeRequestId;

  const ExchangeRequest({
    super.key,
    required this.workPlaceId,
    required this.workChangeRequestId,
  });

  @override
  State<ExchangeRequest> createState() => _ExchangeRequestState();
}

class _ExchangeRequestState extends State<ExchangeRequest> {
  final WorkChangeRequestListApi _api = WorkChangeRequestListApi();
  final Dio _dio = Dio(BaseOptions(baseUrl: "https://chackchack.shop"));

  bool _isLoading = true;
  String? _error;

  // 거절 API 호출 중인지 여부 (버튼 중복 클릭 방지 및 로딩 표시용)
  bool _isRejecting = false;

  String? _applicantName;
  String? _reason;

  // 신청자(왼쪽) / 나(오른쪽) 근무 날짜·시간
  String? _applicantDate;
  String? _applicantTime;
  String? _myDate;
  String? _myTime;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      // 요청 상세와 크루(이름 매핑용) 목록을 함께 불러온다.
      // Future.wait([...])로 서로 다른 타입의 Future를 한 리스트에 담으면
      // 리스트의 타입이 공통 상위 타입인 Object로 통일되어버려서
      // detail.requesterMemberId, detail.reason 같은 getter를 찾지 못하는
      // 컴파일 오류가 발생한다.
      // 대신 각 Future를 먼저 "시작"만 해두고(동시 실행은 그대로 유지됨)
      // 개별 변수에 담아 각각 await하면 원래 타입이 그대로 보존된다.
      final requestFuture = _api.fetchRequestById(
        workPlaceId: widget.workPlaceId,
        workChangeRequestId: widget.workChangeRequestId,
        scope: "RECEIVED",
      );
      final crewNamesFuture = _fetchCrewNames();

      final detail = await requestFuture;
      final crewNames = await crewNamesFuture;

      if (!mounted) return;

      if (detail == null) {
        setState(() {
          _error = "요청 정보를 찾을 수 없어요.";
          _isLoading = false;
        });
        return;
      }

      // requestAssignmentId / targetAssignmentId에 해당하는 날짜·시간을 찾는다.
      final assignmentTimes = await _fetchAssignmentTimes(detail);

      if (!mounted) return;

      final applicantInfo =
      detail.requestAssignmentId != null ? assignmentTimes[detail.requestAssignmentId] : null;

      // SUBSTITUTE(대타) 요청은 서로 다른 두 근무를 맞바꾸는 게 아니라
      // 신청자의 근무 하나가 그대로 나에게 넘어오는 방식이라 targetAssignmentId가 없다.
      // 이 경우 오른쪽("나")에도 같은 근무 정보를 보여줘야
      // "이 근무가 내게 배정됩니다"라는 의미가 자연스럽게 전달된다.
      final myInfo = detail.targetAssignmentId != null
          ? assignmentTimes[detail.targetAssignmentId]
          : (detail.requestType == "SUBSTITUTE" ? applicantInfo : null);

      setState(() {
        // 신청자 이름 자리에는 오직 이름만
        _applicantName = crewNames[detail.requesterMemberId] ??
            "회원 ${detail.requesterMemberId}";
        // 사유 자리에는 오직 사유만
        _reason = detail.reason.isNotEmpty ? detail.reason : "사유 없음";

        _applicantDate = applicantInfo?.dateLabel ?? "-";
        _applicantTime = applicantInfo?.timeLabel ?? "-";
        _myDate = myInfo?.dateLabel ?? "-";
        _myTime = myInfo?.timeLabel ?? "-";

        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = "요청 정보를 불러오지 못했어요.";
        _isLoading = false;
      });
    }
  }

  /// memberId -> name 매핑
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
      final crews = list.map((e) => RCrewModel.fromJson(e)).toList();

      for (final crew in crews) {
        names[crew.memberId] = crew.name;
      }
    } catch (_) {
      // 이름 매핑 실패해도 화면 자체는 보여줘야 하므로 조용히 무시.
    }
    return names;
  }

  /// requestAssignmentId / targetAssignmentId에 해당하는 날짜·시간을 찾기 위해
  /// 확정 스케줄(work-change-targets)을 조회하고 assignmentId -> 시간 정보로 매핑한다.
  ///
  /// 정확한 날짜를 미리 알 수 없으므로, 요청 생성일(createdAt) 기준
  /// 앞뒤로 넉넉한 기간을 조회한다. 필요하면 범위를 프로젝트 상황에 맞게 조정하세요.
  Future<Map<int, _AssignmentTimeInfo>> _fetchAssignmentTimes(
      WorkChangeRequestResponse detail,
      ) async {
    final Map<int, _AssignmentTimeInfo> map = {};

    // 둘 다 없으면 조회할 필요가 없다.
    if (detail.requestAssignmentId == null && detail.targetAssignmentId == null) {
      return map;
    }

    try {
      // 서버 정책: fromDate는 오늘 이전일 수 없다
      // ("교대/대타 대상 근무는 오늘 이후의 확정 근무만 조회할 수 있습니다.")
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final createdAt = DateTime.tryParse(detail.createdAt) ?? now;
      final createdDate = DateTime(createdAt.year, createdAt.month, createdAt.day);

      // 오늘과 요청 생성일 중 더 이른 날짜를 fromDate로 쓰되, 오늘 이전으로는 내려가지 않는다.
      final fromDate = createdDate.isBefore(today) ? today : createdDate;
      final toDate = fromDate.add(const Duration(days: 60));

      debugPrint(
        "[ExchangeRequest] fetchAssignmentTimes 요청: "
            "workPlaceId=${widget.workPlaceId}, "
            "fromDate=${_formatDate(fromDate)}, toDate=${_formatDate(toDate)}, "
            "requestAssignmentId=${detail.requestAssignmentId}, "
            "targetAssignmentId=${detail.targetAssignmentId}",
      );

      final targets = await WorkChangeTargetsApi.fetchWorkers(
        workPlaceId: widget.workPlaceId,
        fromDate: _formatDate(fromDate),
        toDate: _formatDate(toDate),
      );

      debugPrint(
        "[ExchangeRequest] fetchAssignmentTimes 응답: days=${targets.days.length}개",
      );

      for (final day in targets.days) {
        for (final timeDetail in day.timeDetails) {
          for (final worker in timeDetail.workers) {
            debugPrint(
              "[ExchangeRequest]  - assignmentId=${worker.assignmentId}, "
                  "date=${day.workDate}, time=${timeDetail.timeName}",
            );
            map[worker.assignmentId] = _AssignmentTimeInfo(
              date: day.workDate,
              dayName: day.dayName,
              timeName: timeDetail.timeName,
              startTime: timeDetail.startTime,
              closeTime: timeDetail.closeTime,
            );
          }
        }
      }
    } on DioException catch (e) {
      debugPrint(
        "[ExchangeRequest] fetchAssignmentTimes DioException: "
            "status=${e.response?.statusCode}, data=${e.response?.data}, "
            "requestUri=${e.requestOptions.uri}",
      );
      // 시간 정보 조회 실패해도 화면 자체는 보여줘야 하므로 화면은 그대로 진행.
    } catch (e, st) {
      debugPrint("[ExchangeRequest] fetchAssignmentTimes 실패: $e");
      debugPrint("$st");
      // 시간 정보 조회 실패해도 화면 자체는 보여줘야 하므로 화면은 그대로 진행.
    }

    return map;
  }

  String _formatDate(DateTime date) {
    final y = date.year.toString().padLeft(4, '0');
    final m = date.month.toString().padLeft(2, '0');
    final d = date.day.toString().padLeft(2, '0');
    return "$y-$m-$d";
  }

  /// POST /api/work-places/{workPlaceId}/work-change-requests/{requestId}/reject
  /// 성공하면 null, 실패하면 사용자에게 보여줄 에러 메시지를 반환한다.
  Future<String?> _rejectRequest() async {
    debugPrint(
      "[ExchangeRequest] reject 요청 시작: "
          "workPlaceId=${widget.workPlaceId}, "
          "workChangeRequestId=${widget.workChangeRequestId}",
    );

    try {
      final token = await ServerTokenManager.getValidAccessToken();
      if (token == null) {
        debugPrint("[ExchangeRequest] reject 실패: 토큰 없음");
        return "인증이 만료되었습니다. 다시 로그인해 주세요.";
      }
      debugPrint("[ExchangeRequest] 토큰 확인 완료, API 호출 시도");

      final url =
          "/api/work-places/${widget.workPlaceId}/work-change-requests/${widget.workChangeRequestId}/reject";
      debugPrint("[ExchangeRequest] POST 요청: $url");

      final response = await _dio.post(
        url,
        options: Options(
          headers: {"Authorization": "Bearer $token"},
        ),
      );

      debugPrint(
        "[ExchangeRequest] reject 응답: "
            "status=${response.statusCode}, data=${response.data}",
      );

      final success = response.statusCode == 200 || response.statusCode == 204;
      debugPrint("[ExchangeRequest] reject 결과: success=$success");

      return success ? null : _errorMessage(response.statusCode, null);
    } on DioException catch (e) {
      debugPrint(
        "[ExchangeRequest] reject DioException: "
            "status=${e.response?.statusCode}, data=${e.response?.data}, "
            "requestUri=${e.requestOptions.uri}",
      );

      final data = e.response?.data;
      final serverMessage = (data is Map) ? data["message"]?.toString() : null;
      return _errorMessage(e.response?.statusCode, serverMessage);
    } catch (e, st) {
      debugPrint("[ExchangeRequest] reject 실패: $e");
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
    if (_isRejecting) {
      debugPrint("[ExchangeRequest] 이미 처리 중이라 무시함");
      return;
    }

    debugPrint("[ExchangeRequest] 거절 버튼 클릭됨");

    setState(() {
      _isRejecting = true;
    });

    final errorMessage = await _rejectRequest();

    if (!mounted) {
      debugPrint("[ExchangeRequest] 위젯이 dispose됨, 처리 중단");
      return;
    }

    setState(() {
      _isRejecting = false;
    });

    if (errorMessage == null) {
      debugPrint("[ExchangeRequest] 거절 성공 → EExchangeReject로 이동");
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => EExchangeReject(
            workPlaceId: widget.workPlaceId,
            workChangeRequestId: widget.workChangeRequestId,
          ),
        ),
      );
    } else {
      debugPrint("[ExchangeRequest] 거절 실패 → 스낵바 표시: $errorMessage");
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
                        onTap: () => Navigator.pop(context),
                        child: const Icon(
                          Icons.arrow_back_ios_new,
                          size: 22,
                        ),
                      ),
                    ),
                    const Center(
                      child: Text(
                        "교대 신청 내역",
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
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _error != null
                  ? Center(child: Text(_error!))
                  : Padding(
                padding: const EdgeInsets.symmetric(horizontal: 30),
                child: Column(
                  children: [
                    const Spacer(),

                    /// 교대 카드
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 30,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xffF5F5F9),
                        borderRadius: BorderRadius.circular(22),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: _WorkInfo(
                              name: _applicantName ?? "",
                              badgeColor: Colors.white,
                              textColor: const Color(0xff00315F),
                              date: _applicantDate ?? "-",
                              time: _applicantTime ?? "-",
                            ),
                          ),

                          const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 10),
                            child: Icon(
                              Icons.swap_horiz,
                              color: Color(0xff8F8F8F),
                              size: 30,
                            ),
                          ),

                          Expanded(
                            child: _WorkInfo(
                              name: "나",
                              badgeColor: const Color(0xffE6F3FF),
                              textColor: const Color(0xff0063BF),
                              date: _myDate ?? "-",
                              time: _myTime ?? "-",
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 30),

                    _InfoRow(title: "교대 신청자", value: _applicantName ?? ""),

                    const SizedBox(height: 30),

                    _InfoRow(title: "교대 신청 사유", value: _reason ?? ""),

                    const Spacer(),

                    Row(
                      children: [
                        Expanded(
                          child: SizedBox(
                            height: 55,
                            child: OutlinedButton(
                              style: OutlinedButton.styleFrom(
                                side: BorderSide.none,
                              ),
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
                                  builder: (_) => ExAcceptionBottomSheet(
                                    workPlaceId: widget.workPlaceId,
                                    workChangeRequestId:
                                    widget.workChangeRequestId,
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
              ),
            ),
          ],
        ),
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
          padding: const EdgeInsets.symmetric(
            horizontal: 6,
            vertical: 4,
          ),
          decoration: BoxDecoration(
            color: badgeColor,
            borderRadius: BorderRadius.circular(4),
          ),
          child: Text(
            name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
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
  const _InfoRow({
    required this.title,
    required this.value,
  });

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
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}