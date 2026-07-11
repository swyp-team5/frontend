import 'package:flutter/material.dart';
import 'package:dio/dio.dart';

import '../../../common/auth/server_token_manager.dart';
import 'RWorkChangeRequestDetailPage.dart';

/// 근무자가 사장님에게 보낸 근무 변경(교대/대타) 요청 1건
///
/// GET /api/work-places/{workPlaceId}/owner/work-change-requests?page=0&size=20
/// 응답의 content[] 항목 스펙에 맞춘 모델
class WorkChangeRequestItem {
  final int workChangeRequestId;
  final int workPlaceId;

  /// "SUBSTITUTE"(대타) | "SHIFT"/"EXCHANGE"(교대) 등 서버 정의값
  final String requestType;

  /// "REQUESTED" | "APPROVED" | "REJECTED" | "CANCELED" 등 서버 정의값
  final String status;

  final int requesterMemberId;
  final int? targetMemberId;
  final int? requestAssignmentId;
  final int? targetAssignmentId;
  final String? reason;
  final DateTime? targetRespondedAt;
  final int? processedByMemberId;
  final DateTime? processedAt;
  final DateTime? canceledAt;
  final DateTime? createdAt;

  WorkChangeRequestItem({
    required this.workChangeRequestId,
    required this.workPlaceId,
    required this.requestType,
    required this.status,
    required this.requesterMemberId,
    this.targetMemberId,
    this.requestAssignmentId,
    this.targetAssignmentId,
    this.reason,
    this.targetRespondedAt,
    this.processedByMemberId,
    this.processedAt,
    this.canceledAt,
    this.createdAt,
  });

  factory WorkChangeRequestItem.fromJson(Map<String, dynamic> json) {
    DateTime? parseDate(dynamic value) {
      if (value == null) return null;
      return DateTime.tryParse(value.toString());
    }

    return WorkChangeRequestItem(
      workChangeRequestId: json["workChangeRequestId"],
      workPlaceId: json["workPlaceId"],
      requestType: json["requestType"]?.toString() ?? "",
      status: json["status"]?.toString() ?? "",
      requesterMemberId: json["requesterMemberId"],
      targetMemberId: json["targetMemberId"],
      requestAssignmentId: json["requestAssignmentId"],
      targetAssignmentId: json["targetAssignmentId"],
      reason: json["reason"]?.toString(),
      targetRespondedAt: parseDate(json["targetRespondedAt"]),
      processedByMemberId: json["processedByMemberId"],
      processedAt: parseDate(json["processedAt"]),
      canceledAt: parseDate(json["canceledAt"]),
      createdAt: parseDate(json["createdAt"]),
    );
  }
}

/// 페이지네이션 응답 래퍼
class WorkChangeRequestPageResult {
  final List<WorkChangeRequestItem> content;
  final int page;
  final int size;
  final int totalElements;
  final int totalPages;

  WorkChangeRequestPageResult({
    required this.content,
    required this.page,
    required this.size,
    required this.totalElements,
    required this.totalPages,
  });

  factory WorkChangeRequestPageResult.fromJson(Map<String, dynamic> json) {
    final List list = json["content"] ?? [];
    return WorkChangeRequestPageResult(
      content: list.map((e) => WorkChangeRequestItem.fromJson(e)).toList(),
      page: json["page"] ?? 0,
      size: json["size"] ?? 20,
      totalElements: json["totalElements"] ?? 0,
      totalPages: json["totalPages"] ?? 1,
    );
  }
}

/// 크루(근무자) 정보
///
/// GET /api/work-places/{workPlaceId}/owner/crews
/// 응답이 List<RCrewModel>을 바로 담은 배열이라고 가정 (아니면 아래 파싱부만 수정)
class RCrewModel {
  final int crewId;
  final int memberId;

  final String name;
  final String phoneNumber;
  final String? profileImageUrl;

  final String crewRole;
  final String joinStatus;
  final String crewStatus;

  final DateTime createdAt;

  RCrewModel({
    required this.crewId,
    required this.memberId,
    required this.name,
    required this.phoneNumber,
    required this.profileImageUrl,
    required this.crewRole,
    required this.joinStatus,
    required this.crewStatus,
    required this.createdAt,
  });

  factory RCrewModel.fromJson(Map<String, dynamic> json) {
    return RCrewModel(
      crewId: json["crewId"],
      memberId: json["memberId"],
      name: json["name"],
      phoneNumber: json["phoneNumber"],
      profileImageUrl: json["profileImageUrl"],
      crewRole: json["crewRole"],
      joinStatus: json["joinStatus"],
      crewStatus: json["crewStatus"],
      createdAt: DateTime.parse(json["createdAt"]),
    );
  }
}

class RWorkChangeRequestListPage extends StatefulWidget {
  final int workPlaceId;

  const RWorkChangeRequestListPage({
    super.key,
    required this.workPlaceId,
  });

  @override
  State<RWorkChangeRequestListPage> createState() =>
      _RWorkChangeRequestListPageState();
}

class _RWorkChangeRequestListPageState extends State<RWorkChangeRequestListPage> {
  static const int _pageSize = 20;

  final Dio _dio = Dio(
    BaseOptions(baseUrl: "https://chackchack.shop"),
  );

  final ScrollController _scrollController = ScrollController();

  final List<WorkChangeRequestItem> _items = [];

  // memberId -> 이름 매핑 (요청자/대상자 이름 표시용)
  final Map<int, String> _memberNames = {};

  int _page = 0;
  int _totalPages = 1;

  bool _isLoading = true; // 최초 로딩
  bool _isLoadingMore = false; // 다음 페이지 로딩
  String? _error;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _load(reset: true);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_isLoadingMore || _isLoading) return;
    if (_page + 1 >= _totalPages) return;

    final position = _scrollController.position;
    if (position.pixels >= position.maxScrollExtent - 200) {
      _loadMore();
    }
  }

  Future<void> _load({required bool reset}) async {
    setState(() {
      if (reset) {
        _isLoading = true;
        _error = null;
        _items.clear();
        _page = 0;
      }
    });

    try {
      // 요청 목록과 이름 매핑용 크루 목록을 함께 불러온다.
      final results = await Future.wait([
        _fetchPage(0),
        _loadMemberNames(),
      ]);
      final result = results[0] as WorkChangeRequestPageResult;

      if (!mounted) return;

      setState(() {
        _items.addAll(result.content);
        _page = result.page;
        _totalPages = result.totalPages;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = _errorMessage(e);
        _isLoading = false;
      });
    }
  }

  Future<void> _loadMore() async {
    setState(() {
      _isLoadingMore = true;
    });

    try {
      final nextPage = _page + 1;
      final result = await _fetchPage(nextPage);

      if (!mounted) return;

      setState(() {
        _items.addAll(result.content);
        _page = result.page;
        _totalPages = result.totalPages;
        _isLoadingMore = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoadingMore = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_errorMessage(e))),
      );
    }
  }

  Future<WorkChangeRequestPageResult> _fetchPage(int page) async {
    final token = await ServerTokenManager.getValidAccessToken();

    if (token == null) {
      throw Exception("토큰 없음");
    }

    final response = await _dio.get(
      "/api/work-places/${widget.workPlaceId}/owner/work-change-requests",
      queryParameters: {
        "page": page,
        "size": _pageSize,
      },
      options: Options(
        headers: {"Authorization": "Bearer $token"},
      ),
    );

    return WorkChangeRequestPageResult.fromJson(response.data);
  }

  /// 사업장 크루 목록을 불러와 memberId -> name 매핑을 만든다.
  ///
  /// TODO: 실제 엔드포인트 경로 및 응답 래핑 형태(content 유무)에 맞게 조정 필요.
  Future<void> _loadMemberNames() async {
    try {
      final token = await ServerTokenManager.getValidAccessToken();
      if (token == null) return;

      final response = await _dio.get(
        "/api/work-places/${widget.workPlaceId}/crews",
        options: Options(
          headers: {"Authorization": "Bearer $token"},
        ),
      );

      final List list = response.data["crews"] ?? [];

      final crews = list.map((e) => RCrewModel.fromJson(e)).toList();

      for (final crew in crews) {
        _memberNames[crew.memberId] = crew.name;
      }
    } catch (_) {
      // 이름 매핑 실패해도 목록 자체는 보여줘야 하므로 조용히 무시.
    }
  }

  String _nameOf(int? memberId) {
    if (memberId == null) return "";
    return _memberNames[memberId] ?? "회원 $memberId";
  }

  String _errorMessage(Object e) {
    if (e is DioException) {
      return e.response?.data?["message"]?.toString() ??
          "요청 목록을 불러오지 못했습니다.";
    }
    return e.toString();
  }

  String _typeText(String type) {
    final upper = type.toUpperCase();
    if (upper.contains("SUBSTITUTE")) return "대타 요청";
    if (upper.contains("SHIFT") || upper.contains("EXCHANGE")) return "교대 요청";
    return type;
  }

  String _statusText(String status) {
    switch (status.toUpperCase()) {
      case "REQUESTED":
        return "대기중";
      case "ACCEPTED_BY_TARGET":
        return "대상 근무자가 요청을 수락";
      case "REJECTED_BY_TARGET":
        return "대상 근무자가 요청을 거절";
      case "APPROVED":
        return "사장 승인 완료";
      case "REJECTED_BY_OWNER":
        return "사장 최종 거절";
      case "CANCELED":
        return "취소됨";
      default:
        return status;
    }
  }

  Color _statusColor(String status) {
    switch (status.toUpperCase()) {
      case "ACCEPTED_BY_TARGET":
      case "ACCEPTED":
        return const Color(0xFF00B475);
      case "REJECTED_BY_TARGET":
      case "REJECTED_BY_OWNER":
        return const Color(0xFFFF4D4F);
      case "CANCELED":
        return const Color(0xFF8E8E93);
      case "REQUESTED":
      default:
        return const Color(0xFF0084FF);
    }
  }

  String _formatDate(DateTime? dt) {
    if (dt == null) return "";
    return "${dt.month}월 ${dt.day}일 "
        "${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          "요청 목록",
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
      body: RefreshIndicator(
        onRefresh: () => _load(reset: true),
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _error != null
            ? ListView(
          children: [
            const SizedBox(height: 120),
            Center(
              child: Text(
                _error!,
                textAlign: TextAlign.center,
              ),
            ),
          ],
        )
            : _items.isEmpty
            ? ListView(
          children: const [
            SizedBox(height: 120),
            Center(
              child: Text(
                "아직 들어온 요청이 없습니다.",
                style: TextStyle(
                  fontSize: 15,
                  color: Color(0xFF767676),
                ),
              ),
            ),
          ],
        )
            : ListView.separated(
          controller: _scrollController,
          padding: const EdgeInsets.all(20),
          itemCount: _items.length + (_page + 1 < _totalPages ? 1 : 0),
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            // 다음 페이지 로딩 인디케이터
            if (index >= _items.length) {
              return const Padding(
                padding: EdgeInsets.symmetric(vertical: 16),
                child: Center(
                  child: SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                ),
              );
            }

            final item = _items[index];
            final requesterName = _nameOf(item.requesterMemberId);
            final targetName = item.targetMemberId != null
                ? _nameOf(item.targetMemberId)
                : null;

            // "대상 근무자가 요청을 수락"(ACCEPTED_BY_TARGET) 상태일 때만
            // 카드를 탭해서 별도의 상세(승인) 페이지로 이동할 수 있게 한다.
            final isAcceptedByTarget =
                item.status.toUpperCase() == "ACCEPTED_BY_TARGET";

            final cardContent = Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFF5F5F7),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          _typeText(item.requestType),
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF8E8E93),
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: _statusColor(item.status).withOpacity(.12),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          _statusText(item.status),
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: _statusColor(item.status),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 8),

                  Text(
                    "요청자: $requesterName",
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  if (targetName != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      "대상자: $targetName",
                      style: const TextStyle(
                        fontSize: 13,
                        color: Color(0xFF444444),
                      ),
                    ),
                  ],

                  if (item.reason != null && item.reason!.isNotEmpty) ...[
                    const SizedBox(height: 6),
                    Text(
                      item.reason!,
                      style: const TextStyle(
                        fontSize: 13,
                        color: Color(0xFF444444),
                      ),
                    ),
                  ],

                  if (item.createdAt != null) ...[
                    const SizedBox(height: 6),
                    Text(
                      _formatDate(item.createdAt),
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF9A9A9A),
                      ),
                    ),
                  ],
                ],
              ),
            );

            if (!isAcceptedByTarget) {
              return cardContent;
            }

            return GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => RWorkChangeRequestDetailPage(
                      item: item,
                      requesterName: requesterName,
                      targetName: targetName,
                    ),
                  ),
                );
              },
              child: cardContent,
            );
          },
        ),
      ),
    );
  }
}