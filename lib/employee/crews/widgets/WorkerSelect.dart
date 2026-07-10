import 'package:flutter/material.dart';

import '../model/WorkChangeTargetsResponse.dart';

class WorkerSelect extends StatelessWidget {
  final List<WorkChangeWorker> workers;
  final WorkChangeWorker? selectedWorker;
  final ValueChanged<WorkChangeWorker> onWorkerSelected;
  final VoidCallback onConfirm;

  const WorkerSelect({
    super.key,
    required this.workers,
    required this.selectedWorker,
    required this.onWorkerSelected,
    required this.onConfirm,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 20,
          ),
          child: Row(
            children: const [
              Text(
                "교대 희망 상대를 선택하세요",
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF505050),
                ),
              ),
            ],
          ),
        ),

        Expanded(
          child: GridView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            itemCount: workers.length,
            gridDelegate:
            const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 2.7,
            ),
            itemBuilder: (_, index) {
              final worker = workers[index];
              final selected =
                  selectedWorker?.memberId == worker.memberId;

              return GestureDetector(
                onTap: () => onWorkerSelected(worker),
                child: Container(
                  decoration: BoxDecoration(
                    color: selected
                        ? const Color(0xffE6F3FF)
                        : Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: selected
                          ? const Color(0xFF0084FF)
                          : Colors.transparent,
                    ),
                  ),
                  child: Row(
                    children: [
                      const SizedBox(width: 12),

                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: worker.profileImageUrl != null
                            ? Image.network(
                          worker.profileImageUrl!,
                          width: 48,
                          height: 48,
                          fit: BoxFit.cover,
                        )
                            : Container(
                          width: 48,
                          height: 48,
                          color: const Color(0xFFE0E2E5),
                        ),
                      ),

                      const SizedBox(width: 12),

                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment:
                          CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "동료",
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 12,
                                color: Color(0xFF999999),
                              ),
                            ),
                            Text(
                              worker.name,
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),

        Padding(
          padding: const EdgeInsets.all(20),
          child: SizedBox(
            width: double.infinity,
            height: 54,
            child: ElevatedButton(
              onPressed: selectedWorker == null ? null : onConfirm,

              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0084FF),
                disabledBackgroundColor: const Color(0xFF80C2FF),
                foregroundColor: Colors.white,
                disabledForegroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),

              child: const Text(
                "근무자 선택",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            )
          ),
        ),
      ],
    );
  }
}