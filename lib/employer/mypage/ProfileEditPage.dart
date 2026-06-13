import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../../common/widgets/BottomNavBar.dart';
import '../crews/CrewsPage.dart';
import '../home/HomePage.dart';
import 'MyPage.dart';

class ProfileEditPage extends StatefulWidget {

  const ProfileEditPage({super.key});

  @override
  State<ProfileEditPage> createState() =>
      _ProfileEditPageState();
}

class _ProfileEditPageState
    extends State<ProfileEditPage> {

  File? profileImage;

  final ImagePicker picker =
  ImagePicker();

  /// 프로필 이미지 선택
  Future<void> pickProfileImage() async {

    final XFile? image =
    await picker.pickImage(
      source: ImageSource.gallery,
    );

    if (image != null) {

      setState(() {

        profileImage =
            File(image.path);
      });
    }
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor:
      const Color(0xFFF5F5F5),

      /// 공통 BottomNavBar 적용
      bottomNavigationBar:
      BottomNavBar(
        currentIndex: 4,

        onTap: (index) {

          /// 홈
          if (index == 0) {

            Navigator.push(
              context,

              MaterialPageRoute(
                builder: (_) =>
                const HomePage(),
              ),
            );
          }

          /// 동료
          else if (index == 1) {

            Navigator.push(
              context,

              MaterialPageRoute(
                builder: (_) =>
                const CrewsPage(),
              ),
            );
          }

          /// 스케줄
          else if (index == 2) {}

          /// 급여
          else if (index == 3) {}

          /// 마이페이지
          else if (index == 4) {

            Navigator.push(
              context,

              MaterialPageRoute(
                builder: (_) =>
                const MyPage(),
              ),
            );
          }
        },
      ),

      body: SafeArea(
        child: SingleChildScrollView(

          child: Column(
            crossAxisAlignment:
            CrossAxisAlignment.start,

            children: [

              /// 상단 헤더
              Padding(
                padding:
                const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 30,
                ),

                child: Row(
                  children: [

                    GestureDetector(
                      onTap: () {

                        Navigator.pop(
                          context,
                        );
                      },

                      child: const Icon(
                        Icons.arrow_back_ios_new,
                        size: 22,
                      ),
                    ),

                    const Expanded(
                      child: Center(
                        child: Text(
                          '프로필 변경',

                          style: TextStyle(
                            fontSize: 22,
                            fontWeight:
                            FontWeight.bold,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(width: 22),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              /// 프로필 영역
              Center(
                child: Column(
                  children: [

                    Stack(
                      alignment:
                      Alignment.bottomRight,

                      children: [

                        /// 프로필 이미지
                        Container(
                          width: 92,
                          height: 92,

                          decoration:
                          BoxDecoration(
                            shape:
                            BoxShape.circle,

                            color:
                            Colors
                                .grey
                                .shade300,

                            image:
                            profileImage !=
                                null
                                ? DecorationImage(
                              image:
                              FileImage(
                                profileImage!,
                              ),

                              fit:
                              BoxFit.cover,
                            )
                                : null,
                          ),
                        ),

                        /// 추가 버튼
                        GestureDetector(
                          onTap: () async {

                            await pickProfileImage();
                          },

                          child: Container(
                            width: 30,
                            height: 30,

                            decoration:
                            BoxDecoration(
                              color:
                              Colors
                                  .grey
                                  .shade500,

                              shape:
                              BoxShape
                                  .circle,
                            ),

                            child: const Icon(
                              Icons.add,
                              color:
                              Colors.white,
                              size: 20,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 18),

                    const Text(
                      '집게사장',

                      style: TextStyle(
                        fontSize: 25,
                        fontWeight:
                        FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 10),

                    Text(
                      '010-XXXX-XXXX',

                      style: TextStyle(
                        color:
                        Colors.grey
                            .shade600,

                        fontSize: 15,
                        fontWeight:
                        FontWeight.w500,
                      ),
                    ),

                    const SizedBox(height: 22),

                    TextButton(
                      onPressed: () {

                        /// 상태 메시지 수정
                      },

                      style:
                      TextButton.styleFrom(
                        padding:
                        EdgeInsets.zero,

                        minimumSize:
                        Size.zero,

                        tapTargetSize:
                        MaterialTapTargetSize
                            .shrinkWrap,
                      ),

                      child: Row(
                        mainAxisSize:
                        MainAxisSize.min,

                        children: [

                          const Text(
                            '상태 메시지 입력',

                            style: TextStyle(
                              color:
                              Colors.black,

                              fontSize: 15,

                              fontWeight:
                              FontWeight.w500,
                            ),
                          ),

                          const SizedBox(width: 8),

                          Icon(
                            Icons.edit_outlined,
                            size: 20,
                            color:
                            Colors.grey
                                .shade600,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 40),

              Container(
                height: 15,
                color: Colors.grey.shade300,
              ),

              /// 개인 정보
              _buildSection(
                context: context,

                title: '개인 정보',

                items: [

                  _ProfileItem(
                    title: '이름',
                    value: '집게사장',
                    isArrow: false,
                  ),

                  _ProfileItem(
                    title: '생년월일',
                    value: '설정하기',
                  ),

                  _ProfileItem(
                    title: '이메일',
                    value: '설정하기',
                  ),
                ],
              ),

              Container(
                height: 15,
                color: Colors.grey.shade300,
              ),

              /// 매장 정보
              _buildSection(
                context: context,

                title: '매장 정보',

                items: [

                  _ProfileItem(
                    title: '매장 로고',
                    value: '설정하기',
                  ),

                  _ProfileItem(
                    title: '매장 이름',
                    value: '집게리아',
                  ),

                  _ProfileItem(
                    title: '매장 전화번호',
                    value: '설정하기',
                  ),
                ],
              ),

              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  /// 섹션
  Widget _buildSection({
    required BuildContext context,
    required String title,
    required List<_ProfileItem> items,
  }) {

    return Padding(
      padding:
      const EdgeInsets.fromLTRB(
        30,
        20,
        30,
        0,
      ),

      child: Column(
        crossAxisAlignment:
        CrossAxisAlignment.start,

        children: [

          /// 섹션 타이틀
          Text(
            title,

            style: const TextStyle(
              fontSize: 22,
              fontWeight:
              FontWeight.bold,
            ),
          ),

          const SizedBox(height: 25),

          ...items.map(
                (item) => Padding(
              padding:
              const EdgeInsets.only(
                bottom: 25,
              ),

              child: Row(
                children: [

                  /// 섹션 디테일
                  Text(
                    item.title,

                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight:
                      FontWeight.w500,
                    ),
                  ),

                  const Spacer(),

                  /// 버튼화
                  TextButton(
                    onPressed: () {

                      /// 네비게이션 가능
                    },

                    style:
                    TextButton.styleFrom(
                      padding:
                      EdgeInsets.zero,

                      minimumSize:
                      Size.zero,

                      tapTargetSize:
                      MaterialTapTargetSize
                          .shrinkWrap,
                    ),

                    child: Row(
                      children: [

                        Text(
                          item.value,

                          style: TextStyle(
                            color:
                            item.value ==
                                '설정하기'
                                ? Colors.grey.shade500
                                : Colors.black,

                            fontSize: 20,
                            fontWeight:
                            FontWeight.w500,
                          ),
                        ),

                        Padding(
                          padding:
                          const EdgeInsets.only(
                            left: 0,
                          ),

                          child:
                          item.isArrow
                              ? Icon(
                            Icons
                                .chevron_right,

                            size: 24,

                            color:
                            Colors.grey
                                .shade500,
                          )
                              : const SizedBox(
                            width: 24,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileItem {

  final String title;
  final String value;
  final bool isArrow;

  _ProfileItem({
    required this.title,
    required this.value,
    this.isArrow = true,
  });
}