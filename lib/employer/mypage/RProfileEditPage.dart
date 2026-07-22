import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import 'dart:typed_data';

import '../../common/auth/server_token_manager.dart';
import '../../common/image_upload/upload_image_normalizer.dart';
import 'RWorkPlaceSettingPage.dart';
import 'api/profile_api.dart';
import 'package:dio/dio.dart';

class RProfileEditPage extends StatefulWidget {

  const RProfileEditPage({super.key});

  @override
  State<RProfileEditPage> createState() => _RProfileEditPageState();
}

class _RProfileEditPageState extends State<RProfileEditPage> {
  String? profileImageUrl;

  late final Dio dio;
  late final ProfileApi profileApi;

  final TextEditingController nameController = TextEditingController();

  final TextEditingController phoneController = TextEditingController();


  Future<void> updateProfileImage(File file) async {
    try {
      final token = await ServerTokenManager.getValidAccessToken();

      if (token == null) {
        throw Exception("로그인이 필요합니다.");
      }

      // 명세서 15.3: fileSize는 10MB 이하만 허용. 서버까지 안 가고 미리 걸러낸다.
      final fileSize = await file.length();
      if (fileSize > 10 * 1024 * 1024) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("이미지 용량은 10MB를 넘을 수 없어요.")),
        );
        return;
      }

      final uploadInfo =
      await profileApi.getUploadUrl(
        token: token,
        file: file,
      );

      final uploadUrl = uploadInfo["uploadUrl"];
      final objectKey = uploadInfo["objectKey"];

      final headers = Map<String, String>.from(
        uploadInfo["headers"],
      );

      final bytes = await file.readAsBytes();

      await profileApi.uploadToS3(
        uploadUrl: uploadUrl,
        headers: headers,
        bytes: bytes,
      );

      await profileApi.updateProfileImage(
        token: token,
        objectKey: objectKey,
      );

      final profile =
      await profileApi.getMyProfile(
        token: token,
      );

      profileImageUrl =
      profile["profileImage"]?["imageUrl"];

      if (!mounted) return;

      setState(() {});

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("프로필 이미지가 변경되었습니다."),
        ),
      );
    } on DioException catch (e) {
      debugPrint(
        "🔴 [updateProfileImage] DioException: "
        "status=${e.response?.statusCode}, data=${e.response?.data}",
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _profileImageErrorMessage(e.response?.statusCode, e.response?.data),
          ),
        ),
      );
    } catch (e) {
      debugPrint(e.toString());

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString().replaceFirst("Exception: ", ""))),
      );
    }
  }

  // 서버가 내려주는 raw 메시지/코드 대신, 사용자가 이해하기 쉬운 문구로 바꿔서 보여준다.
  // (15.3 업로드 URL 발급 / 15.5 업로드 확정 기준)
  String _profileImageErrorMessage(int? statusCode, dynamic data) {
    final serverMessage = (data is Map) ? data["message"]?.toString() : null;

    switch (statusCode) {
      case 400:
        return serverMessage ?? "이미지 파일을 확인해주세요. (jpg/png/webp, 최대 10MB)";
      case 401:
        return "로그인이 만료됐어요. 다시 로그인해주세요.";
      case 403:
        return "이 이미지를 등록할 권한이 없어요.";
      case 404:
        return "업로드 정보를 찾을 수 없어요. 처음부터 다시 시도해주세요.";
      default:
        return "프로필 이미지 변경에 실패했어요. 잠시 후 다시 시도해주세요.";
    }
  }

  Future<void> deleteProfileImage() async {
    try {
      final token = await ServerTokenManager.getValidAccessToken();

      if (token == null) {
        throw Exception("로그인이 필요합니다.");
      }

      await profileApi.deleteProfileImage(
        token: token,
      );

      final profile = await profileApi.getMyProfile(
        token: token,
      );

      profileImageUrl = profile["profileImage"]?["imageUrl"];

      if (!mounted) return;

      setState(() {});

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("프로필 이미지가 삭제되었습니다."),
        ),
      );
    } on DioException catch (e) {
      debugPrint(
        "🔴 [deleteProfileImage] DioException: "
        "status=${e.response?.statusCode}, data=${e.response?.data}",
      );

      if (!mounted) return;

      final serverMessage = (e.response?.data is Map)
          ? e.response?.data["message"]?.toString()
          : null;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            e.response?.statusCode == 401
                ? "로그인이 만료됐어요. 다시 로그인해주세요."
                : (serverMessage ?? "프로필 이미지 삭제에 실패했어요. 잠시 후 다시 시도해주세요."),
          ),
        ),
      );
    } catch (e) {
      debugPrint(e.toString());

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString().replaceFirst("Exception: ", ""))),
      );
    }
  }

  // /// 최근 항목 목록을 (재)조회한다. "다른 사진 선택"으로 허용 목록이
  // /// 바뀐 뒤 다시 불러올 때도 재사용한다.
  // Future<List<AssetEntity>> _fetchRecentImages() async {
  //   final List<AssetPathEntity> albums = await PhotoManager.getAssetPathList(
  //     type: RequestType.image,
  //     onlyAll: true,
  //     // 정렬 옵션을 안 주면 기기 기본 순서(최신순이 아닐 수 있음)로 오기 때문에,
  //     // 페이징으로 100장만 잘라오기 전에 최신순 정렬을 명시적으로 지정한다.
  //     filterOption: FilterOptionGroup(
  //       orders: [
  //         const OrderOption(type: OrderOptionType.createDate, asc: false),
  //       ],
  //     ),
  //   );
  //
  //   if (albums.isEmpty) return [];
  //
  //   final List<AssetEntity> images = await albums.first.getAssetListPaged(
  //     page: 0,
  //     size: 300,
  //   );
  //
  //   return images;
  // }

  /// 프로필 이미지 선택
  Future<void> _pickProfileImage() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? pickedFile = await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
      );

      if (pickedFile == null) return;

      final rawFile = File(pickedFile.path);
      final normalizedFile = await UploadImageNormalizer.normalizeFileForUpload(rawFile);

      if (normalizedFile == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('이 사진을 불러올 수 없어요. 다른 사진을 선택해주세요.')),
          );
        }
        return;
      }

      await updateProfileImage(normalizedFile);
    } catch (e) {
      debugPrint("🔴 [pickProfileImage] 예외: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('사진을 불러오지 못했습니다. 다시 시도해주세요.')),
        );
      }
    }
  }

  @override
  void initState() {
    super.initState();

    dio = ServerTokenManager.authorizedDio;
    profileApi = ProfileApi(dio);

    _loadProfile();
  }

  @override
  void dispose() {
    nameController.dispose();
    phoneController.dispose();
    super.dispose();
  }

  Future<void> _loadProfile() async {
    try {
      final token = await ServerTokenManager.getValidAccessToken();

      debugPrint("GET TOKEN = $token");

      if (token == null) return;

      final data = await profileApi.getMyProfile(
        token: token,
      );

      debugPrint("GET SUCCESS");
      debugPrint(data.toString());

      nameController.text = data["name"] ?? "";
      phoneController.text = data["phoneNumber"] ?? "";
      profileImageUrl = data["profileImage"]?["imageUrl"];

      setState(() {});
    } on DioException catch (e) {
      debugPrint("========== GET ERROR ==========");
      debugPrint("StatusCode : ${e.response?.statusCode}");
      debugPrint("Response : ${e.response?.data}");
      debugPrint("Message : ${e.message}");
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  Future<void> _saveProfile() async {
    try {
      final token = await ServerTokenManager.getValidAccessToken();

      if (token == null) {
        throw Exception("로그인이 필요합니다.");
      }

      final trimmedName = nameController.text.trim();
      // 명세서 15.2: 휴대폰 번호는 클라이언트에서 하이픈 없는 11자리 숫자로 정규화해서 보낸다.
      final normalizedPhone =
          phoneController.text.replaceAll(RegExp(r'[^0-9]'), '');

      if (trimmedName.isEmpty || trimmedName.length > 10) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("이름은 1~10자로 입력해주세요.")),
        );
        return;
      }

      if (normalizedPhone.length != 11) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("휴대폰 번호는 숫자 11자리로 입력해주세요.")),
        );
        return;
      }

      // 프로필 수정
      await profileApi.updateProfile(
        token: token,
        name: trimmedName,
        phoneNumber: normalizedPhone,
      );

      // 서버에서 최신 정보 다시 조회
      final profile = await profileApi.getMyProfile(
        token: token,
      );

      nameController.text = profile["name"] ?? "";
      phoneController.text = profile["phoneNumber"] ?? "";
      profileImageUrl = profile["profileImage"]?["imageUrl"];

      if (!mounted) return;

      setState(() {});

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("프로필이 수정되었습니다."),
        ),
      );

      Navigator.pop(context, true);
    } on DioException catch (e) {
      debugPrint("========== DIO ERROR ==========");
      debugPrint("StatusCode : ${e.response?.statusCode}");
      debugPrint("Response : ${e.response?.data}");
      debugPrint("Message : ${e.message}");

      if (!mounted) return;

      final data = e.response?.data;
      final serverMessage = (data is Map) ? data["message"]?.toString() : null;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            serverMessage ?? "프로필 수정에 실패했어요. 잠시 후 다시 시도해주세요.",
          ),
        ),
      );
    } catch (e) {
      debugPrint(e.toString());

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString().replaceFirst("Exception: ", ""))),
      );
    }
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
      backgroundColor:
      const Color(0xFFF5F5F5),

      body: SafeArea(
        child: SingleChildScrollView(

          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,

            children: [

              /// 상단 헤더
              Padding(
                padding: const EdgeInsets.fromLTRB(30, 30, 20, 0),
                child: SizedBox(
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

                      /// 오른쪽 저장 버튼
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: () async {
                            await _saveProfile();
                          },
                          style: TextButton.styleFrom(
                            padding: EdgeInsets.zero,
                            minimumSize: Size.zero,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                          child: const Text(
                            "저장",
                            style: TextStyle(
                              fontSize: 16,
                              color: Color(0xFF767676),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              /// 프로필 영역
              Center(
                child: Column(
                  children: [
                    const SizedBox(height: 32),

                    Stack(
                      clipBehavior: Clip.none,
                      children: [

                        Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            color: const Color(0xFFA5A5AF),
                            borderRadius: BorderRadius.circular(24),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(24),
                            child: profileImageUrl != null
                                ? Image.network(
                              profileImageUrl!,
                              fit: BoxFit.cover,
                            )
                                : Image.asset(
                              "assets/images/profile.png",
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),

                        // 삭제 버튼 (X)
                        if (profileImageUrl != null)
                          Positioned(
                            top: -6,
                            right: -6,
                            child: InkWell(
                              onTap: () async {
                                final result = await showDialog<bool>(
                                  context: context,
                                  builder: (_) => AlertDialog(
                                    title: const Text("프로필 이미지 삭제"),
                                    content: const Text("프로필 이미지를 삭제하시겠습니까?"),
                                    actions: [
                                      TextButton(
                                        onPressed: () =>
                                            Navigator.pop(context, false),
                                        child: const Text("취소"),
                                      ),
                                      TextButton(
                                        onPressed: () =>
                                            Navigator.pop(context, true),
                                        child: const Text("삭제"),
                                      ),
                                    ],
                                  ),
                                );

                                if (result == true) {
                                  await deleteProfileImage();
                                }
                              },
                              child: Container(
                                width: 26,
                                height: 26,
                                decoration: BoxDecoration(
                                  color: Colors.red,
                                  shape: BoxShape.circle,
                                  border: Border.all(color: Colors.white),
                                ),
                                child: const Icon(
                                  Icons.close,
                                  size: 16,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),

                        // 카메라 버튼
                        Positioned(
                          right: -2,
                          bottom: -2,
                          child: InkWell(
                            onTap: _pickProfileImage,
                            child: Container(
                              width: 34,
                              height: 34,
                              decoration: BoxDecoration(
                                color: const Color(0xFFF1F1F5),
                                shape: BoxShape.circle,
                                border: Border.all(color: Colors.white),
                              ),
                              child: const Icon(
                                Icons.photo_camera,
                                size: 18,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 14),

                    const Text(
                      "사장님",
                      style: TextStyle(
                        fontSize: 15,
                        color: Color(0xFF505050),
                      ),
                    ),

                    const SizedBox(height: 6),

                    Text(
                      nameController.text,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),

              /// 개인 정보
              const SizedBox(height: 30),

              _buildSection(
                title: "통합 개인 정보",
                items: const [
                  _ProfileItem(title: "이름"),
                  _ProfileItem(title: "휴대폰 번호"),
                ],
              ),

              _buildStoreSetting(),
              const SizedBox(height: 30),
            ],
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
                        : phoneController;

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
                            : phoneController.text,
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


  Widget _buildStoreSetting() {
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
          const Text(
            "매장설정",
            style: TextStyle(
              fontSize: 16,
              color: Color(0xFF999999),
              fontWeight: FontWeight.w700,
            ),
          ),

          const SizedBox(height: 36),

          InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const RWorkPlaceSettingPage(),
                ),
              );
            },
            child: const Row(
              children: [
                Text(
                  "매장 설정",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Spacer(),
                Icon(
                  Icons.chevron_right,
                  color: Color(0xFF999999),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileItem {
  final String title;
  final bool isArrow;

  const _ProfileItem({
    required this.title,
    this.isArrow = true,
  });
}
