import 'package:flutter/material.dart';

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
        Expanded(
          child: InkWell(
            onTap: () => onChanged(false),
            child: Container(
              height: 52,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: !isSubstitute
                        ? Colors.black
                        : const Color(0xffE9E9EE),
                    width: !isSubstitute ? 2 : 1,
                  ),
                ),
              ),
              child: Text(
                "교대",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: !isSubstitute ? Colors.black : Colors.grey,
                ),
              ),
            ),
          ),
        ),
        Expanded(
          child: InkWell(
            onTap: () => onChanged(true),
            child: Container(
              height: 52,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: isSubstitute
                        ? Colors.black
                        : const Color(0xffE9E9EE),
                    width: isSubstitute ? 2 : 1,
                  ),
                ),
              ),
              child: Text(
                "대타",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: isSubstitute ? Colors.black : Colors.grey,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}