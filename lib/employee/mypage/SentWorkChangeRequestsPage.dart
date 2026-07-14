import 'package:flutter/material.dart';

import '../crews/model/WorkChangeRequestResponse.dart';
import '../home/api/WorkChangeRequestListApi.dart';
import '../home/model/AssignmentResolver.dart';

/// 목록 한 줄에 필요한 데이터: 원본 요청 + 미리 조회해둔 상대 회원 이름
class _SentRequestItem {
  const _SentRequestItem({
    required this.request,
    required this.targetName,
  });

  final WorkChangeRequestResponse request;
  final String targetName;
}

/// 내가 보낸(SENT) 대타/교대 요청 목록 화면
class SentWorkChangeRequestsPage extends StatefulWidget {
  const SentWorkChangeRequestsPage({
    super.key,
    required this.workPlaceId,
  });

  final int workPlaceId;

  @override
  State<SentWorkChangeRequestsPage> createState() =>
      _SentWorkChangeRequestsPageState();
}

class _SentWorkChangeRequestsPageState
    extends State<SentWorkChangeRequestsPage> {
  final _api = WorkChangeRequestListApi();
  late Future<List<_SentRequestItem>> _future;

  /// 0: 전체보기, 1: 대기 중
  int _selectedTab = 0;

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  Future<List<_SentRequestItem>> _load() async {
    final result = await _api.fetchRequests(
      workPlaceId: widget.workPlaceId,
      scope: "SENT",
      page: 0,
      size: 20,
    );

    final requests = result.content;

    // 요청마다 상대 회원(target) 쪽 근무 정보를 조회해서 이름을 채워 넣는다.
    final items = await Future.wait(
      requests.map((request) async {
        final name = await _resolveTargetName(request);
        return _SentRequestItem(request: request, targetName: name);
      }),
    );

    return items;
  }

  /// 상대 회원 이름 조회.
  /// targetAssignmentId가 있으면 그 근무를, 없으면(SUBSTITUTE) requestAssignmentId 근무를
  /// 기준으로 AssignmentResolver에서 workerName을 찾아온다.
  /// 이름을 찾지 못하면 "멤버 #id"로 대체 표시한다.
  Future<String> _resolveTargetName(WorkChangeRequestResponse request) async {
    if (request.targetMemberId == null) {
      return "대상 미정";
    }

    try {
      final createdAt = DateTime.parse(request.createdAt);
      final (fromDate, toDate) =
      AssignmentResolver.defaultRangeAround(createdAt);

      final assignmentMap = await AssignmentResolver.buildAssignmentMap(
        workPlaceId: widget.workPlaceId,
        fromDate: fromDate,
        toDate: toDate,
      );

      final assignmentId =
          request.targetAssignmentId ?? request.requestAssignmentId;
      final resolved =
      assignmentId != null ? assignmentMap[assignmentId] : null;

      return resolved?.workerName ?? "멤버 #${request.targetMemberId}";
    } catch (_) {
      return "멤버 #${request.targetMemberId}";
    }
  }

  Future<void> _refresh() async {
    final future = _load();
    setState(() {
      _future = future;
    });
    await future;
  }

  List<_SentRequestItem> _filter(List<_SentRequestItem> items) {
    if (_selectedTab == 1) {
      return items.where((e) => e.request.status == "REQUESTED").toList();
    }
    return items;
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
                        "보낸 요청 내역",
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

            /// 탭 (전체보기 / 대기 중)
            _SentRequestTabBar(
              selectedIndex: _selectedTab,
              onChanged: (index) {
                setState(() {
                  _selectedTab = index;
                });
              },
            ),

            // /// 안내 배너
            // Padding(
            //   padding: const EdgeInsets.fromLTRB(20, 16, 20, 4),
            //   child: Container(
            //     width: double.infinity,
            //     padding: const EdgeInsets.symmetric(
            //       horizontal: 14,
            //       vertical: 12,
            //     ),
            //     decoration: BoxDecoration(
            //       color: const Color(0xFFF0F0F3),
            //       borderRadius: BorderRadius.circular(10),
            //     ),
            //     child: Row(
            //       children: [
            //         const Icon(
            //           Icons.info_outline,
            //           size: 16,
            //           color: Color(0xFF9A9A9A),
            //         ),
            //         const SizedBox(width: 6),
            //         Expanded(
            //           child: Text(
            //             "보낸 요청 내역은 최대 3일까지 보관돼요",
            //             style: const TextStyle(
            //               fontSize: 12.5,
            //               color: Color(0xFF8F8F8F),
            //               fontWeight: FontWeight.w500,
            //             ),
            //           ),
            //         ),
            //       ],
            //     ),
            //   ),
            // ),

            Expanded(
              child: FutureBuilder<List<_SentRequestItem>>(
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
                              _selectedTab == 1
                                  ? "대기 중인 요청이 없어요."
                                  : "보낸 요청이 없어요.",
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
                        return _SentRequestCard(item: items[index]);
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

/// 전체보기 / 대기 중 탭 바
class _SentRequestTabBar extends StatelessWidget {
  const _SentRequestTabBar({
    required this.selectedIndex,
    required this.onChanged,
  });

  final int selectedIndex;
  final ValueChanged<int> onChanged;

  static const _tabs = ["전체보기", "대기 중"];

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Color(0xFFEAEAEA), width: 1),
        ),
      ),
      child: Row(
        children: List.generate(_tabs.length, (index) {
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
                  _tabs[index],
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

class _SentRequestCard extends StatelessWidget {
  const _SentRequestCard({required this.item});

  final _SentRequestItem item;

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
      // 교대(SHIFT_SWAP)는 상대의 "응답"을, 대타(SUBSTITUTE)는 관리자의 "승인"을 기다리는 흐름을 반영
        return request.requestType == "SUBSTITUTE"
            ? "승인 대기 중"
            : "응답 대기 중";
      case "ACCEPTED":
        return "수락 완료";
      case "REJECTED":
        return "거절 완료";
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
      case "ACCEPTED":
        return const Color(0xFF3D7DFF);
      case "REJECTED":
        return const Color(0xFFFF5C5C);
      default:
        return const Color(0xFF8F8F8F);
    }
  }

  Color get _statusBackgroundColor {
    switch (request.status) {
      case "REQUESTED":
        return const Color(0xFFD8F5E9);
      case "ACCEPTED":
        return const Color(0xFFDDE8FF);
      case "REJECTED":
        return const Color(0xFFFFE1E1);
      default:
        return const Color(0xFFECECEC);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                item.targetName,
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
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
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
    );
  }
}