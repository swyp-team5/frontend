import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'AgreementPage.dart';

class RoleSelectDialog extends StatelessWidget {
  const RoleSelectDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20),
      alignment: Alignment.bottomCenter,
      child: Container(
        padding: const EdgeInsets.fromLTRB(24, 12, 24, 28),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(28),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 56,
              height: 6,
              decoration: BoxDecoration(
                color: const Color(0xffD9D9D9),
                borderRadius: BorderRadius.circular(100),
              ),
            ),

            const SizedBox(height: 40),

            const Text(
              "매장을 운영하는\n사장님인가요?",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                height: 1.5,
              ),
            ),

            const SizedBox(height: 36),

            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  elevation: 0,
                  backgroundColor: const Color(0xff0084FF),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onPressed: () {
                  // TODO : 사장님 회원가입 페이지 이동
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const AgreementPage(
                        role: UserRole.owner,
                      ),
                    ),
                  );
                },
                child: const Text(
                  "사장님이에요",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 16),

            TextButton(
              onPressed: () {
                // TODO : 직원 회원가입 페이지 이동
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const AgreementPage(
                      role: UserRole.worker,
                    ),
                  ),
                );
              },
              style: TextButton.styleFrom(
                padding: EdgeInsets.zero,
                foregroundColor: Colors.black,
              ),
              child: const Text(
                "직원이에요",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Colors.black,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}