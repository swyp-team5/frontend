import 'package:flutter/material.dart';

/// 신청서 화면 상단의 "교대 / 대타" 토글 탭바.
class ExchangeSubstituteTabBar extends StatelessWidget {
  final bool isSubstitute;
  final ValueChanged<bool> onChanged;

  const ExchangeSubstituteTabBar({
    super.key,
    required this.isSubstitute,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _Tab(
          label: "교대",
          selected: !isSubstitute,
          onTap: () => onChanged(false),
        ),
        _Tab(
          label: "대타",
          selected: isSubstitute,
          onTap: () => onChanged(true),
        ),
      ],
    );
  }
}

class _Tab extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _Tab({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        child: Container(
          height: 52,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: selected ? Colors.black : const Color(0xffE9E9EE),
                width: selected ? 2 : 1,
              ),
            ),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: selected ? Colors.black : Colors.grey,
            ),
          ),
        ),
      ),
    );
  }
}