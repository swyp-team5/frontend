
import 'package:flutter/material.dart';

import 'RSignUp2.dart';

class RSignUp1 extends StatefulWidget {

  const RSignUp1({super.key});

  @override
  State<RSignUp1> createState() =>
      _RSignUp1State();
}

class _RSignUp1State
    extends State<RSignUp1> {

  int? selectedIndex;

  final List<String> storeSizes = [
    '1-4명',
    '5-9명',
    '10-19명',
    '20명 이상',
  ];

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),

      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 18,
          ),

          child: Column(
            crossAxisAlignment:
            CrossAxisAlignment.start,

            children: [

              const SizedBox(height: 30),

              /// 뒤로가기
              GestureDetector(
                onTap: () {
                  Navigator.pop(context);
                },

                child: const Icon(
                  Icons.arrow_back_ios_new,
                  size: 25,
                ),
              ),

              const SizedBox(height: 30),

              const Text(
                '직원과 알바 모두 포함한\n매장 규모를 알려주세요',

                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  height: 1.4,
                ),
              ),

              const SizedBox(height: 40),

              Expanded(
                child: ListView.separated(
                  itemCount: storeSizes.length,

                  separatorBuilder:
                      (_, __) =>
                  const SizedBox(height: 12),

                  itemBuilder:
                      (context, index) {

                    final isSelected =
                        selectedIndex == index;

                    return GestureDetector(
                      onTap: () {

                        setState(() {
                          selectedIndex = index;
                        });
                      },

                      child: Container(
                        height: 72,

                        padding:
                        const EdgeInsets.symmetric(
                          horizontal: 20,
                        ),

                        decoration: BoxDecoration(
                          color: isSelected
                              ? const Color(
                            0xFFD9EEFF,
                          )
                              : const Color(
                            0xFFE7E7EC,
                          ),

                          borderRadius:
                          BorderRadius.circular(
                            14,
                          ),

                          border: isSelected
                              ? Border.all(
                            color: Colors.black,
                          )
                              : null,
                        ),

                        child: Row(
                          children: [

                            Text(
                              storeSizes[index],

                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight:
                                FontWeight.w700,
                              ),
                            ),

                            const Spacer(),

                            if (isSelected)
                              Container(
                                width: 24,
                                height: 24,

                                decoration:
                                const BoxDecoration(
                                  color: Colors.black,
                                  shape:
                                  BoxShape.circle,
                                ),

                                child: const Icon(
                                  Icons.check,
                                  color: Colors.white,
                                  size: 16,
                                ),
                              ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),

              SizedBox(
                width: double.infinity,
                height: 60,

                child: ElevatedButton(
                  onPressed: selectedIndex == null
                      ? null
                      : () {

                    /// 다음 페이지 이동
                    Navigator.push(
                      context,

                      MaterialPageRoute(
                        builder: (_) =>
                        const RSignUp2(),
                      ),
                    );
                  },

                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,

                    disabledBackgroundColor:
                    Colors.grey.shade400,

                    shape: RoundedRectangleBorder(
                      borderRadius:
                      BorderRadius.circular(14),
                    ),
                  ),

                  child: const Text(
                    '다음',

                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight:
                      FontWeight.w600,
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