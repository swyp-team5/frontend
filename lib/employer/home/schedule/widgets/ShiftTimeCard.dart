import 'package:flutter/material.dart';
import '../models/ShiftInfo.dart';
import '../TimeInputBottomSheet.dart';
import 'CounterBox.dart';

class ShiftTimeCard extends StatefulWidget {
  final int index;
  final ShiftInfo info;
  final VoidCallback? onChanged;

  const ShiftTimeCard({
    super.key,
    required this.index,
    required this.info,
    this.onChanged,
  });

  @override
  State<ShiftTimeCard> createState() => _ShiftTimeCardState();
}

class _ShiftTimeCardState extends State<ShiftTimeCard> {
  final TextEditingController _nameController = TextEditingController();

  static const List<String> ordinals = [
    "첫 번째", "두 번째", "세 번째", "네 번째", "다섯 번째", "여섯 번째", "일곱 번째", "여덟 번째", "아홉 번째", "열 번째"
  ];

  @override
  void initState() {
    super.initState();
    _nameController.text = widget.info.name;
    _nameController.addListener(() {
      widget.info.name = _nameController.text;
      widget.onChanged?.call();
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  String _formatTime(TimeOfDay time) {
    return "${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}";
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.index > 0) const SizedBox(height: 32),
        
        Text(
          "${ordinals[widget.index % ordinals.length]} 타임",
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        
        const Text("타임 이름", style: TextStyle(color: Color(0xFF6C6E76), fontSize: 13)),
        const SizedBox(height: 8),
        Container(
          height: 52,
          decoration: BoxDecoration(
            color: const Color(0xFFF7F8FA),
            borderRadius: BorderRadius.circular(10),
          ),
          child: TextField(
            controller: _nameController,
            decoration: const InputDecoration(
              hintText: "타임 이름을 작성해주세요",
              hintStyle: TextStyle(color: Color(0xFFAEB0B6), fontSize: 15),
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(horizontal: 16),
            ),
          ),
        ),
        const SizedBox(height: 20),
        
        Row(
          children: [
            Expanded(
              child: _buildTimePicker(
                label: "시작 시간",
                time: _formatTime(widget.info.startTime),
                onTap: () async {
                  final bool startIsDefault =
                      widget.info.startTime.hour == 0 && widget.info.startTime.minute == 0;

                  final bool endIsDefault =
                      widget.info.endTime.hour == 0 && widget.info.endTime.minute == 0;

                  final result = await TimeInputBottomSheet.show(
                    context,
                    initialOpenTime:
                    startIsDefault ? widget.info.endTime : widget.info.startTime,
                    initialCloseTime:
                    endIsDefault ? widget.info.startTime : widget.info.endTime,
                  );
                  if (result != null) {
                    setState(() {
                      widget.info.startTime = result.openTime;
                      widget.info.endTime = result.closeTime;
                    });
                  }
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildTimePicker(
                label: "종료 시간",
                time: _formatTime(widget.info.endTime),
                onTap: () async {
                  final bool startIsDefault =
                      widget.info.startTime.hour == 0 && widget.info.startTime.minute == 0;

                  final bool endIsDefault =
                      widget.info.endTime.hour == 0 && widget.info.endTime.minute == 0;

                  final result = await TimeInputBottomSheet.show(
                    context,
                    initialOpenTime:
                    startIsDefault ? widget.info.endTime : widget.info.startTime,
                    initialCloseTime:
                    endIsDefault ? widget.info.startTime : widget.info.endTime,
                  );
                  if (result != null) {
                    setState(() {
                      widget.info.startTime = result.openTime;
                      widget.info.endTime = result.closeTime;
                    });
                  }
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),

        const Text(
          "휴게 시간",
          style: TextStyle(
            color: Color(0xFF6C6E76),
            fontSize: 13,
          ),
        ),
        const SizedBox(height: 8),

        InkWell(
          onTap: () async {
            final result = await showModalBottomSheet<String>(
              context: context,
              isScrollControlled: true,
              backgroundColor: Colors.transparent,
              builder: (context) {
                String? selectedValue = widget.info.breakTime;

                return StatefulBuilder(
                  builder: (context, setModalState) {
                    const options = [
                      "없음",
                      "30분",
                      "1시간",
                      "1시간 30분",
                    ];

                    return Container(
                      padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.vertical(
                          top: Radius.circular(24),
                        ),
                      ),
                      child: SafeArea(
                        top: false,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // 상단 핸들
                            Container(
                              width: 56,
                              height: 5,
                              decoration: BoxDecoration(
                                color: const Color(0xFFD9D9D9),
                                borderRadius: BorderRadius.circular(100),
                              ),
                            ),

                            const SizedBox(height: 20),

                            // 제목 + 닫기 버튼
                            Stack(
                              alignment: Alignment.center,
                              children: [
                                const Center(
                                  child: Text(
                                    "휴게시간 선택",
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                                Positioned(
                                  right: 0,
                                  child: GestureDetector(
                                    onTap: () => Navigator.pop(context),
                                    child: Container(
                                      width: 36,
                                      height: 36,
                                      decoration: const BoxDecoration(
                                        color: Color(0xFFF2F2F5),
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(
                                        Icons.close,
                                        color: Color(0xFFAEB0B6),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 8),

                            const Text(
                              "휴게시간은 4시간마다 30분씩 법적으로 정해져 있어요",
                              style: TextStyle(
                                fontSize: 14,
                                color: Color(0xFF767676),
                              ),
                            ),

                            const SizedBox(height: 16),

                            const Divider(
                              height: 1,
                              thickness: 1,
                              color: Color(0xFFF1F1F5),
                            ),

                            const SizedBox(height: 16),

                            GridView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: options.length,
                              gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                crossAxisSpacing: 12,
                                mainAxisSpacing: 12,
                                childAspectRatio: 2.1,
                              ),
                              itemBuilder: (context, index) {
                                final item = options[index];
                                final isSelected = selectedValue == item;

                                return GestureDetector(
                                  onTap: () {
                                    setModalState(() {
                                      selectedValue = item;
                                    });
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 18),
                                    decoration: BoxDecoration(
                                      color: isSelected
                                          ? const Color(0xFFE6F3FF)
                                          : const Color(0xFFF1F1F5),
                                      borderRadius: BorderRadius.circular(14),
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
                                          child: Text(
                                            item,
                                            style: TextStyle(
                                              fontSize: 18,
                                              fontWeight:
                                              isSelected ? FontWeight.w700 : FontWeight.w500,
                                              color: Colors.black,
                                            ),
                                          ),
                                        ),
                                        if (isSelected)
                                          Container(
                                            width: 22,
                                            height: 22,
                                            decoration: const BoxDecoration(
                                              color: Color(0xFF0084FF),
                                              shape: BoxShape.circle,
                                            ),
                                            child: const Icon(
                                              Icons.check,
                                              size: 18,
                                              color: Colors.white,
                                            ),
                                          ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),

                            const SizedBox(height: 28),

                            SizedBox(
                              width: double.infinity,
                              height: 60,
                              child: ElevatedButton(
                                onPressed: () {
                                  Navigator.pop(context, selectedValue);
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF1784F4),
                                  elevation: 0,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                child: const Text(
                                  "저장",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            );

            if (result != null) {
              setState(() {
                widget.info.breakTime = result;
              });
              widget.onChanged?.call();
            }
          },
          child: Container(
            height: 52,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: const Color(0xFFF7F8FA),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                Text(
                  widget.info.breakTime,
                  style: const TextStyle(
                    fontSize: 15,
                  ),
                ),
                const Spacer(),
                const Icon(
                  Icons.keyboard_arrow_down,
                  color: Color(0xFFAEB0B6),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 20),
        
        const Text("필요 근무자 수", style: TextStyle(color: Color(0xFF6C6E76), fontSize: 13)),
        const SizedBox(height: 8),
        CounterBox(
          value: widget.info.requiredWorkers,
          minValue: 1,
          onMinus: () {
            setState(() {
              widget.info.requiredWorkers--;
            });
            widget.onChanged?.call();
          },

          onPlus: () {
            setState(() {
              widget.info.requiredWorkers++;
            });
            widget.onChanged?.call();
          },
        ),
      ],
    );
  }

  Widget _buildTimePicker({required String label, required String time, required VoidCallback onTap}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Color(0xFF6C6E76), fontSize: 13)),
        const SizedBox(height: 8),
        InkWell(
          onTap: onTap,
          child: Container(
            height: 52,
            decoration: BoxDecoration(
              color: const Color(0xFFF7F8FA),
              borderRadius: BorderRadius.circular(10),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 14),
            child: Row(
              children: [
                Text(time, style: const TextStyle(fontSize: 15, color: Colors.black)),
                const Spacer(),
                const Icon(Icons.access_time, color: Color(0xFFAEB0B6), size: 18),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
