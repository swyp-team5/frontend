import 'package:flutter/material.dart';

class ESubmitScheduleBottomSheet extends StatefulWidget {
  final DateTime date;

  const ESubmitScheduleBottomSheet({
    super.key,
    required this.date,
  });

  @override
  State<ESubmitScheduleBottomSheet> createState() => _ESubmitScheduleBottomSheetState();
}

class _ESubmitScheduleBottomSheetState extends State<ESubmitScheduleBottomSheet> {
  final Set<String> selectedTypes = {};

  final List<String> titles = ["오픈", "미들", "마감",];

  final List<String> times = [
    "10:00 - 13:00", "13:00 - 16:00", "16:00 - 20:00",];

  void _select(String type) {
    setState(() {
      if (selectedTypes.contains(type)) {
        selectedTypes.remove(type);
      } else {
        selectedTypes.add(type);
      }
    });
  }

  void _submit() {
    if (selectedTypes.isEmpty) return;

    Navigator.pop(context, {
      "date": widget.date,
      "types": selectedTypes.toList(),
      "timeRange": _makeTimeRange(),
    });
  }

  String _makeTimeRange() {
    final Map<String, String> timeMap = {
      "오픈": "10:00 - 13:00",
      "미들": "13:00 - 16:00",
      "마감": "16:00 - 20:00",
    };

    return selectedTypes
        .map((type) => timeMap[type]!)
        .join(", ");
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(24),
        ),
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            /// 핸들
            Container(
              width: 44,
              height: 4,
              decoration: BoxDecoration(
                color: const Color(0xFFE6E6E6),
                borderRadius: BorderRadius.circular(20),
              ),
            ),

            const SizedBox(height: 18),

            /// 제목
            const Text(
              "스케줄 시간 선택",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),

            const SizedBox(height: 6),

            Text(
              "불가능한 근무 시간을 선택해주세요 (중복 선택 가능)",
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Color(0xFF767676),
              ),
            ),

            const SizedBox(height: 10),

            Divider(height: 10, color: Color(0xFFF1F1F5),),
            const SizedBox(height: 10),

            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: titles.length,
              gridDelegate:
              const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 10,
                crossAxisSpacing: 15,
                childAspectRatio: 2,
              ),
              itemBuilder: (context, index) {
                final title = titles[index];
                final time = times[index];
                final isSelected = selectedTypes.contains(title);

                return GestureDetector(
                  onTap: () => _select(title),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? const Color(0xFFE6F3FF)
                          : const Color(0xFFF1F1F5),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSelected
                            ? const Color(0xFF0084FF)
                            : Colors.transparent,
                        width: 1.5,
                      ),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                title,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                time,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: Color(0xFF767676),
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(width: 10),

                        if (isSelected)
                          Container(
                            width: 22,
                            height: 22,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: Color(0xFF0084FF),
                            ),
                            child: const Icon(
                              Icons.check,
                              size: 14,
                              color: Colors.white,
                            ),
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),

            const SizedBox(height: 18),

            /// 저장 버튼
            SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton(
                onPressed: selectedTypes.isEmpty ? null : _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0084FF),
                  disabledBackgroundColor: const Color(0xFFA9D0FB),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  "저장",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}