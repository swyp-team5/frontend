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
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          "제출 현황",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black, // 뒤로가기 아이콘 및 텍스트 색상
      ),
      // UI는 요청 범위 밖 — 데이터 로딩/에러 상태만 최소 구성
      body: Center(
        child: _isLoading
            ? const CircularProgressIndicator()
            : _error != null
            ? Text(_error!)
            : Text(
          "제출완료 ${_status!.submittedCount}명 / 미제출 ${_status!.notSubmittedCount}명",
        ),
      ),
    );
  }
}