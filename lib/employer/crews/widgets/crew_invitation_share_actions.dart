import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class CrewInvitationShareActions extends StatelessWidget {
  const CrewInvitationShareActions({
    super.key,
    required this.onCopyLink,
    required this.onShareToKakao,
  });

  final Future<void> Function() onCopyLink;
  final Future<void> Function() onShareToKakao;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton(
            onPressed: onCopyLink,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF0084FF),
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            child: const Text(
              '초대 링크 복사',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton.icon(
            onPressed: onShareToKakao,
            icon: SvgPicture.asset(
              'assets/images/logo/kakao.svg',
              width: 20,
              height: 20,
            ),
            label: const Text(
              '카카오톡으로 초대',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF111111),
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFFE200),
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
