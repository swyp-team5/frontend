import 'package:flutter/material.dart';

import 'Agree1BottomSheet.dart';
import 'Agree2BottomSheet.dart';
import 'Agree3BottomSheet.dart';

enum UserRole {
  owner,
  worker,
}

class AgreementPage extends StatefulWidget {
  final UserRole role;

  const AgreementPage({
    super.key,
    required this.role,
  });

  @override
  State<AgreementPage> createState() => _AgreementPageState();
}

class _AgreementPageState extends State<AgreementPage> {
  bool allAgree = false;

  bool ageAgree = false;
  bool serviceAgree = false;
  bool privacyAgree = false;
  bool marketingAgree = false;

  bool get requiredAgree =>
      ageAgree && serviceAgree && privacyAgree;

  void updateAllAgree() {
    allAgree =
        ageAgree &&
            serviceAgree &&
            privacyAgree &&
            marketingAgree;
  }

  void toggleAll(bool value) {
    setState(() {
      allAgree = value;

      ageAgree = value;
      serviceAgree = value;
      privacyAgree = value;
      marketingAgree = value;
    });
  }

  Widget agreementItem({
    required bool value,
    required ValueChanged<bool> onChanged,
    required String title,
    bool showArrow = false,
    VoidCallback? onArrowTap,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 14),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => onChanged(!value),
            child: Container(
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: value
                      ? const Color(0xff0084FF)
                      : const Color(0xffD9D9D9),
                  width: 1.5,
                ),
                color: value
                    ? const Color(0xff0084FF)
                    : Colors.white,
              ),
              child: value
                  ? const Icon(
                Icons.check,
                color: Colors.white,
                size: 18,
              )
                  : null,
            ),
          ),

          const SizedBox(width: 12),

          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w500,
                color: Color(0xFF505050),
              ),
            ),
          ),

          if (showArrow)
            IconButton(
              onPressed: onArrowTap,
              icon: const Icon(
                Icons.arrow_forward_ios,
                size: 18,
              ),
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 22),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 24),

              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: const Icon(Icons.arrow_back_ios_new),
              ),

              const SizedBox(height: 70),

              const Text(
                "서비스 이용을 위해\n동의가 필요해요",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w600,
                  height: 1.35,
                ),
              ),

              const SizedBox(height: 36),

              //-----------------------------------
              // 전체 동의
              //-----------------------------------
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 18, vertical: 18),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFE5E5EC)),
                ),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () => toggleAll(!allAgree),
                      child: Container(
                        width: 30,
                        height: 30,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: allAgree
                                ? const Color(0xff0084FF)
                                : const Color(0xffD9D9D9),
                            width: 1.5,
                          ),
                          color: allAgree
                              ? const Color(0xff0084FF)
                              : Colors.white,
                        ),
                        child: allAgree
                            ? const Icon(
                          Icons.check,
                          color: Colors.white,
                          size: 18,
                        )
                            : null,
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Text(
                      "필수 및 선택 동의 모두 선택",
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF767676),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 28),

              agreementItem(
                value: ageAgree,
                title: "[필수] 만 14세 이상입니다.",
                onChanged: (value) {
                  setState(() {
                    ageAgree = value;
                    updateAllAgree();
                  });
                },
              ),

              agreementItem(
                value: serviceAgree,
                title: "[필수] 서비스 이용약관 동의",
                showArrow: true,
                onArrowTap: () {
                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    backgroundColor: Colors.transparent,
                    builder: (_) => const Agree1BottomSheet(),
                  );
                },
                onChanged: (value) {
                  setState(() {
                    serviceAgree = value;
                    updateAllAgree();
                  });
                },
              ),

              agreementItem(
                value: privacyAgree,
                title: "[필수] 개인정보 수집 및 이용 동의",
                showArrow: true,
                onArrowTap: () {
                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    backgroundColor: Colors.transparent,
                    builder: (_) => const Agree2BottomSheet(),
                  );
                },
                onChanged: (value) {
                  setState(() {
                    privacyAgree = value;
                    updateAllAgree();
                  });
                },
              ),

              agreementItem(
                value: marketingAgree,
                title: "[선택] 마케팅 정보 수신 동의",
                showArrow: true,
                onArrowTap: () {
                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    backgroundColor: Colors.transparent,
                    builder: (_) => const Agree3BottomSheet(),
                  );
                },
                onChanged: (value) {
                  setState(() {
                    marketingAgree = value;
                    updateAllAgree();
                  });
                },
              ),

              const Spacer(),

              //-----------------------------------
              // 완료 버튼
              //-----------------------------------
              SizedBox(
                width: double.infinity,
                height: 58,
                child: ElevatedButton(
                  onPressed: requiredAgree
                      ? () {
                    if (widget.role == UserRole.owner) {
                      // 사장님 → 매장 설정 페이지
                      Navigator.pushReplacementNamed(
                          context, "/storeSetup");
                    } else {
                      // 직원 → 홈
                      Navigator.pushReplacementNamed(
                          context, "/home");
                    }
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
                    "동의 후 서비스 시작하기",
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