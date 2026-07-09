import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../common/workplace/selected_work_place_storage.dart';
import 'api/crew_invitation_api.dart';

class RCrewInvitationHistoryPage extends StatefulWidget {
  const RCrewInvitationHistoryPage({super.key});

  @override
  State<RCrewInvitationHistoryPage> createState() =>
      _RCrewInvitationHistoryPageState();
}

class _RCrewInvitationHistoryPageState
    extends State<RCrewInvitationHistoryPage> {
  final CrewInvitationApi _api = CrewInvitationApi();
  final DateFormat _dateFormat = DateFormat('yyyy.MM.dd HH:mm');

  final List<CrewInvitationHistoryItem> _items = [];
  bool _isLoading = true;
  bool _isLoadingMore = false;
  int _page = 0;
  int _totalPages = 0;
  int? _workPlaceId;

  bool get _hasNextPage => _page + 1 < _totalPages;

  @override
  void initState() {
    super.initState();
    _loadFirstPage();
  }

  Future<void> _loadFirstPage() async {
    setState(() {
      _isLoading = true;
      _items.clear();
      _page = 0;
      _totalPages = 0;
    });

    try {
      _workPlaceId = await SelectedWorkPlaceStorage.load();
      if (_workPlaceId == null) {
        throw Exception('선택된 매장이 없어요.');
      }

      final response = await _api.getHistory(
        workPlaceId: _workPlaceId!,
        page: 0,
      );

      if (!mounted) {
        return;
      }

      setState(() {
        _items.addAll(response.content);
        _page = response.page;
        _totalPages = response.totalPages;
      });
    } catch (e) {
      _showMessage(_messageFromError(e, '초대 이력을 불러오지 못했어요.'));
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _loadNextPage() async {
    if (!_hasNextPage || _workPlaceId == null || _isLoadingMore) {
      return;
    }

    setState(() {
      _isLoadingMore = true;
    });

    try {
      final response = await _api.getHistory(
        workPlaceId: _workPlaceId!,
        page: _page + 1,
      );

      if (!mounted) {
        return;
      }

      setState(() {
        _items.addAll(response.content);
        _page = response.page;
        _totalPages = response.totalPages;
      });
    } catch (e) {
      _showMessage(_messageFromError(e, '다음 이력을 불러오지 못했어요.'));
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingMore = false;
        });
      }
    }
  }

  void _showMessage(String message) {
    if (!mounted) {
      return;
    }
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  String _messageFromError(Object error, String fallback) {
    final text = error.toString();
    if (text.startsWith('Exception: ')) {
      return text.replaceFirst('Exception: ', '');
    }
    return fallback;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
              child: SizedBox(
                height: 40,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    const Center(
                      child: Text(
                        '초대 코드 이력',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: const Icon(Icons.arrow_back_ios_new, size: 22),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : RefreshIndicator(
                      onRefresh: _loadFirstPage,
                      child: ListView(
                        padding: const EdgeInsets.fromLTRB(22, 26, 22, 26),
                        children: [
                          if (_items.isEmpty)
                            const Padding(
                              padding: EdgeInsets.only(top: 120),
                              child: Center(
                                child: Text(
                                  '아직 생성된 초대 코드가 없어요.',
                                  style: TextStyle(
                                    color: Color(0xFF767676),
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                            )
                          else
                            ..._items.map(_historyCard),
                          if (_hasNextPage) ...[
                            const SizedBox(height: 10),
                            SizedBox(
                              height: 52,
                              child: OutlinedButton(
                                onPressed: _isLoadingMore
                                    ? null
                                    : _loadNextPage,
                                style: OutlinedButton.styleFrom(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                child: Text(
                                  _isLoadingMore ? '불러오는 중...' : '더 보기',
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _historyCard(CrewInvitationHistoryItem item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  item.inviteCode,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              _statusChip(item),
            ],
          ),
          const SizedBox(height: 12),
          _infoRow('생성', _dateFormat.format(item.createdAt)),
          _infoRow('만료', _dateFormat.format(item.expiresAt)),
          if (item.usedAt != null)
            _infoRow('사용', _dateFormat.format(item.usedAt!)),
          if (item.usedByMemberName != null &&
              item.usedByMemberName!.isNotEmpty)
            _infoRow('사용자', item.usedByMemberName!),
          if (item.failedAttemptCount > 0)
            _infoRow('실패 횟수', '${item.failedAttemptCount}회'),
          const SizedBox(height: 10),
          Text(
            item.inviteUrl,
            style: const TextStyle(color: Color(0xFF767676), fontSize: 13),
          ),
        ],
      ),
    );
  }

  Widget _statusChip(CrewInvitationHistoryItem item) {
    final color = switch (item.status) {
      'ACTIVE' => const Color(0xFF0084FF),
      'USED' => const Color(0xFF34C759),
      'EXPIRED' => const Color(0xFF8E8E93),
      'LOCKED' => const Color(0xFFFF3B30),
      _ => const Color(0xFF767676),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        item.statusLabel,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          SizedBox(
            width: 64,
            child: Text(
              label,
              style: const TextStyle(color: Color(0xFF999999), fontSize: 13),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}
