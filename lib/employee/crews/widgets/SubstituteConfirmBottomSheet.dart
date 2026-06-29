import 'package:flutter/material.dart';

import '../../../common/employee/ESubstitueAccept.dart';

class SubstituteConfirmBottomSheet extends StatelessWidget {
  const SubstituteConfirmBottomSheet({
    super.key,
    required this.myName,
    required this.myDate,
    required this.myTime,

    required this.workerName,
    required this.workerDate,
    required this.workerTime,

    required this.reason,
    required this.onConfirm,
  });

  final String myName;
  final String myDate;
  final String myTime;

  final String workerName;
  final String workerDate;
  final String workerTime;

  final String reason;

  final VoidCallback onConfirm;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(28),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 48,
              height: 6,
              decoration: BoxDecoration(
                color: const Color(0xffD9D9D9),
                borderRadius: BorderRadius.circular(100),
              ),
            ),

            const SizedBox(height: 24),

            const Text(
              "이대로 신청하시겠습니까?",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),

            const SizedBox(height: 8),

            const Text(
              "한 번 전송된 신청서는 이후 수정이 불가능해요",
              style: TextStyle(
                color: Color(0xff767676),
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),

            const SizedBox(height: 10),

            const Divider(
              height: 1,
              color: Color(0xFFF1F1F5),
            ),

            const SizedBox(height: 10),

            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xffF5F5F9),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                children: [

                  /// 상단 정보
                  Row(
                    children: [

                      /// 내 근무
                      Expanded(
                        child: Column(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xffE6F3FF),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                myName,
                                style: const TextStyle(
                                  color: Color(0xff0063BF),
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),

                            const SizedBox(height: 10),

                            Text(
                              myDate,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),

                            const SizedBox(height: 6),

                            Text(
                              myTime,
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w500,
                                color: Color(0xff505050),
                              ),
                            ),
                          ],
                        ),
                      ),

                      /// 단방향 화살표
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 18),
                        child: Icon(
                          Icons.arrow_forward,
                          size: 34,
                          color: Color(0xff8F8F8F),
                        ),
                      ),

                      /// 대타 근무자
                      Expanded(
                        child: Column(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xffCDFFD4),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                workerName,
                                style: const TextStyle(
                                  color: Color(0xff019A4E),
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),

                            const SizedBox(height: 10),

                            Text(
                              workerDate,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),

                            const SizedBox(height: 6),

                            Text(
                              workerTime,
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w500,
                                color: Color(0xff505050),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 22),

                  const Divider(),

                  const SizedBox(height: 18),

                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      children: [
                        const Text(
                          "대타 사유",
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: Color(0xff767676),
                          ),
                        ),

                        const Spacer(),

                        Text(
                          reason,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 26),

            Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 56,
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide.none,
                      ),
                      child: const Text(
                        "취소",
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(width: 12),

                Expanded(
                  child: SizedBox(
                    height: 56,
                    child: ElevatedButton(
                      onPressed: () {
                        onConfirm();

                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const ESubstituteAccept(),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xff0084FF),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text(
                        "확정",
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}