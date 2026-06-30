import 'package:flutter/material.dart';
import '../../../../employer/home/RHomePage.dart';
import 'AddressSearchPage.dart';

class RSignUp3 extends StatefulWidget {
  const RSignUp3({super.key});

  @override
  State<RSignUp3> createState() => _RSignUp2State();
}

class _RSignUp2State extends State<RSignUp3> {
  final TextEditingController zonecodeController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController detailAddressController = TextEditingController();

  bool isPrivacyChecked = false;

  @override
  Widget build(BuildContext context) {
    final bool isFormValid =
        addressController.text.isNotEmpty &&
            detailAddressController.text.isNotEmpty;
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 15,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 24),

              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: const Icon(
                  Icons.arrow_back_ios_new,
                  size: 22,
                ),
              ),

              const SizedBox(height: 64),

              const Text(
                "매장 주소를\n입력해주세요",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w600,
                  height: 1.5,
                ),
              ),

              const SizedBox(height: 48),

              const Text(
                '매장 주소',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),

              const SizedBox(height: 16),

              /// 우편번호 Row
              Row(
                children: [
                  Expanded(
                    child: _buildInputContainer(
                      child: TextField(
                        controller: zonecodeController,
                        readOnly: true,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.black,
                        ),
                        decoration: const InputDecoration(
                          hintText: '우편번호',
                          hintStyle: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFF505050),
                          ),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(horizontal: 16),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  SizedBox(
                    height: 56,
                    child: ElevatedButton(
                      onPressed: () async {
                        final result = await Navigator.push<Map<String, dynamic>>(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const AddressSearchPage(),
                          ),
                        );

                        if (result != null) {
                          setState(() {
                            zonecodeController.text = result['zonecode'] ?? '';
                            addressController.text = result['roadAddress'] ?? '';
                          });
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFEBF5FF),
                        foregroundColor: const Color(0xFF007AFF),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                      ),
                      child: const Text(
                        '주소 찾기',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              /// 주소 입력칸
              _buildInputContainer(
                child: TextField(
                  controller: addressController,
                  readOnly: true,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                  decoration: const InputDecoration(
                    hintText: '주소',
                    hintStyle: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF505050),
                    ),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(horizontal: 16),
                  ),
                ),
              ),

              const SizedBox(height: 12),

              /// 상세 주소 입력칸
              _buildInputContainer(
                child: TextField(
                  controller: detailAddressController,
                  onChanged: (_) {
                    setState(() {});
                  },
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                  decoration: const InputDecoration(
                    hintText: '상세 주소',
                    hintStyle: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF505050),
                    ),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(horizontal: 16),
                  ),
                ),
              ),

              const Spacer(),

              /// 다음 버튼
              SizedBox(
                width: double.infinity,
                height: 56,

                child: ElevatedButton(
                  onPressed: isFormValid
                      ? () {
                    _showPrivacyAgreement();
                  }
                      : null,

                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                    const Color(0xFF007AFF),

                    disabledBackgroundColor:
                    const Color(0xFF80C2FF),

                    elevation: 0,

                    shape: RoundedRectangleBorder(
                      borderRadius:
                      BorderRadius.circular(12),
                    ),
                  ),

                  child: const Text(
                    '다음',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInputContainer({required Widget child}) {
    return Container(
      height: 56,
      decoration: BoxDecoration(
        color: const Color(0xFFF7F8FA),
        borderRadius: BorderRadius.circular(12),
      ),
      child: child,
    );
  }

  void _showPrivacyAgreement() {
    isPrivacyChecked = false;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              margin: const EdgeInsets.all(18),
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.all(Radius.circular(28)),
              ),
              child: SafeArea(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 50,
                        height: 5,
                        decoration: BoxDecoration(
                          color: Colors.black12,
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                    const SizedBox(height: 30),
                    const Center(
                      child: Text(
                        '서비스 이용을 위해 동의가 필요해요',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(height: 25),
                    InkWell(
                      onTap: () {
                        setModalState(() {
                          isPrivacyChecked = !isPrivacyChecked;
                        });
                      },
                      child: Row(
                        children: [
                          Expanded(
                            child: InkWell(
                              onTap: () {
                                setModalState(() {
                                  isPrivacyChecked = !isPrivacyChecked;
                                });
                              },
                              child: Row(
                                children: [
                                  Container(
                                    width: 22,
                                    height: 22,
                                    decoration: BoxDecoration(
                                      color: isPrivacyChecked
                                          ? const Color(0xff0084FF)
                                          : Colors.white,
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: isPrivacyChecked
                                            ? const Color(0xff0084FF)
                                            : Colors.black,
                                      ),
                                    ),
                                    child: isPrivacyChecked
                                        ? const Icon(
                                      Icons.check,
                                      size: 14,
                                      color: Colors.white,
                                    )
                                        : null,
                                  ),

                                  const SizedBox(width: 12),

                                  const Text(
                                    '[필수] 개인정보보호의무',
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),

                          IconButton(
                            onPressed: () {
                              // TODO : 개인정보보호의무 상세 약관 페이지 또는 BottomSheet
                            },
                            icon: const Icon(Icons.chevron_right),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 30),
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: isPrivacyChecked
                            ? () {

                          Navigator.push(
                            context,

                            MaterialPageRoute(
                              builder: (_) =>
                              const RHomePage(),
                            ),
                          );
                          // 회원가입 완료 로직 추가 가능
                        }
                            : null,
                        style: ElevatedButton.styleFrom(
                          elevation: 0,
                          backgroundColor: const Color(0xff0084FF),
                          disabledBackgroundColor: const Color(0xff80C1FF),
                          disabledForegroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text(
                          '동의 후 서비스 시작하기',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
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
      },
    );
  }
}
