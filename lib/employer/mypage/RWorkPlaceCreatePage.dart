import 'package:flutter/material.dart';

import '../../common/onboarding/signup/employer/AddressSearchPage.dart';
import 'api/work_place_api.dart';

class RWorkPlaceCreatePage extends StatefulWidget {
  const RWorkPlaceCreatePage({super.key});

  @override
  State<RWorkPlaceCreatePage> createState() => _RWorkPlaceCreatePageState();
}

class _RWorkPlaceCreatePageState extends State<RWorkPlaceCreatePage> {
  final WorkPlaceApi _api = WorkPlaceApi();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _zoneCodeController = TextEditingController();
  final TextEditingController _roadAddressController = TextEditingController();
  final TextEditingController _detailAddressController =
      TextEditingController();
  final TextEditingController _phoneController = TextEditingController();

  String? _selectedSize;
  bool _isSaving = false;

  final List<Map<String, String>> _sizes = const [
    {'label': '1~4명', 'value': 'ONE_TO_FOUR'},
    {'label': '5~9명', 'value': 'FIVE_TO_NINE'},
    {'label': '10~17명', 'value': 'TEN_TO_SEVENTEEN'},
    {'label': '18~23명', 'value': 'EIGHTEEN_TO_TWENTY_THREE'},
  ];

  bool get _isFormValid {
    return _selectedSize != null &&
        _nameController.text.trim().isNotEmpty &&
        _roadAddressController.text.trim().isNotEmpty;
  }

  @override
  void initState() {
    super.initState();
    _nameController.addListener(_refresh);
    _roadAddressController.addListener(_refresh);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _zoneCodeController.dispose();
    _roadAddressController.dispose();
    _detailAddressController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  void _refresh() {
    if (mounted) {
      setState(() {});
    }
  }

  Future<void> _selectAddress() async {
    final result = await Navigator.push<Map<String, dynamic>>(
      context,
      MaterialPageRoute(builder: (_) => const AddressSearchPage()),
    );

    if (result == null) {
      return;
    }

    if (!mounted) {
      return;
    }

    setState(() {
      _zoneCodeController.text = result['zonecode']?.toString() ?? '';
      _roadAddressController.text = result['roadAddress']?.toString() ?? '';
    });
  }

  Future<void> _save() async {
    final phone = WorkPlaceApi.normalizePhoneNumber(_phoneController.text);
    if (phone != null && (phone.length < 8 || phone.length > 11)) {
      _showMessage('전화번호는 숫자 8~11자리로 입력해주세요.');
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      final created = await _api.createWorkPlace(
        WorkPlaceCreateRequest(
          size: _selectedSize!,
          name: _nameController.text.trim(),
          roadAddress: _roadAddressController.text.trim(),
          detailAddress: _detailAddressController.text.trim().isEmpty
              ? null
              : _detailAddressController.text.trim(),
          phoneNumber: _phoneController.text,
        ),
      );

      if (!mounted) {
        return;
      }

      Navigator.pop(context, created);
    } catch (e) {
      _showMessage(_messageFromError(e, '매장 추가에 실패했어요.'));
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
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
      backgroundColor: Colors.white,
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
                        '매장 추가',
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
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 34, 20, 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _sectionTitle('매장 규모'),
                    const SizedBox(height: 12),
                    ..._sizes.map((size) {
                      final selected = _selectedSize == size['value'];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(12),
                          onTap: () {
                            setState(() {
                              _selectedSize = size['value'];
                            });
                          },
                          child: Container(
                            height: 56,
                            padding: const EdgeInsets.symmetric(horizontal: 18),
                            decoration: BoxDecoration(
                              color: selected
                                  ? Colors.white
                                  : const Color(0xFFF7F7FB),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: selected
                                    ? const Color(0xFF0084FF)
                                    : Colors.transparent,
                                width: 1.5,
                              ),
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    size['label']!,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                                if (selected)
                                  const Icon(
                                    Icons.check_circle,
                                    color: Color(0xFF0084FF),
                                  ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }),
                    const SizedBox(height: 24),
                    _sectionTitle('매장 정보'),
                    const SizedBox(height: 12),
                    _inputField(
                      controller: _nameController,
                      label: '매장 이름',
                      hint: '예시) 착착 강남점',
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: _inputField(
                            controller: _zoneCodeController,
                            label: '우편번호',
                            hint: '주소 검색',
                            readOnly: true,
                          ),
                        ),
                        const SizedBox(width: 10),
                        SizedBox(
                          height: 56,
                          child: ElevatedButton(
                            onPressed: _selectAddress,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFEBF5FF),
                              foregroundColor: const Color(0xFF007AFF),
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: const Text('주소 찾기'),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    _inputField(
                      controller: _roadAddressController,
                      label: '도로명 주소',
                      hint: '주소를 선택해주세요',
                      readOnly: true,
                    ),
                    const SizedBox(height: 12),
                    _inputField(
                      controller: _detailAddressController,
                      label: '상세 주소',
                      hint: '예시) 3층',
                    ),
                    const SizedBox(height: 12),
                    _inputField(
                      controller: _phoneController,
                      label: '매장 전화번호',
                      hint: '선택 입력',
                      keyboardType: TextInputType.phone,
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
              child: SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _isFormValid && !_isSaving ? _save : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0084FF),
                    disabledBackgroundColor: const Color(0xFF80C1FF),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    _isSaving ? '저장 중...' : '매장 추가',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
    );
  }

  Widget _inputField({
    required TextEditingController controller,
    required String label,
    required String hint,
    bool readOnly = false,
    TextInputType? keyboardType,
  }) {
    return TextField(
      controller: controller,
      readOnly: readOnly,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        filled: true,
        fillColor: const Color(0xFFF7F7FB),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF0084FF), width: 1.5),
        ),
      ),
    );
  }
}
