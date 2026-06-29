import 'package:flutter/material.dart';

class ApplicationForm extends StatelessWidget {
  final bool isSubstitute;

  final Widget scheduleTile;
  final Widget workerTile;
  final Widget reasonTile;

  final VoidCallback? onSubmit;

  const ApplicationForm({
    super.key,
    required this.isSubstitute,
    required this.scheduleTile,
    required this.workerTile,
    required this.reasonTile,
    this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.zero,
      child: Column(
        children: [
          Expanded(
            child: ListView(
              children: [
                const SizedBox(height: 8),

                scheduleTile,

                workerTile,

                reasonTile,
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 20,
            ),
            child: SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton(
                onPressed: onSubmit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: onSubmit != null
                      ? const Color(0xff0084FF)   // 활성
                      : const Color(0xff79B5F3),  // 비활성
                  disabledBackgroundColor: const Color(0xff79B5F3),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: const Text(
                  "신청하기",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 18,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}