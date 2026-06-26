import 'package:flutter/material.dart';

class WorkerBottomSheet extends StatefulWidget {
  final List<String> workers;
  final List<String> initialSelected;

  const WorkerBottomSheet({
    super.key,
    required this.workers,
    this.initialSelected = const [],
  });

  static Future<List<String>?> show(
      BuildContext context, {
        required List<String> workers,
        List<String> initialSelected = const [],
      }) {
    return showModalBottomSheet<List<String>>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(28),
        ),
      ),
      builder: (_) => WorkerBottomSheet(
        workers: workers,
        initialSelected: initialSelected,
      ),
    );
  }

  @override
  State<WorkerBottomSheet> createState() =>
      _WorkerBottomSheetState();
}

class _WorkerBottomSheetState
    extends State<WorkerBottomSheet> {

  late List<String> selectedWorkers;

  @override
  void initState() {
    super.initState();
    selectedWorkers =
    List<String>.from(widget.initialSelected);
  }

  Widget item(String worker) {

    final selected =
    selectedWorkers.contains(worker);

    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: () {

        setState(() {

          if (selected) {
            selectedWorkers.remove(worker);
          } else {
            selectedWorkers.add(worker);
          }

        });

      },
      child: Container(
        height: 64,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: selected
              ? const Color(0xFFEAF4FF)
              : const Color(0xFFF5F5FA),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: selected
                ? const Color(0xFF1687F8)
                : Colors.transparent,
            width: 1.5,
          ),
        ),
        child: Row(
          children: [

            Expanded(
              child: Text(
                worker,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),

            if (selected)
              Container(
                width: 28,
                height: 28,
                decoration: const BoxDecoration(
                  color: Color(0xFF1687F8),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check,
                  color: Colors.white,
                  size: 18,
                ),
              ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {

    return SafeArea(
      child: Padding(
        padding:
        const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [

            const SizedBox(height: 10),

            Container(
              width: 52,
              height: 6,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius:
                BorderRadius.circular(99),
              ),
            ),

            const SizedBox(height: 20),

            Stack(
              alignment: Alignment.center,
              children: [

                const Center(
                  child: Text(
                    "근무자 설정",
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),

                Align(
                  alignment: Alignment.centerRight,
                  child: IconButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    icon: const Icon(Icons.close),
                  ),
                )
              ],
            ),

            const SizedBox(height: 8),

            const Text(
              "중복 선택이 가능해요",
              style: TextStyle(
                color: Color(0xff888888),
                fontSize: 14,
              ),
            ),

            const SizedBox(height: 24),

            GridView.builder(
              shrinkWrap: true,
              physics:
              const NeverScrollableScrollPhysics(),
              itemCount: widget.workers.length,
              gridDelegate:
              const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 2.1,
              ),
              itemBuilder: (_, index) {
                return item(widget.workers[index]);
              },
            ),

            const SizedBox(height: 24),

            SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton(
                onPressed: selectedWorkers.isEmpty
                    ? null
                    : () {
                  Navigator.pop(
                    context,
                    selectedWorkers,
                  );
                },
                style: ElevatedButton.styleFrom(
                  elevation: 0,
                  backgroundColor: const Color(0xFF1687F8),
                  disabledBackgroundColor: const Color(0xFFA9D0FB),
                  shape: RoundedRectangleBorder(
                    borderRadius:
                    BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  "저장",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                    fontSize: 16,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}