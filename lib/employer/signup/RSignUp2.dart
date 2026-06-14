import 'package:flutter/material.dart';
import '../home/RHomePage.dart';
import 'AddressSearchPage.dart';

class RSignUp2 extends StatefulWidget {
  const RSignUp2({super.key});

  @override
  State<RSignUp2> createState() => _RSignUp2State();
}

class _RSignUp2State extends State<RSignUp2> {
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
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 30),

              /// 뒤로가기
              GestureDetector(
                onTap: () {
                  Navigator.pop(context);
                },
                child: const Icon(
                  Icons.arrow_back_ios_new,
                  size: 24,
                  color: Colors.black,
                ),
              ),

              const SizedBox(height: 30),

              const Text(
                '매장 주소를\n입력해주세요',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                  height: 1.2,
                ),
              ),

              const SizedBox(height: 40),

              const Text(
                '매장 주소',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
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
                        decoration: const InputDecoration(
                          hintText: '우편번호',
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(horizontal: 16),
                          hintStyle: TextStyle(color: Color(0xFFAEB0B6)),
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
                  decoration: const InputDecoration(
                    hintText: '주소',
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(horizontal: 16),
                    hintStyle: TextStyle(color: Color(0xFFAEB0B6)),
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
                  decoration: const InputDecoration(
                    hintText: '상세 주소',
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(horizontal: 16),
                    hintStyle: TextStyle(color: Color(0xFFAEB0B6)),
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
                    const Text(
                      '서비스 이용을 위해 동의가 필요해요.',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
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
                          Container(
                            width: 22,
                            height: 22,
                            decoration: BoxDecoration(
                              color: isPrivacyChecked ? Colors.black : Colors.white,
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.black),
                            ),
                            child: isPrivacyChecked
                                ? const Icon(Icons.check, size: 14, color: Colors.white)
                                : null,
                          ),
                          const SizedBox(width: 12),
                          const Expanded(
                            child: Text(
                              '[필수] 개인정보보호의무',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          const Icon(Icons.chevron_right),
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
                          backgroundColor: Colors.black,
                          disabledBackgroundColor: Colors.grey.shade300,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          '동의 후 서비스 시작하기',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
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
