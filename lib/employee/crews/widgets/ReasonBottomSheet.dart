import 'package:flutter/material.dart';

class ReasonBottomSheet extends StatefulWidget {
  const ReasonBottomSheet({
    super.key,
    this.initialReason,
    this.initialEtc,
  });

  final String? initialReason;
  final String? initialEtc;

  @override
  State<ReasonBottomSheet> createState() => _ReasonBottomSheetState();
}

class _ReasonBottomSheetState extends State<ReasonBottomSheet> {
  final TextEditingController _etcController = TextEditingController();

  final List<String> reasons = [
    "가족 일정",
    "수업",
    "건강",
    "기타",
  ];

  String? selectedReason;

  @override
  void initState() {
    super.initState();

    selectedReason = widget.initialReason;
    _etcController.text = widget.initialEtc ?? "";
  }

  @override
  void dispose() {
    _etcController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Container(
          padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(28),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [

              /// 드래그 바
              Container(
                width: 48,
                height: 6,
                decoration: BoxDecoration(
                  color: const Color(0xffD9D9D9),
                  borderRadius: BorderRadius.circular(100),
                ),
              ),

              const SizedBox(height: 22),

              Row(
                children: [
                  const Spacer(),

                  const Text(
                    "교대 사유",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),

                  const Spacer(),

                  InkWell(
                    onTap: () => Navigator.pop(context),
                    child: const Icon(
                      Icons.close,
                      color: Color(0xffC4C4C4),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 10),

              const Text(
                "교대 신청 사유를 선택하세요",
                style: TextStyle(
                  color: Color(0xff8F8F8F),
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),

              SizedBox(height: 10,),

              Divider(height: 1, color: Color(0xFFF1F1F5)),

              SizedBox(height: 10,),

              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: reasons.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                  childAspectRatio: 2.35,
                ),
                itemBuilder: (_, index) {
                  final reason = reasons[index];
                  final selected = selectedReason == reason;

                  return InkWell(
                    borderRadius: BorderRadius.circular(16),
                    onTap: () {
                      setState(() {
                        selectedReason = reason;
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      decoration: BoxDecoration(
                        color: selected
                            ? const Color(0xffEAF4FF)
                            : const Color(0xffF4F4F8),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: selected
                              ? const Color(0xff0084FF)
                              : Colors.transparent,
                          width: 2,
                        ),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              reason,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.black,
                              ),
                            ),
                          ),

                          if (selected)
                            Container(
                              width: 28,
                              height: 28,
                              decoration: const BoxDecoration(
                                color: Color(0xff0084FF),
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
                },
              ),

              const SizedBox(height: 18),

              TextField(
                controller: _etcController,
                maxLength: 50,
                maxLines: 4,
                decoration: InputDecoration(
                  counterText: "",
                  hintText: "기타 내용 작성 (최대 50자)",
                  filled: true,
                  fillColor: const Color(0xffF4F4F8),
                  border: OutlineInputBorder(
                    borderRadius:
                    BorderRadius.circular(14),
                    borderSide: BorderSide.none,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius:
                    BorderRadius.circular(14),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius:
                    BorderRadius.circular(14),
                    borderSide: const BorderSide(
                      color: Color(0xff0084FF),
                    ),
                  ),
                ),
                onChanged: (_) {
                  setState(() {});
                },
              ),

              Align(
                alignment: Alignment.centerRight,
                child: Text(
                  "${_etcController.text.length}/50",
                  style: const TextStyle(
                    color: Color(0xff8F8F8F),
                    fontSize: 14,
                  ),
                ),
              ),

              const SizedBox(height: 20),

              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  onPressed: selectedReason == null
                      ? null
                      : () {
                    Navigator.pop(
                      context,
                      {
                        "reason": selectedReason,
                        "etc": _etcController.text,
                      },
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    elevation: 0,
                    backgroundColor:
                    const Color(0xff0084FF),
                    disabledBackgroundColor:
                    const Color(0xff79B5F3),
                    shape: RoundedRectangleBorder(
                      borderRadius:
                      BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    "사유 확정",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
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