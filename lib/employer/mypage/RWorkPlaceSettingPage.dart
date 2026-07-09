import 'package:flutter/material.dart';

import '../../common/workplace/selected_work_place_storage.dart';
import 'RWorkPlaceCreatePage.dart';
import 'api/work_place_api.dart';

class RWorkPlaceSettingPage extends StatefulWidget {
  const RWorkPlaceSettingPage({super.key});

  @override
  State<RWorkPlaceSettingPage> createState() => _RWorkPlaceSettingPageState();
}

class _RWorkPlaceSettingPageState extends State<RWorkPlaceSettingPage> {
  final WorkPlaceApi _api = WorkPlaceApi();

  List<WorkPlaceSummary> _workPlaces = [];
  int? _selectedWorkPlaceId;
  bool _isLoading = true;

  WorkPlaceSummary? get _selectedWorkPlace {
    for (final workPlace in _workPlaces) {
      if (workPlace.workPlaceId == _selectedWorkPlaceId) {
        return workPlace;
      }
    }
    return _workPlaces.isEmpty ? null : _workPlaces.first;
  }

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final storedId = await SelectedWorkPlaceStorage.load();
      final workPlaces = await _api.getMyWorkPlaces();

      int? selectedId = storedId;
      if (selectedId == null ||
          !workPlaces.any((e) => e.workPlaceId == selectedId)) {
        selectedId = workPlaces.isEmpty ? null : workPlaces.first.workPlaceId;
      }

      if (selectedId != null) {
        await SelectedWorkPlaceStorage.save(selectedId);
      }

      if (!mounted) {
        return;
      }

      setState(() {
        _workPlaces = workPlaces;
        _selectedWorkPlaceId = selectedId;
      });
    } catch (e) {
      _showMessage(_messageFromError(e, '매장 정보를 불러오지 못했어요.'));
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _selectWorkPlace(WorkPlaceSummary workPlace) async {
    await SelectedWorkPlaceStorage.save(workPlace.workPlaceId);

    if (!mounted) {
      return;
    }

    setState(() {
      _selectedWorkPlaceId = workPlace.workPlaceId;
    });

    _showMessage('${workPlace.name} 매장으로 변경했어요.');
  }

  Future<void> _goToCreatePage() async {
    final created = await Navigator.push<WorkPlaceSummary>(
      context,
      MaterialPageRoute(builder: (_) => const RWorkPlaceCreatePage()),
    );

    if (created == null) {
      return;
    }

    await SelectedWorkPlaceStorage.save(created.workPlaceId);

    if (!mounted) {
      return;
    }

    setState(() {
      _workPlaces = [..._workPlaces, created];
      _selectedWorkPlaceId = created.workPlaceId;
    });

    _showMessage('매장이 추가되었어요.');
  }

  Future<void> _showPhoneBottomSheet() async {
    final current = _selectedWorkPlace;
    if (current == null) {
      return;
    }

    final updated = await showModalBottomSheet<WorkPlaceSummary>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return _PhoneNumberBottomSheet(
          current: current,
          onUpdate: _updatePhoneNumber,
        );
      },
    );

    if (updated == null || !mounted) {
      return;
    }

    setState(() {
      _workPlaces = _workPlaces
          .map((e) => e.workPlaceId == updated.workPlaceId ? updated : e)
          .toList();
    });

    _showMessage('전화번호가 변경되었어요.');
  }

  Future<WorkPlaceSummary?> _updatePhoneNumber(
    WorkPlaceSummary current,
    String? phoneNumber,
  ) async {
    final normalized = WorkPlaceApi.normalizePhoneNumber(phoneNumber);

    if (normalized != null &&
        (normalized.length < 8 || normalized.length > 11)) {
      _showMessage('전화번호는 숫자 8~11자리로 입력해주세요.');
      return null;
    }

    try {
      return await _api.updatePhoneNumber(
        workPlaceId: current.workPlaceId,
        phoneNumber: phoneNumber,
      );
    } catch (e) {
      _showMessage(_messageFromError(e, '전화번호 변경에 실패했어요.'));
      return null;
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
    final selected = _selectedWorkPlace;

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
                        '매장 설정',
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
                      onRefresh: _load,
                      child: ListView(
                        padding: const EdgeInsets.fromLTRB(22, 30, 22, 22),
                        children: [
                          if (selected != null) ...[
                            _sectionTitle('현재 매장'),
                            const SizedBox(height: 12),
                            _selectedWorkPlaceCard(selected),
                            const SizedBox(height: 30),
                          ],
                          _sectionTitle('매장 목록'),
                          const SizedBox(height: 12),
                          ..._workPlaces.map(_workPlaceTile),
                          const SizedBox(height: 24),
                          SizedBox(
                            width: double.infinity,
                            height: 56,
                            child: ElevatedButton.icon(
                              onPressed: _goToCreatePage,
                              icon: const Icon(Icons.add),
                              label: const Text('매장 추가'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF0084FF),
                                foregroundColor: Colors.white,
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _selectedWorkPlaceCard(WorkPlaceSummary workPlace) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            workPlace.name,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 10),
          Text(
            _sizeLabel(workPlace.size),
            style: const TextStyle(color: Color(0xFF767676)),
          ),
          const SizedBox(height: 6),
          Text(
            workPlace.displayAddress,
            style: const TextStyle(color: Color(0xFF767676)),
          ),
          const SizedBox(height: 18),
          InkWell(
            borderRadius: BorderRadius.circular(10),
            onTap: _showPhoneBottomSheet,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
              decoration: BoxDecoration(
                color: const Color(0xFFF7F7FB),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  const Icon(Icons.phone_outlined, size: 20),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      workPlace.displayPhoneNumber,
                      style: const TextStyle(fontSize: 15),
                    ),
                  ),
                  const Icon(Icons.chevron_right, color: Color(0xFF999999)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _workPlaceTile(WorkPlaceSummary workPlace) {
    final selected = workPlace.workPlaceId == _selectedWorkPlaceId;

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => _selectWorkPlace(workPlace),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
          decoration: BoxDecoration(
            color: selected ? const Color(0xFFE6F3FF) : Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: selected
                ? Border.all(color: const Color(0xFF0084FF), width: 1.5)
                : null,
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      workPlace.name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      workPlace.displayPhoneNumber,
                      style: const TextStyle(
                        color: Color(0xFF767676),
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              if (selected)
                const Icon(Icons.check_circle, color: Color(0xFF0084FF)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        color: Color(0xFF767676),
        fontSize: 16,
        fontWeight: FontWeight.w700,
      ),
    );
  }

  String _sizeLabel(String size) {
    switch (size) {
      case 'ONE_TO_FOUR':
        return '1~4명';
      case 'FIVE_TO_NINE':
        return '5~9명';
      case 'TEN_TO_SEVENTEEN':
        return '10~17명';
      case 'EIGHTEEN_TO_TWENTY_THREE':
        return '18~23명';
      case 'TWENTY_FOUR_OR_MORE':
        return '24명 이상';
      default:
        return size;
    }
  }
}

class _PhoneNumberBottomSheet extends StatefulWidget {
  const _PhoneNumberBottomSheet({
    required this.current,
    required this.onUpdate,
  });

  final WorkPlaceSummary current;
  final Future<WorkPlaceSummary?> Function(
    WorkPlaceSummary current,
    String? phoneNumber,
  )
  onUpdate;

  @override
  State<_PhoneNumberBottomSheet> createState() =>
      _PhoneNumberBottomSheetState();
}

class _PhoneNumberBottomSheetState extends State<_PhoneNumberBottomSheet> {
  late final TextEditingController _controller;
  bool _isSaving = false;

  bool get _hasPhoneNumber =>
      widget.current.phoneNumber != null && widget.current.phoneNumber!.isNotEmpty;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(
      text: widget.current.phoneNumber ?? '',
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _submit(String? phoneNumber) async {
    if (_isSaving) {
      return;
    }

    FocusManager.instance.primaryFocus?.unfocus();

    setState(() {
      _isSaving = true;
    });

    try {
      await Future<void>.delayed(const Duration(milliseconds: 250));

      final updated = await widget.onUpdate(
        widget.current,
        phoneNumber,
      );

      if (!mounted || updated == null) {
        return;
      }

      Navigator.of(context).pop(updated);
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedPadding(
      duration: const Duration(milliseconds: 180),
      curve: Curves.easeOut,
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: SafeArea(
        top: false,
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 48,
                  height: 5,
                  decoration: BoxDecoration(
                    color: const Color(0xFFD9D9D9),
                    borderRadius: BorderRadius.circular(100),
                  ),
                ),
                const SizedBox(height: 22),
                const Text(
                  '매장 전화번호',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 22),
                TextField(
                  controller: _controller,
                  keyboardType: TextInputType.phone,
                  enabled: !_isSaving,
                  decoration: InputDecoration(
                    hintText: '예시) 0212345678',
                    filled: true,
                    fillColor: const Color(0xFFF7F7FB),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(
                        color: Color(0xFF0084FF),
                        width: 1.5,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                if (_hasPhoneNumber)
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: OutlinedButton(
                      onPressed: _isSaving ? null : () => _submit(null),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.red,
                        side: const BorderSide(color: Color(0xFFE0E0E0)),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: _isSaving
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text('전화번호 삭제'),
                    ),
                  ),
                if (_hasPhoneNumber) const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: ElevatedButton(
                    onPressed: _isSaving
                        ? null
                        : () => _submit(_controller.text),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0084FF),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: _isSaving
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Text(
                            '저장',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 17,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}