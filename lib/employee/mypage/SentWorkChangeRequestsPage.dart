import 'package:flutter/material.dart';

import '../../common/auth/server_token_manager.dart';
import '../crews/model/WorkChangeRequestResponse.dart';
import '../home/api/WorkChangeRequestListApi.dart';

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

  /// 사업장 크루 목록을 조회해서 memberId -> 이름 맵으로 변환한다.
  Future<Map<int, String>> _loadNameByMemberId() async {
    try {
      final response = await ServerTokenManager.authorizedDio.get(
        "/api/work-places/${widget.workPlaceId}/crews",
      );

      final List crews = (response.data["crews"] ?? []) as List;
      final map = <int, String>{};
      for (final e in crews) {
        final crew = Map<String, dynamic>.from(e ?? {});
        final memberId = crew["memberId"] is int
            ? crew["memberId"] as int
            : int.tryParse(crew["memberId"]?.toString() ?? "");
        if (memberId == null) continue;
        map[memberId] = crew["name"]?.toString() ?? "이름 없음";
      }
      return map;
    } catch (e) {
      debugPrint("[SentWorkChangeRequestsPage] 크루 목록 조회 실패: $e");
      return {};
    }
  }

  Future<List<_SentRequestItem>> _load() async {
    final result = await _api.fetchRequests(
      workPlaceId: widget.workPlaceId,
      scope: "SENT",
      page: 0,
      size: 20,
    );

    final requests = result.content;
    final nameByMemberId = await _loadNameByMemberId();

    final items = requests.map((request) {
      if (request.targetMemberId == null) {
        return _SentRequestItem(request: request, targetName: "대상 미정");
      }
      final name = nameByMemberId[request.targetMemberId] ??
          "멤버 #${request.targetMemberId}";
      return _SentRequestItem(request: request, targetName: name);
    }).toList();

    return items;
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