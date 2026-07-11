import 'package:flutter/material.dart';

import '../../crews/model/WorkChangeRequestResponse.dart';
import '../api/WorkChangeRequestListApi.dart';


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
  late Future<List<WorkChangeRequestResponse>> _future;

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  Future<List<WorkChangeRequestResponse>> _load() async {
    final result = await _api.fetchRequests(
      workPlaceId: widget.workPlaceId,
      scope: "SENT",
      page: 0,
      size: 20,
    );
    return result.content;
  }

  Future<void> _refresh() async {
    final future = _load();
    setState(() {
      _future = future;
    });
    await future;
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

            Expanded(
              child: FutureBuilder<List<WorkChangeRequestResponse>>(
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

                  final items = snapshot.data ?? [];

                  if (items.isEmpty) {
                    return RefreshIndicator(
                      onRefresh: _refresh,
                      child: ListView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        children: const [
                          SizedBox(height: 120),
                          Center(child: Text("보낸 요청이 없어요.")),
                        ],
                      ),
                    );
                  }

                  return RefreshIndicator(
                    onRefresh: _refresh,
                    child: ListView.separated(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 12,
                      ),
                      physics: const AlwaysScrollableScrollPhysics(),
                      itemCount: items.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        return _SentRequestCard(request: items[index]);
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

class _SentRequestCard extends StatelessWidget {
  const _SentRequestCard({required this.request});

  final WorkChangeRequestResponse request;

  String get _typeLabel {
    switch (request.requestType) {
      case "SUBSTITUTE":
        return "대타 요청";
      case "SHIFT_SWAP":
        return "교대 요청";
      default:
        return request.requestType;
    }
  }

  String get _statusLabel {
    switch (request.status) {
      case "REQUESTED":
        return "응답 대기중";
      case "ACCEPTED":
        return "수락됨";
      case "REJECTED":
        return "거절됨";
      case "CANCELED":
        return "취소됨";
      default:
        return request.status;
    }
  }

  Color get _statusColor {
    switch (request.status) {
      case "REQUESTED":
        return const Color(0xFF7D67FD);
      case "ACCEPTED":
        return const Color(0xFF00B475);
      case "REJECTED":
        return const Color(0xFFFF5C5C);
      default:
        return const Color(0xFF8F8F8F);
    }
  }

  String get _createdAtLabel {
    final dt = DateTime.tryParse(request.createdAt);
    if (dt == null) return request.createdAt;
    return "${dt.month}월 ${dt.day}일 ${dt.hour.toString().padLeft(2, '0')}:"
        "${dt.minute.toString().padLeft(2, '0')} 신청";
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFDDD7FE),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  _typeLabel,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF6450D4),
                  ),
                ),
              ),
              const Spacer(),
              Row(
                children: [
                  Container(
                    width: 6,
                    height: 6,
                    decoration: BoxDecoration(
                      color: _statusColor,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    _statusLabel,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: _statusColor,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            request.reason,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w500,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _createdAtLabel,
            style: const TextStyle(
              fontSize: 12,
              color: Color(0xFF9A9A9A),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}