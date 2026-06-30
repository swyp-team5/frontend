import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'RoleSelectDialog.dart';

class CommonSignUpPage extends StatefulWidget {
  const CommonSignUpPage({super.key});

  @override
  State<CommonSignUpPage> createState() => _CommonSignUpPageState();
}

class _CommonSignUpPageState extends State<CommonSignUpPage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();

  int currentStep = 0;

  bool get isEnabled {
    if (currentStep == 0) {
      return _nameController.text.trim().isNotEmpty;
    } else {
      final phone =
      _phoneController.text.replaceAll(RegExp(r'[^0-9]'), '');
      return phone.length == 11;
    }
  }

  @override
  void initState() {
    super.initState();

    _nameController.addListener(() {
      setState(() {});
    });

    _phoneController.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 24),

              GestureDetector(
                onTap: () {
                  if (currentStep == 1) {
                    setState(() {
                      currentStep = 0;
                    });
                  } else {
                    Navigator.pop(context);
                  }
                },
                child: const Icon(
                  Icons.arrow_back_ios_new,
                  size: 22,
                ),
              ),

              const SizedBox(height: 72),

              const Text(
                "내 정보를 입력해주세요",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w600,
                ),
              ),

              const SizedBox(height: 40),

              if (currentStep == 0) ...[
                //----------------------------------
                // 이름 입력
                //----------------------------------

                const Text(
                  "이름",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),

                const SizedBox(height: 16),

                SizedBox(
                  height: 65,
                  child: TextField(
                    controller: _nameController,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                    ),
                    decoration: InputDecoration(
                      hintText: "이름을 입력해주세요",
                      filled: true,
                      fillColor: _nameController.text.isEmpty
                          ? const Color(0xffF1F1F5)
                          : Colors.white,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 16,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: _nameController.text.isNotEmpty
                              ? const Color(0xffC6CBD2)
                              : Colors.transparent,
                          width: 1,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(
                          color: Color(0xff0084FF),
                          width: 1.5,
                        ),
                      ),
                    ),
                  ),
                ),
              ] else ...[
                //----------------------------------
                // 전화번호
                //----------------------------------

                const Text(
                  "전화번호",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),

                const SizedBox(height: 16),

                SizedBox(
                  height: 70,
                  child: TextField(
                    controller: _phoneController,
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      PhoneNumberFormatter(),
                    ],
                    decoration: InputDecoration(
                      hintText: "전화번호를 입력해주세요",
                      filled: true,
                      fillColor: _phoneController.text
                          .replaceAll(RegExp(r'[^0-9]'), '')
                          .length == 11
                          ? Colors.white
                          : const Color(0xffF5F5F9),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 22,
                        vertical: 22,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide(
                          color: _nameController.text.isNotEmpty
                              ? const Color(0xffC6CBD2)
                              : Colors.transparent,
                          width: 1,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(
                          color: Color(0xff0084FF),
                          width: 1.5,
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 32),

                //----------------------------------
                // 이름
                //----------------------------------

                const Text(
                  "이름",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),

                const SizedBox(height: 16),

                SizedBox(
                  height: 70,
                  child: TextField(
                    controller: _nameController,
                    readOnly: true,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                    ),
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 22,
                        vertical: 22,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: _phoneController.text
                              .replaceAll(RegExp(r'[^0-9]'), '')
                              .length ==
                              11
                              ? const Color(0xffC6CBD2)
                              : Colors.transparent,
                          width: 1,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ],

              const Spacer(),

              SizedBox(
                width: double.infinity,
                height: 58,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    elevation: 0,
                    backgroundColor: const Color(0xff0084FF),
                    disabledBackgroundColor: const Color(0xff80C1FF),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onPressed: isEnabled
                      ? () {
                    if (currentStep == 0) {
                      setState(() {
                        currentStep = 1;
                      });
                    } else {
                      showDialog(
                        context: context,
                        barrierDismissible: true,
                        barrierColor: Colors.black.withOpacity(0.25),
                        builder: (context) => const RoleSelectDialog(),
                      );
                    }
                  }
                      : null,
                  child: const Text(
                    "다음",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}

class PhoneNumberFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue,
      TextEditingValue newValue,
      ) {
    String numbers = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');

    if (numbers.length > 11) {
      numbers = numbers.substring(0, 11);
    }

    String text = '';

    if (numbers.length <= 3) {
      text = numbers;
    } else if (numbers.length <= 7) {
      text = '${numbers.substring(0, 3)}-${numbers.substring(3)}';
    } else {
      text =
      '${numbers.substring(0, 3)}-${numbers.substring(3, 7)}-${numbers.substring(7)}';
    }

    return TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(
        offset: text.length,
      ),
    );
  }
}