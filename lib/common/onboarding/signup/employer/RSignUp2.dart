import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/signup_provider.dart';
import 'RSignUp3.dart';

class RSignUp2 extends ConsumerStatefulWidget {
  const RSignUp2({super.key});

  @override
  ConsumerState<RSignUp2> createState() => _RSignUp2State();
}

class _RSignUp2State extends ConsumerState<RSignUp2> {
  final TextEditingController _storeNameController =
  TextEditingController();

  bool get isEnabled =>
      _storeNameController.text.trim().isNotEmpty;

  @override
  void initState() {
    super.initState();

    _storeNameController.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _storeNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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

              //----------------------------------
              // 뒤로가기
              //----------------------------------

              GestureDetector(
                onTap: () {
                  Navigator.pop(context);
                },
                child: const Icon(
                  Icons.arrow_back_ios_new,
                  size: 22,
                ),
              ),

              const SizedBox(height: 64),

              //----------------------------------
              // 제목
              //----------------------------------

              const Text(
                "매장 이름을\n입력해주세요",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w600,
                  height: 1.5,
                ),
              ),

              const SizedBox(height: 48),

              //----------------------------------
              // 라벨
              //----------------------------------

              const Text(
                "매장 이름",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),

              const SizedBox(height: 16),

              //----------------------------------
              // 입력창
              //----------------------------------

              SizedBox(
                height: 68,
                child: TextField(
                  controller: _storeNameController,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                  ),
                  decoration: InputDecoration(
                    hintText: "예시) 스타벅스 강남점",
                    hintStyle: const TextStyle(
                      color: Color(0xff767676),
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                    filled: true,
                    fillColor: _storeNameController.text.isEmpty
                        ? const Color(0xffF5F5F9)
                        : Colors.white,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 20,
                    ),
                    border: OutlineInputBorder(
                      borderRadius:
                      BorderRadius.circular(16),
                      borderSide: BorderSide.none,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius:
                      BorderRadius.circular(16),
                      borderSide: BorderSide(
                        color: _storeNameController
                            .text.isNotEmpty
                            ? const Color(0xffC6CBD2)
                            : Colors.transparent,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius:
                      BorderRadius.circular(16),
                      borderSide: const BorderSide(
                        color: Color(0xff0084FF),
                        width: 1.5,
                      ),
                    ),
                  ),
                ),
              ),

              const Spacer(),

              //----------------------------------
              // 다음 버튼
              //----------------------------------

              SizedBox(
                width: double.infinity,
                height: 58,
                child: ElevatedButton(
                  onPressed: isEnabled
                      ? () {
                    ref
                        .read(signupProvider.notifier)
                        .setWorkPlaceName(
                      _storeNameController.text.trim(),
                    );

                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const RSignUp3(),
                      ),
                    );
                  }
                      : null,
                  style: ElevatedButton.styleFrom(
                    elevation: 0,
                    backgroundColor:
                    const Color(0xff0084FF),
                    disabledBackgroundColor:
                    const Color(0xff80C1FF),
                    disabledForegroundColor:
                    Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius:
                      BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    "다음",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
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