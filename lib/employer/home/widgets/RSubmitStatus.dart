import 'package:flutter/material.dart';

import '../api/SubmitStatusApi.dart';
import '../model/SubmitStatus.dart';

class RSubmitStatusPage extends StatefulWidget {
  final int workPlaceId;
  final int weekScheduleId;

  const RSubmitStatusPage({
    super.key,
    required this.workPlaceId,
    required this.weekScheduleId,
  });

  @override
  State<RSubmitStatusPage> createState() => _RSubmitStatusPageState();
}

class _RSubmitStatusPageState extends State<RSubmitStatusPage> {
  SubmitStatusResponse? _status;
  bool _isLoading = true;
  String? _error;

  // 0: 제출완료 탭, 1: 미제출 탭
  int _selectedTab = 0;

  bool _isRejecting = false;

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
      final res = await SubmitStatusApi.getStatus(
        workPlaceId: widget.workPlaceId,
        weekScheduleId: widget.weekScheduleId,
      );

      setState(() {
        _status = res;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString().replaceFirst("Exception: ", "");
        _isLoading = false;
      });
    }
  }

  // 거절 확인 바텀시트 → 확인 시 실제 반려 API 호출.
  // 반려되면 서버에서 해당 근무자의 제출 데이터가 물리 삭제되므로,
  // 성공 응답을 받으면 로컬에서도 그 근무자를 "미제출"로 옮겨준다.
  Future<void> _showRejectConfirmSheet(WorkerSubmitStatus worker) async {
    final confirmed = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        final bottomInset = MediaQuery.paddingOf(context).bottom;
        return Padding(
          padding: EdgeInsets.fromLTRB(20, 0, 20, bottomInset),
          child: Container(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 43,
                  height: 6,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE0E2E5),
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                const SizedBox(height: 18),
                const Text(
                  '스케줄 제출 거절',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF111111),
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 4),
                const Text(
                  '거절된 근무자는 스케줄을 다시 제출해야해요',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF767676),
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context, true),
                    style: ElevatedButton.styleFrom(
                      elevation: 0,
                      backgroundColor: const Color(0xFF0084FF),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      '거절',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                GestureDetector(
                  onTap: () => Navigator.pop(context, false),
                  child: const Padding(
                    padding: EdgeInsets.symmetric(vertical: 4),
                    child: Text(
                      '취소',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF111111),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );

    if (confirmed != true || _status == null || _isRejecting) return;

    setState(() => _isRejecting = true);

    try {
      await SubmitStatusApi.rejectSubmission(
        workPlaceId: widget.workPlaceId,
        weekScheduleId: widget.weekScheduleId,
        memberId: worker.memberId,
      );

      if (!mounted) return;

      setState(() {
        _status = SubmitStatusResponse(
          workPlaceId: _status!.workPlaceId,
          weekScheduleId: _status!.weekScheduleId,
          workers: [
            for (final w in _status!.workers)
              if (w.memberId == worker.memberId)
                WorkerSubmitStatus(
                  memberId: w.memberId,
                  memberName: w.memberName,
                  submitted: false,
                )
              else
                w,
          ],
        );
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString().replaceFirst("Exception: ", ""))),
      );
    } finally {
      if (mounted) {
        setState(() => _isRejecting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "제출 현황",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(_error!, style: const TextStyle(color: Colors.red)),
                      const SizedBox(height: 12),
                      ElevatedButton(onPressed: _load, child: const Text("다시 시도")),
                    ],
                  ),
                )
              : Column(
                  children: [
                    _buildTabBar(),
                    const Divider(height: 1, color: Color(0xFFF2F2F2)),
                    Expanded(child: _buildWorkerList()),
                  ],
                ),
    );
  }

  Widget _buildTabBar() {
    return Row(
      children: [
        Expanded(child: _buildTabItem("제출완료", 0)),
        Expanded(child: _buildTabItem("미제출", 1)),
      ],
    );
  }

  Widget _buildTabItem(String title, int index) {
    final selected = _selectedTab == index;
    return GestureDetector(
      onTap: () => setState(() => _selectedTab = index),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: selected ? const Color(0xFF111111) : Colors.transparent,
              width: 2,
            ),
          ),
        ),
        child: Center(
          child: Text(
            title,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: selected ? const Color(0xFF111111) : const Color(0xFFAEAEAE),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildWorkerList() {
    final workers = _selectedTab == 0
        ? _status!.submittedWorkers
        : _status!.notSubmittedWorkers;

    if (workers.isEmpty) {
      return Center(
        child: Text(
          _selectedTab == 0 ? "제출한 근무자가 없어요" : "미제출한 근무자가 없어요",
          style: const TextStyle(color: Color(0xFF999999)),
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      itemCount: workers.length,
      separatorBuilder: (_, __) =>
          const Divider(height: 1, color: Color(0xFFF2F2F2)),
      itemBuilder: (context, index) {
        final worker = workers[index];
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  worker.memberName,
                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                ),
              ),
              if (_selectedTab == 0)
                OutlinedButton(
                  onPressed: _isRejecting ? null : () => _showRejectConfirmSheet(worker),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF0084FF),
                    side: const BorderSide(color: Color(0xFF0084FF)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                  ),
                  child: const Text("거절", style: TextStyle(fontSize: 13)),
                ),
            ],
          ),
        );
      },
    );
  }
}
