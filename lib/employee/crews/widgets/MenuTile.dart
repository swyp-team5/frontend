import 'package:flutter/material.dart';

/// 신청서 화면에서 사용하는 공용 메뉴 타일 위젯
///
/// 기존 EApplicationFormPage 내부의 private `_MenuTile`을
/// 별도 파일로 분리하여 재사용 가능하도록 만들었습니다.
class MenuTile extends StatelessWidget {
  final String title;
  final String? subtitle;

  final Widget? trailing;
  final String? value;

  final bool hasArrow;
  final VoidCallback onTap;
  final Color? valueColor;
  final FontWeight? valueWeight;

  const MenuTile({
    super.key,
    required this.title,
    this.subtitle,
    this.trailing,
    this.value,
    required this.onTap,
    this.hasArrow = false,
    this.valueColor,
    this.valueWeight,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        height: 72,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Row(
          children: [
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            trailing ??
                Text(
                  value ?? "",
                  style: TextStyle(
                    color: valueColor ?? const Color(0xff8F8F8F),
                    fontSize: 16,
                    fontWeight: valueWeight ?? FontWeight.w400,
                  ),
                ),
            if (hasArrow)
              const Padding(
                padding: EdgeInsets.only(left: 6),
                child: Icon(
                  Icons.chevron_right,
                  color: Color(0xffBDBDBD),
                ),
              ),
          ],
        ),
      ),
    );
  }
}