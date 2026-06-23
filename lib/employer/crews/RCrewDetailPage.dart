import 'package:chack_chack/employer/crews/widgets/RInfoSectionCard.dart';
import 'package:chack_chack/employer/crews/widgets/RTagChip.dart';
import 'package:flutter/material.dart';


class RCrewDetailPage extends StatefulWidget {

  const RCrewDetailPage({super.key});

  @override
  State<RCrewDetailPage> createState() => _RCrewDetailPageState();
}

class _RCrewDetailPageState extends State<RCrewDetailPage> {

  bool isEditMode = false;

  /// API 연동 시 서버에서 받아올 더미 태그 목록
  List<String> crewTags = ["매점", "매표", "마감 불가",];

  final TextEditingController tagController = TextEditingController();

  // 나중에 API 응답으로 교체
  // crewTags = response.tags;

  Future<void> _showTagBottomSheet() async {
    List<String> tempTags = List.from(crewTags);
    tagController.clear();

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(24),
        ),
      ),
      builder: (_) {
        return StatefulBuilder(
          builder: (context, modalSetState) {
            final bool canAdd =
                tempTags.length < 3 &&
                    tagController.text.trim().isNotEmpty;

            /// 최대 3개 미만이어야 저장 가능
            final bool canSave = tempTags.length > 0 && tempTags.length < 4;

            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
              ),
              child: SafeArea(
                top: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 24,),
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
                                child: const Center(
                                  child: Icon(
                                    Icons.close,
                                    size: 18,
                                    color: Color(0xFF9A9AA2),
                                  ),
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
                          fontSize: 14,
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
                              onChanged: (_) {
                                modalSetState(() {});
                              },
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
                              onPressed: canAdd ? () {
                                final value = tagController.text.trim();

                                if (!tempTags.contains(value)) {
                                  modalSetState(() {
                                    tempTags.add(value);
                                    tagController.clear();
                                  });
                                }
                              } : null,
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
                                modalSetState(() {
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
                            setState(() {
                              crewTags = List<String>.from(tempTags);
                            });

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
          },
        );
      },
    );
  }


  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),

      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 20, vertical: 30,
            ),

            child: Column(
              children: [
                /// 상단 헤더
                SizedBox(
                  height: 40,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // 가운데 제목
                      const Center(
                        child: Text(
                          "상세 정보",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),

                      // 왼쪽 뒤로가기
                      Align(
                        alignment: Alignment.centerLeft,
                        child: GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: const Icon(
                            Icons.arrow_back_ios_new,
                            size: 22,
                          ),
                        ),
                      ),

                      // 오른쪽 저장/편집
                      Align(
                        alignment: Alignment.centerRight,
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              isEditMode = !isEditMode;
                            });
                          },
                          child: isEditMode
                              ? const Text(
                            "저장",
                            style: TextStyle(
                              fontSize: 16,
                              color: Color(0xFF767676),
                              fontWeight: FontWeight.w600,
                            ),
                          )
                              : const Icon(
                            Icons.edit_outlined,
                            size: 24,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 30),

                /// 프로필 이미지
                Container(width: 80, height: 80,
                  decoration: BoxDecoration(
                    color: Color(0xFFA5A5AF),
                    borderRadius: BorderRadius.circular(24),
                  ),
                ),

                const SizedBox(height: 18),

                /// 역할
                Text('근무자',
                  style: TextStyle(
                    color: Color(0xFF505050),
                    fontSize: 15,
                  ),
                ),

                const SizedBox(height: 6),

                /// 이름 + 상태
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      "박지연",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(width: 8),

                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text(
                        "재직 중",
                        style: TextStyle(
                          color: Color(0xFF00315F),
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 14),

                /// 태그
                Wrap(
                  spacing: 8,
                  children: [
                    ...crewTags.map((tag) => RTagChip(text: tag)),
                    if (isEditMode)
                      GestureDetector(
                        onTap: _showTagBottomSheet,
                        child: const Icon(
                          Icons.edit_outlined,
                          size: 18,
                          color: Color(0xFF767676),
                        ),
                      ),
                  ],
                ),

                const SizedBox(height: 26),

                /// 개인 정보
                RInfoSectionCard(
                  title: '개인 정보',
                  isEditMode: isEditMode,
                  arrowIndexes: const [],
                  items: [
                    ['이름', '박지연'],
                    ['휴대폰 번호', '010-1234-5678'],
                  ],
                ),

                const SizedBox(height: 16),

                /// 소속 정보
                RInfoSectionCard(
                  title: "소속 정보",
                  isEditMode: isEditMode,
                  arrowIndexes: const [1, 2],
                  items: [
                    ["직급", "근무자"],
                    ["입사일", "2026년 4월 1일"],
                    ["재직 상태", "재직중"],
                  ],
                ),

                const SizedBox(height: 16),

                /// 근무 정보
                RInfoSectionCard(
                  title: '근무 정보',
                  isEditMode: isEditMode,
                  arrowIndexes: const [0, 1],
                  items: [
                    ['근무 시간', '오전 09:00 - 오후 14:00'],
                    ['근무 요일', '월, 수, 금'],
                  ],
                ),

                const SizedBox(height: 16),

                /// 소속 정보
                RInfoSectionCard(
                  title: '소속 정보',
                  isEditMode: isEditMode,
                  arrowIndexes: const [],
                  items: [
                    ['총 근무 일수', '16일'],
                    ['총 근무 시간', '80시간'],
                  ],
                ),

                const SizedBox(height: 16),

                /// 지난 달 급여 정보
                GestureDetector(
                    onTap: () {},

                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 18, vertical: 20,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              "지난달 급여 정보",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: isEditMode
                                    ? Colors.black
                                    : const Color(0xFF767676),
                              ),
                            ),
                          ),
                          Icon(
                            Icons.chevron_right,
                            color: Colors.black,
                          ),
                        ],
                      ),
                    )
                ),

                if (!isEditMode) ...[
                  const SizedBox(height: 24),

                  SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: ElevatedButton(
                      onPressed: () {
                        // 삭제 기능 구현
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0084FF),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text(
                        "근무자 삭제",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}