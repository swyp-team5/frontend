
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/signup_request.dart';
import '../../providers/signup_provider.dart';
import 'RSignUp2.dart';

class RSignUp1 extends ConsumerStatefulWidget {
  const RSignUp1({super.key});

  @override
  ConsumerState<RSignUp1> createState() => _RSignUp1State();
}

class _RSignUp1State extends ConsumerState<RSignUp1> {

  int? selectedIndex;

  final List<String> storeSizes = [
    '1~4명',
    '5~9명',
    '10~17명',
    '18~23명',
    '24명 이상',
  ];

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: Colors.white,

      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 24),
              /// 뒤로가기
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

              const Text(
                "직원과 알바 모두 포함한\n매장 규모를 알려주세요",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w600,
                  height: 1.5,
                ),
              ),

              const SizedBox(height: 40),

              Expanded(
                child: ListView.separated(
                  itemCount: storeSizes.length,

                  separatorBuilder:
                      (_, __) =>
                  const SizedBox(height: 10),

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
                        height: 60,
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        alignment: Alignment.centerLeft,
                        decoration: BoxDecoration(
                          color: isSelected
                              ? Colors.white
                              : const Color(0xffF7F7FB),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isSelected
                                ? const Color(0xFFC6CBD2)
                                : Colors.transparent,
                            width: 1.5,
                          ),
                        ),
                        child: Text(
                          storeSizes[index],
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                            color: isSelected
                                ? Colors.black
                                : const Color(0xff505050),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),

              SizedBox(
                width: double.infinity,
                height: 58,
                child: ElevatedButton(
                  onPressed: selectedIndex == null
                      ? null
                      : () {
                    final notifier = ref.read(signupProvider.notifier);

                    switch (selectedIndex) {
                      case 0:
                        notifier.setWorkPlaceSize(WorkPlaceSize.ONE_TO_FOUR);
                        break;

                      case 1:
                        notifier.setWorkPlaceSize(WorkPlaceSize.FIVE_TO_NINE);
                        break;

                      case 2:
                        notifier.setWorkPlaceSize(WorkPlaceSize.TEN_TO_SEVENTEEN);
                        break;

                      case 3:
                        notifier.setWorkPlaceSize(
                            WorkPlaceSize.EIGHTEEN_TO_TWENTY_THREE);
                        break;

                      case 4:
                        notifier.setWorkPlaceSize(
                            WorkPlaceSize.TWENTY_FOUR_OR_MORE);
                        break;
                    }

                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const RSignUp2(),
                      ),
                    );
                  },
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
                    "다음",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
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