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
                    const RTagChip(text: '매점'),
                    const RTagChip(text: '매표'),
                    const RTagChip(text: '마감 불가'),
                    if (isEditMode) ...const [
                      const SizedBox(width: 8),
                      const Icon(
                        Icons.edit_outlined,
                        size: 18,
                        color: Color(0xFF767676),
                      ),
                    ],
                  ],
                ),

                const SizedBox(height: 26),

                /// 개인 정보
                RInfoSectionCard(
                  title: '개인 정보',
                  isEditMode: isEditMode,
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