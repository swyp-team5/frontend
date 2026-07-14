import 'package:flutter/material.dart';

import '../crews/model/WorkChangeRequestResponse.dart';
import '../home/api/WorkChangeRequestListApi.dart';
import '../home/model/AssignmentResolver.dart';

/// 목록 한 줄에 필요한 데이터: 원본 요청 + 미리 조회해둔 상대(요청자) 회원 이름
class _ReceivedRequestItem {
  const _ReceivedRequestItem({
    required this.request,
    required this.requesterName,
  });

  final WorkChangeRequestResponse request;
  final String requesterName;
}

/// 내가 받은(RECEIVED) 대타/교대 요청 목록 화면
class ReceivedWorkChangeRequestsPage extends StatefulWidget {
  const ReceivedWorkChangeRequestsPage({
    super.key,
    required this.workPlaceId,
  });

  final int workPlaceId;

  @override
  State<ReceivedWorkChangeRequestsPage> createState() =>
      _ReceivedWorkChangeRequestsPageState();
}

class _ReceivedWorkChangeRequestsPageState
    extends State<ReceivedWorkChangeRequestsPage> {
  final _api = WorkChangeRequestListApi();
  late Future<List<_ReceivedRequestItem>> _future;

  /// 0: 답변 대기, 1: 답변 완료
  int _selectedTab = 0;

  /// 수락/거절 처리 중인 요청 id (버튼 중복 클릭 방지 + 로딩 표시용)
  int? _respondingId;

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  Future<List<_ReceivedRequestItem>> _load() async {
    final result = await _api.fetchRequests(
      workPlaceId: widget.workPlaceId,
      scope: "RECEIVED",
      page: 0,
      size: 20,
    );

    final requests = result.content;

    // 요청마다 상대(요청자) 회원 쪽 근무 정보를 조회해서 이름을 채워 넣는다.
    final items = await Future.wait(
      requests.map((request) async {
        final name = await _resolveRequesterName(request);
        return _ReceivedRequestItem(request: request, requesterName: name);
      }),
    );

    return items;
  }

  /// 요청을 보낸 상대(requester) 이름 조회.
  /// requester 쪽 근무는 requestAssignmentId를 기준으로 삼는다.
  /// (SENT 페이지에서 target 쪽을 targetAssignmentId ?? requestAssignmentId로
  /// 봤던 것과 대칭되는 개념: RECEIVED에서는 요청을 보낸 사람의 근무 = requestAssignmentId)
  /// 이름을 찾지 못하면 "멤버 #id"로 대체 표시한다.
  Future<String> _resolveRequesterName(
      WorkChangeRequestResponse request) async {
    try {
      final createdAt = DateTime.parse(request.createdAt);
      final (fromDate, toDate) =
      AssignmentResolver.defaultRangeAround(createdAt);

      final assignmentMap = await AssignmentResolver.buildAssignmentMap(
        workPlaceId: widget.workPlaceId,
        fromDate: fromDate,
        toDate: toDate,
      );

      final resolved = request.requestAssignmentId != null
          ? assignmentMap[request.requestAssignmentId]
          : null;

      return resolved?.workerName ?? "멤버 #${request.requesterMemberId}";
    } catch (_) {
      return "멤버 #${request.requesterMemberId}";
    }
  }

  Future<void> _refresh() async {
    final future = _load();
    setState(() {
      _future = future;
    });
    await future;
  }

  /// 답변 대기: status == "REQUESTED"
  /// 답변 완료: 그 외 전부 (ACCEPTED / REJECTED / CANCELED 등)
  List<_ReceivedRequestItem> _filter(List<_ReceivedRequestItem> items) {
    if (_selectedTab == 0) {
      return items.where((e) => e.request.status == "REQUESTED").toList();
    }
    return items.where((e) => e.request.status != "REQUESTED").toList();
  }

  Future<void> _respond({
    required WorkChangeRequestResponse request,
    required bool accept,
  }) async {
    if (_respondingId != null) return; // 이미 처리 중이면 무시

    setState(() {
      _respondingId = request.workChangeRequestId;
    });

    try {
      await _api.respondToRequest(
        workPlaceId: widget.workPlaceId,
        workChangeRequestId: request.workChangeRequestId,
        accept: accept,
      );
      await _refresh();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("처리하지 못했어요: $e")),
      );
    } finally {
      if (mounted) {
        setState(() {
          _respondingId = null;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F7),
      body: SafeArea(
        child: Column(
          children: [
            /// 헤더
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 24,
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
                        "받은 요청 내역",
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

            /// 탭 (답변 대기 {건수} / 답변 완료)
            FutureBuilder<List<_ReceivedRequestItem>>(
              future: _future,
              builder: (context, snapshot) {
                final pendingCount = (snapshot.data ?? [])
                    .where((e) => e.request.status == "REQUESTED")
                    .length;

                return _ReceivedRequestTabBar(
                  selectedIndex: _selectedTab,
                  pendingCount: pendingCount,
                  onChanged: (index) {
                    setState(() {
                      _selectedTab = index;
                    });
                  },
                );
              },
            ),

            Expanded(
              child: FutureBuilder<List<_ReceivedRequestItem>>(
                future: _future,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (snapshot.hasError) {
                    return Center(
                      child: Text("불러오지 못했어요: ${snapshot.error}"),
                    );
                  }

                  final items = _filter(snapshot.data ?? []);

                  if (items.isEmpty) {
                    return RefreshIndicator(
                      onRefresh: _refresh,
                      child: ListView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        children: [
                          const SizedBox(height: 120),
                          Center(
                            child: Text(
                              _selectedTab == 0
                                  ? "답변 대기 중인 요청이 없어요."
                                  : "답변 완료된 요청이 없어요.",
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  return RefreshIndicator(
                    onRefresh: _refresh,
                    child: ListView.separated(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 20,
                      ),
                      physics: const AlwaysScrollableScrollPhysics(),
                      itemCount: items.length,
                      separatorBuilder: (_, __) => const Divider(
                        height: 40,
                        thickness: 1,
                        color: Color(0xFFECECEC),
                      ),
                      itemBuilder: (context, index) {
                        final item = items[index];
                        final isResponding =
                            _respondingId == item.request.workChangeRequestId;

                        return _ReceivedRequestCard(
                          item: item,
                          isResponding: isResponding,
                          onAccept: () => _respond(
                            request: item.request,
                            accept: true,
                          ),
                          onReject: () => _respond(
                            request: item.request,
                            accept: false,
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// 답변 대기 / 답변 완료 탭 바
class _ReceivedRequestTabBar extends StatelessWidget {
  const _ReceivedRequestTabBar({
    required this.selectedIndex,
    required this.onChanged,
    this.pendingCount = 0,
  });

  final int selectedIndex;
  final ValueChanged<int> onChanged;
  final int pendingCount;

  @override
  Widget build(BuildContext context) {
    final tabs = ["답변 대기 $pendingCount", "답변 완료"];

    return Container(
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Color(0xFFEAEAEA), width: 1),
        ),
      ),
      child: Row(
        children: List.generate(tabs.length, (index) {
          final isSelected = index == selectedIndex;
          return Expanded(
            child: GestureDetector(
              onTap: () => onChanged(index),
              behavior: HitTestBehavior.opaque,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                padding: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: isSelected
                          ? Colors.black
                          : Colors.transparent,
                      width: 2,
                    ),
                  ),
                ),
                alignment: Alignment.center,
                child: Text(
                  tabs[index],
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight:
                    isSelected ? FontWeight.w700 : FontWeight.w500,
                    color: isSelected
                        ? Colors.black
                        : const Color(0xFFB0B0B0),
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}

class _ReceivedRequestCard extends StatelessWidget {
  const _ReceivedRequestCard({
    required this.item,
    required this.onAccept,
    required this.onReject,
    this.isResponding = false,
  });

  final _ReceivedRequestItem item;
  final VoidCallback onAccept;
  final VoidCallback onReject;
  final bool isResponding;

  WorkChangeRequestResponse get request => item.request;

  String get _typeLabel {
    switch (request.requestType) {
      case "SUBSTITUTE":
        return "대타 근무";
      case "SHIFT_SWAP":
        return "교대 근무";
      default:
        return request.requestType;
    }
  }

  String get _statusLabel {
    switch (request.status) {
      case "REQUESTED":
        return "답변 대기";
      case "ACCEPTED_BY_TARGET":
        return "근무자 수락 완료";
      case "APPROVED":
        return "사장님 수락 완료";
      case "REJECTED_BY_TARGET":
        return "근무자 수락 거절";
      case "REJECTED_BY_OWNER":
        return "사장님 수락 거절";
      case "CANCELED":
        return "취소됨";
      default:
        return request.status;
    }
  }

  Color get _statusColor {
    switch (request.status) {
      case "REQUESTED":
        return const Color(0xFF00B475);
      case "ACCEPTED_BY_TARGET":
      case "APPROVED":
        return const Color(0xFF3D7DFF);
      case "REJECTED_BY_TARGET":
      case "REJECTED_BY_OWNER":
        return const Color(0xFFFF5C5C);
      default:
        return const Color(0xFF8F8F8F);
    }
  }

  Color get _statusBackgroundColor {
    switch (request.status) {
      case "REQUESTED":
        return const Color(0xFFD8F5E9);
      case "ACCEPTED_BY_TARGET":
      case "APPROVED":
        return const Color(0xFFDDE8FF);
      case "REJECTED_BY_TARGET":
      case "REJECTED_BY_OWNER":
        return const Color(0xFFFFE1E1);
      default:
        return const Color(0xFFECECEC);
    }
  }

  bool get _isPending => request.status == "REQUESTED";

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.requesterName,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF505050),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _typeLabel,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding:
              const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: _statusBackgroundColor,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                _statusLabel,
                style: TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w700,
                  color: _statusColor,
                ),
              ),
            ),
          ],
        ),

        if (_isPending) ...[
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: isResponding ? null : onReject,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF8F8F8F),
                    side: const BorderSide(color: Color(0xFFDADADA)),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text("거절"),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ElevatedButton(
                  onPressed: isResponding ? null : onAccept,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    elevation: 0,
                  ),
                  child: isResponding
                      ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                      : const Text("수락"),
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }
}