import 'package:flutter/material.dart';

class TagBottomSheet extends StatefulWidget {
  final List<String> initialTags;
  final Function(List<String>) onSave;

  const TagBottomSheet({
    super.key,
    required this.initialTags,
    required this.onSave,
  });

  @override
  State<TagBottomSheet> createState() => _TagBottomSheetState();
}

class _TagBottomSheetState extends State<TagBottomSheet> {
  late List<String> tempTags;
  final TextEditingController tagController = TextEditingController();

  @override
  void initState() {
    super.initState();
    tempTags = List<String>.from(widget.initialTags);
  }

  @override
  void dispose() {
    tagController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool canAdd =
        tempTags.length < 3 && tagController.text.trim().isNotEmpty;

    final bool canSave =
        tempTags.isNotEmpty && tempTags.length <= 3;

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 48,
                height: 5,
                decoration: BoxDecoration(
                  color: const Color(0xFFD9D9D9),
                  borderRadius: BorderRadius.circular(100),
                ),
              ),

              const SizedBox(height: 20),

              Stack(
                children: [
                  // 가운데 제목
                  const Align(
                    alignment: Alignment.center,
                    child: Text(
                      "근무자 태그 설정",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  // 오른쪽 닫기 버튼
                  Align(
                    alignment: Alignment.centerRight,
                    child: GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        width: 32,
                        height: 32,
                        decoration: const BoxDecoration(
                          color: Color(0xFFF2F2F7),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.close,
                          size: 18,
                          color: Color(0xFF9A9AA2),
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 8),

              const Text(
                "특이사항을 최대 3개까지 추가할 수 있어요.",
                style: TextStyle(
                  color: Color(0xFF767676),
                ),
              ),

              const SizedBox(height: 24),

              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: tagController,
                      enabled: tempTags.length < 3, // 3개면 입력 비활성화
                      onChanged: (_) => setState(() {}),
                      decoration: InputDecoration(
                        hintText: "태그를 입력하세요",
                        hintStyle: const TextStyle(
                          color: Color(0xFFB5B5BC),
                        ),

                        // 태그 3개면 배경색 회색, 아니면 흰색
                        filled: true,
                        fillColor: tempTags.length >= 3
                            ? const Color(0xFFF7F7FB)
                            : Colors.white,

                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),

                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(
                            color: Color(0xFFE5E5EA),
                          ),
                        ),

                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(
                            color: Color(0xFFE5E5EA),
                          ),
                        ),

                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(
                            color: Color(0xFF0084FF),
                          ),
                        ),

                        disabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(
                            color: Color(0xFFE5E5EA),
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(width: 10),

                  SizedBox(
                    height: 44,
                    child: ElevatedButton(
                      onPressed: canAdd
                          ? () {
                        final value =
                        tagController.text.trim();

                        if (!tempTags.contains(value)) {
                          setState(() {
                            tempTags.add(value);
                            tagController.clear();
                          });
                        }
                      }
                          : null,
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8)
                        ),
                        backgroundColor: const Color(0xFF0084FF),
                        disabledBackgroundColor: const Color(0xFFE0E2E5),
                      ),
                      child: Text("추가",
                        style: TextStyle(
                          color: canAdd
                              ? Colors.white
                              : const Color(0xFFB5B5BC), // 비활성화 시 회색
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              Align(
                alignment: Alignment.centerLeft,
                child: Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: tempTags.map((tag) {
                    return Chip(
                      label: Text(
                        tag,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.black,
                        ),
                      ),
                      backgroundColor: const Color(0xFFF7F7FB),
                      deleteIcon: const Icon(
                        Icons.close,
                        size: 16,
                        color: Color(0xFFA5A5AF),
                      ),
                      onDeleted: () {
                        setState(() {
                          tempTags.remove(tag);
                        });
                      },
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(100),
                        side: const BorderSide(
                          color: Colors.transparent,
                          width: 0,
                        ), // 테두리 제거
                      ),
                    );
                  }).toList(),
                ),
              ),

              const SizedBox(height: 28),

              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  // onPressed: canSave
                  //     ? () {
                  //   setState(() {
                  //     crewTags = List.from(tempTags);
                  //   });
                  //
                  //   Navigator.pop(context);
                  //
                  //   // API 연동 시
                  //   // await api.updateCrewTags(crewTags);
                  // }
                  //     : null,
                  onPressed: canSave
                      ? () {
                    widget.onSave(tempTags);
                    Navigator.pop(context);
                  }
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                    const Color(0xFF0084FF),
                    disabledBackgroundColor:
                    const Color(0xFFE5E5EA),
                    shape: RoundedRectangleBorder(
                      borderRadius:
                      BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    "저장",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 17,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}