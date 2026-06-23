import 'dart:io';

import 'package:chack_chack/employee/mypage/widgets/EInfoSectionCard.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import 'dart:typed_data';
import 'package:photo_manager/photo_manager.dart';

import 'package:shared_preferences/shared_preferences.dart';

import '../crews/widgets/ETagChip.dart';

class EProfileEditPage extends StatefulWidget {

  const EProfileEditPage({super.key});

  @override
  State<EProfileEditPage> createState() => _EProfileEditPageState();
}

class _EProfileEditPageState extends State<EProfileEditPage> {

  bool isEditMode = false;

  // 키 값을 'EMPLOYEE_'로 명확히 구분
  static const String EkeyProfileImage = "EMPLOYEE_profileImage";
  static const String EkeyName = "EMPLOYEE_name";
  static const String EkeyPhone = "EMPLOYEE_phone";
  static const String EkeyStorePhone = "EMPLOYEE_storePhone";

  File? profileImage;

  final ImagePicker picker = ImagePicker();

  final TextEditingController nameController = TextEditingController();

  final TextEditingController phoneController = TextEditingController();

  final TextEditingController storePhoneController = TextEditingController();

  /// 프로필 이미지 선택
  Future<void> _showGalleryBottomSheet() async {
    final PermissionState ps =
    await PhotoManager.requestPermissionExtend();

    if (!ps.isAuth && ps != PermissionState.limited) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("갤러리 접근 권한이 필요합니다."),
          ),
        );
      }
      return;
    }

    final List<AssetPathEntity> albums =
    await PhotoManager.getAssetPathList(
      type: RequestType.image,
      onlyAll: true,
    );

    if (albums.isEmpty) return;

    final AssetPathEntity album = albums.first;

    final List<AssetEntity> images =
    await album.getAssetListPaged(
      page: 0,
      size: 100,
    );

    images.sort(
          (a, b) => b.createDateTime.compareTo(a.createDateTime),
    );

    if (!mounted) return;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(28),
        ),
      ),
      builder: (_) {
        AssetEntity? selectedAsset;

        return StatefulBuilder(
          builder: (context, setModalState) {
            return SizedBox(
              height: MediaQuery.of(context).size.height * 0.7,
              child: Column(
                children: [
                  const SizedBox(height: 12),

                  Container(
                    width: 48, height: 5,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),

                  const SizedBox(height: 16),

                  const Text(
                    "최근 항목",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 16),

                  Expanded(
                    child: GridView.builder(
                      padding: EdgeInsets.zero,
                      itemCount: images.length,
                      gridDelegate:
                      const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        crossAxisSpacing: 2,
                        mainAxisSpacing: 2,
                      ),
                      itemBuilder: (context, index) {
                        final asset = images[index];

                        final isSelected =
                            selectedAsset?.id == asset.id;

                        return FutureBuilder<Uint8List?>(
                          future: asset.thumbnailDataWithSize(
                            const ThumbnailSize(300, 300),
                          ),
                          builder: (context, snapshot) {
                            if (!snapshot.hasData) {
                              return Container(
                                color: Colors.grey.shade200,
                              );
                            }

                            return GestureDetector(
                              onTap: () {
                                setModalState(() {
                                  selectedAsset = asset;
                                });
                              },
                              child: Stack(
                                children: [
                                  Positioned.fill(
                                    child: Image.memory(
                                      snapshot.data!,
                                      fit: BoxFit.cover,
                                    ),
                                  ),

                                  if (isSelected)
                                    Positioned.fill(
                                      child: Container(
                                        decoration: BoxDecoration(
                                          border: Border.all(
                                            color: Colors.blue,
                                            width: 3,
                                          ),
                                        ),
                                      ),
                                    ),

                                  Positioned(
                                    top: 8,
                                    right: 8,
                                    child: Container(
                                      width: 24,
                                      height: 24,
                                      decoration: BoxDecoration(
                                        color: isSelected
                                            ? Colors.blue
                                            : Colors.white,
                                        borderRadius:
                                        BorderRadius.circular(6),
                                      ),
                                      child: isSelected
                                          ? const Icon(
                                        Icons.check,
                                        size: 16,
                                        color: Colors.white,
                                      )
                                          : null,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ),

                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 12, 20, 24,),
                    child: SizedBox(
                      width: double.infinity,
                      height: 54,
                      child: ElevatedButton(
                        onPressed: selectedAsset == null
                            ? null
                            : () async {
                          final file =
                          await selectedAsset!.originFile;

                          if (file != null) {
                            setState(() {
                              profileImage = file;
                            });

                            if (mounted) {
                              Navigator.pop(context);
                            }
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                          const Color(0xff007AFF),
                          disabledBackgroundColor:
                          const Color(0xffE5E5EA),
                          shape: RoundedRectangleBorder(
                            borderRadius:
                            BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          "사진 선택",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 17,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  @override
  void dispose() {
    nameController.dispose();
    phoneController.dispose();
    storePhoneController.dispose();
    super.dispose();
  }

  Future<void> _loadProfile() async {
    final prefs = await SharedPreferences.getInstance();
    final imagePath = prefs.getString(EkeyProfileImage);
    if (imagePath != null && File(imagePath).existsSync()) {
      profileImage = File(imagePath);
    }
    // 근무자 기본값 설정
    nameController.text = prefs.getString(EkeyName) ?? "김세희";
    phoneController.text = prefs.getString(EkeyPhone) ?? "010-1234-5678";
    storePhoneController.text = prefs.getString(EkeyStorePhone) ?? "02-1234-5678";
    setState(() {});
  }

  Future<void> _saveProfile() async {
    final prefs = await SharedPreferences.getInstance();
    if (profileImage != null) await prefs.setString(EkeyProfileImage, profileImage!.path);
    await prefs.setString(EkeyName, nameController.text);
    await prefs.setString(EkeyPhone, phoneController.text);
    await prefs.setString(EkeyStorePhone, storePhoneController.text);

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("저장되었습니다."),
      ),
    );
  }

  Future<void> _showEditBottomSheet({
    required String title,
    required TextEditingController controller,
  }) async {
    final TextEditingController tempController =
    TextEditingController(text: controller.text);

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(24),
        ),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: StatefulBuilder(
            builder: (context, setState) {
              return SafeArea(
                top: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 10, 20, 24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      /// 드래그 바
                      Container(
                        width: 48,
                        height: 5,
                        decoration: BoxDecoration(
                          color: const Color(0xFFD9D9D9),
                          borderRadius: BorderRadius.circular(100),
                        ),
                      ),

                      const SizedBox(height: 22),

                      /// 제목 + 닫기 버튼
                      Stack(
                        alignment: Alignment.center,
                        children: [
                          Center(
                            child: Text(
                              "$title 변경",
                              style: const TextStyle(
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
                                width: 32,
                                height: 32,
                                decoration: const BoxDecoration(
                                  color: Color(0xFFF2F2F7),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.close,
                                  size: 20,
                                  color: Color(0xFF9A9AA2),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 24),

                      /// 입력창
                      TextField(
                        controller: tempController,
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Colors.white,
                          contentPadding:
                          const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 16,
                          ),
                          border: OutlineInputBorder(
                            borderRadius:
                            BorderRadius.circular(12),
                            borderSide: const BorderSide(
                              color: Color(0xFFE5E5EA),
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius:
                            BorderRadius.circular(12),
                            borderSide: const BorderSide(
                              color: Color(0xFFE5E5EA),
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius:
                            BorderRadius.circular(12),
                            borderSide: const BorderSide(
                              color: Color(0xFF0084FF),
                            ),
                          ),
                        ),
                        style: const TextStyle(
                          fontSize: 16,
                        ),
                      ),

                      const SizedBox(height: 28),

                      /// 저장 버튼
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton(
                          onPressed: () {
                            controller.text = tempController.text;
                            Navigator.pop(context);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                            const Color(0xFF007AFF),
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius:
                              BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text(
                            "저장",
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
              );
            },
          ),
        );
      },
    );

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 25,
              vertical: 35,
            ),
            child: Column(
              children: [

                /// Header
                SizedBox(
                  height: 30,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      /// 가운데 제목
                      const Center(
                        child: Text(
                          "프로필 변경",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),

                      /// 왼쪽 뒤로가기
                      Align(
                        alignment: Alignment.centerLeft,
                        child: InkWell(
                          onTap: () => Navigator.pop(context),
                          child: const Icon(
                            Icons.arrow_back_ios_new,
                            size: 22,
                          ),
                        ),
                      ),

                      /// 오른쪽 Edit / 저장
                      Align(
                        alignment: Alignment.centerRight,
                        child: GestureDetector(
                          onTap: () async {
                            if (isEditMode) {
                              await _saveProfile();
                            }

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
                            color: Colors.black,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 30),

                /// 프로필
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: const Color(0xFFA5A5AF),
                        borderRadius: BorderRadius.circular(24),
                        image: profileImage != null
                            ? DecorationImage(
                          image: FileImage(profileImage!),
                          fit: BoxFit.cover,
                        )
                            : null,
                      ),
                    ),

                    if (isEditMode)
                      Positioned(
                        right: -2,
                        bottom: -2,
                        child: InkWell(
                          onTap: _showGalleryBottomSheet,
                          child: Container(
                            width: 32,
                            height: 32,
                            decoration: const BoxDecoration(
                              color: Color(0xFFF1F1F5),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.photo_camera,
                              size: 18,
                              color: Color(0xFF767676),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),

                const SizedBox(height: 18),

                const Text(
                  "근무자",
                  style: TextStyle(
                    fontSize: 15,
                    color: Color(0xFF505050),
                  ),
                ),

                const SizedBox(height: 6),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [

                    Text(
                      nameController.text,
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
                      child: const Text(
                        "재직중",
                        style: TextStyle(
                          fontSize: 12,
                          color: Color(0xFF00315F),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 10),

                Wrap(
                  spacing: 8,
                  children: const [
                    ETagChip(text: "카운터"),
                    ETagChip(text: "마감불가"),
                  ],
                ),

                const SizedBox(height: 26),

                EInfoSectionCard(
                  title: "개인 정보",
                  isEditMode: isEditMode,
                  items: [
                    ["이름", nameController.text],
                    ["휴대폰 번호", phoneController.text],
                  ],
                ),

                const SizedBox(height: 16),

                EInfoSectionCard(
                  title: "소속 정보",
                  isEditMode: isEditMode,
                  items: const [
                    ["직급", "근무자"],
                    ["입사일", "2026년 4월 1일"],
                    ["재직 상태", "재직중"],
                  ],
                ),

                const SizedBox(height: 16),

                EInfoSectionCard(
                  title: "근무 정보",
                  isEditMode: isEditMode,
                  items: const [
                    ["근무 시간", "오전 09:00 - 오후 14:00"],
                    ["근무 요일", "월, 수, 금"],
                  ],
                ),

                const SizedBox(height: 16),

                EInfoSectionCard(
                  title: "소속 정보",
                  isEditMode: isEditMode,
                  items: const [
                    ["총 근무 일수", "16일"],
                    ["총 근무 시간", "80시간"],
                  ],
                ),

                const SizedBox(height: 16),

                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 20,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Row(
                    children: [
                      Expanded(
                        child: Text(
                          "지난달 급여 정보",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      Icon(Icons.chevron_right),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// 섹션
  Widget _buildSection({
    required String title,
    required List<_ProfileItem> items,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: 22,
        vertical: 10,
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: 20,
        vertical: 20,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              color: Color(0xFF999999),
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 36),

          for (int i = 0; i < items.length; i++) ...[
            Row(
              children: [
                Text(
                  items[i].title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const Spacer(),
                GestureDetector(
                  onTap: () {
                    final controller =
                    items[i].title == "이름"
                        ? nameController
                        : items[i].title == "휴대폰 번호"
                        ? phoneController
                        : storePhoneController;

                    _showEditBottomSheet(
                      title: items[i].title,
                      controller: controller,
                    );
                  },
                  child: Row(
                    children: [
                      Text(
                        items[i].title == "이름"
                            ? nameController.text
                            : items[i].title == "휴대폰 번호"
                            ? phoneController.text
                            : storePhoneController.text,
                        style: const TextStyle(
                          fontSize: 16,
                          color: Color(0xFF999999),
                        ),
                      ),
                      if (items[i].isArrow)
                        const Padding(
                          padding: EdgeInsets.only(left: 4),
                          child: Icon(
                            Icons.chevron_right,
                            color: Color(0xFF999999),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
            if (i != items.length - 1) ...[
              const SizedBox(height: 18),
              const Divider(height: 1, color: Color(0xFFF1F1F5),),
              const SizedBox(height: 18),
            ],
          ],
        ],
      ),
    );
  }

  Widget buildItem({
    required String title,
    required String value,
    bool divider = true,
  }) {
    return Column(
      children: [
        Row(
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
            const Spacer(),
            Text(
              value,
              style: const TextStyle(
                fontSize: 18,
                color: Color(0xff9B9B9B),
              ),
            ),
            const SizedBox(width: 6),
            const Icon(
              Icons.chevron_right,
              color: Color(0xffB5B5BC),
            ),
          ],
        ),
        if (divider)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 18),
            child: Divider(height: 1),
          ),
      ],
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