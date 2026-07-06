import 'package:chack_chack/employer/crews/widgets/RInfoSectionCard.dart';
import 'package:flutter/material.dart';

import 'bottom_sheets/EmploymentStatusBottomSheet.dart';
import 'bottom_sheets/EmploymentYearMonthBottomSheet.dart';
import 'bottom_sheets/TagBottomSheet.dart';
import 'bottom_sheets/WorkDaysBottomSheet.dart';
import 'bottom_sheets/WorkingTimeBottomSheet.dart';
import 'model/RCrewModel.dart';


class RCrewDetailPage extends StatefulWidget {

  final RCrewModel crew;

  const RCrewDetailPage({
    super.key,
    required this.crew,
  });

  @override
  State<RCrewDetailPage> createState() => _RCrewDetailPageState();
}

class _RCrewDetailPageState extends State<RCrewDetailPage> {

  bool isEditMode = false;


  final TextEditingController tagController = TextEditingController();

  // 나중에 API 응답으로 교체
  // crewTags = response.tags;


  late DateTime employmentDate;

  late String employmentStatus;

  late TimeOfDay workingStartTime;
  late TimeOfDay workingEndTime;

  late List<String> workingDays;


  @override
  void initState() {
    super.initState();
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
                          onTap: () {
                            Navigator.pop(context, widget.crew);
                          },
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
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: const Color(0xFFA5A5AF),
                    borderRadius: BorderRadius.circular(24),
                    image: (widget.crew.profileImageUrl != null &&
                        widget.crew.profileImageUrl!.isNotEmpty)
                        ? DecorationImage(
                      image: NetworkImage(widget.crew.profileImageUrl!),
                      fit: BoxFit.cover,
                    )
                        : null,
                  ),
                  child: (widget.crew.profileImageUrl == null ||
                      widget.crew.profileImageUrl!.isEmpty)
                      ? const Icon(
                    Icons.person,
                    size: 40,
                    color: Colors.white,
                  )
                      : null,
                ),

                const SizedBox(height: 18),

                /// 이름 + 상태
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      widget.crew.name,
                      style: const TextStyle(
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
                      child: Text(
                        widget.crew.crewRole == "OWNER" ? "사장님" : "재직 중",
                        style: const TextStyle(
                          color: Color(0xFF00315F),
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 30),

                /// 개인 정보
                RInfoSectionCard(
                  title: '개인 정보',
                  isEditMode: isEditMode,
                  arrowIndexes: const [],
                  items: [
                    ['이름', widget.crew.name],
                    ['휴대폰 번호', ''],
                  ],
                ),

                const SizedBox(height: 16),

              ],
            ),
          ),
        ),
      ),
    );
  }
}