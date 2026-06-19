import 'package:flutter/material.dart';

class CounterBox extends StatelessWidget {
  const CounterBox({
    super.key,
    required this.value,
    required this.onMinus,
    required this.onPlus,
    this.title,
    this.minValue = 0,
  });

  final String? title;
  final int value;
  final VoidCallback? onMinus;
  final VoidCallback? onPlus;
  final int minValue;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (title != null && title!.isNotEmpty) ...[
          Text(
            title!,
            style: TextStyle(
              color: Colors.grey.shade600,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 8),
        ],
        Container(
          height: 48,
          decoration: BoxDecoration(
            color: const Color(0xFFF7F8FA),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: const Color(0xFFE8E9ED)),
          ),
          child: Row(
            children: [
              IconButton(
                onPressed: value > minValue ? onMinus : null,
                icon: Icon(
                  Icons.remove,
                  color: value > minValue ? Colors.black : Colors.grey.shade400,
                  size: 20,
                ),
              ),
              const VerticalDivider(width: 1, thickness: 1, color: Color(0xFFE8E9ED)),
              Expanded(
                child: Center(
                  child: Text(
                    "$value",
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const VerticalDivider(width: 1, thickness: 1, color: Color(0xFFE8E9ED)),
              IconButton(
                onPressed: onPlus,
                icon: const Icon(
                  Icons.add,
                  color: Colors.black,
                  size: 20,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
