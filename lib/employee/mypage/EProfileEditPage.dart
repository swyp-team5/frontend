import 'dart:io';

import 'package:chack_chack/employee/mypage/widgets/EInfoSectionCard.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import 'dart:typed_data';
import 'package:photo_manager/photo_manager.dart';

import '../../employer/mypage/api/profile_api.dart';

import '../../../common/auth/server_token_manager.dart';
import '../../../common/image_upload/upload_image_normalizer.dart';
import 'package:dio/dio.dart';

class EProfileEditPage extends StatefulWidget {

  const EProfileEditPage({super.key});

  @override
  State<EProfileEditPage> createState() => _EProfileEditPageState();
}

class _EProfileEditPageState extends State<EProfileEditPage> {

  late final Dio dio;
  late final ProfileApi profileApi;

  bool isEditMode = false;

  String? profileImageUrl;

  final ImagePicker picker = ImagePicker();

  final TextEditingController nameController = TextEditingController();

  final TextEditingController phoneController = TextEditingController();

  final TextEditingController storePhoneController = TextEditingController();

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

      final headers =
      Map<String, String>.from(uploadInfo["headers"]);

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

  /// 최근 항목 목록을 (재)조회한다. "다른 사진 선택"으로 허용 목록이
  /// 바뀐 뒤 다시 불러올 때도 재사용한다.
  Future<List<AssetEntity>> _fetchRecentImages() async {
    final List<AssetPathEntity> albums = await PhotoManager.getAssetPathList(
      type: RequestType.image,
      onlyAll: true,
      // 정렬 옵션을 안 주면 기기 기본 순서(최신순이 아닐 수 있음)로 오기 때문에,
      // 페이징으로 100장만 잘라오기 전에 최신순 정렬을 명시적으로 지정한다.
      filterOption: FilterOptionGroup(
        orders: [
          const OrderOption(type: OrderOptionType.createDate, asc: false),
        ],
      ),
    );

    if (albums.isEmpty) return [];

    final List<AssetEntity> images = await albums.first.getAssetListPaged(
      page: 0,
      size: 300,
    );

    return images;
  }

  /// 프로필 이미지 선택
  Future<void> _showGalleryBottomSheet() async {
    final PermissionState ps =
    await PhotoManager.requestPermissionExtend();

    // 거부된 상태: 기기 설정으로 안내한다.
    if (!ps.isAuth && ps != PermissionState.limited) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text("갤러리 접근 권한이 필요합니다. 설정에서 허용해주세요."),
            action: SnackBarAction(
              label: "설정으로 이동",
              onPressed: () => PhotoManager.openSetting(),
            ),
          ),
        );
      }
      return;
    }

    final bool isLimited = ps == PermissionState.limited;
    final List<AssetEntity> initialImages = await _fetchRecentImages();

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
        List<AssetEntity> currentImages = initialImages;
        bool isConfirming = false;

        return StatefulBuilder(
          builder: (context, setModalState) {
            // 제한된 접근 상태에서 허용 목록에 사진을 추가로 선택하는
            // 시스템 화면을 다시 띄운 뒤, 새로 허용된 사진을 반영해서
            // 최근 항목을 다시 조회한다.
            Future<void> pickMorePhotos() async {
              await PhotoManager.presentLimited();
              final refreshed = await _fetchRecentImages();
              if (!context.mounted) return;
              setModalState(() {
                currentImages = refreshed;
              });
            }

            Future<void> confirmSelection() async {
              if (selectedAsset == null || isConfirming) return;

              setModalState(() => isConfirming = true);

              final file = await UploadImageNormalizer.normalizeAssetForUpload(
                selectedAsset!,
              );

              if (file == null) {
                setModalState(() => isConfirming = false);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        "이 사진을 불러올 수 없어요. 다른 사진을 선택하거나 잠시 후 다시 시도해주세요.",
                      ),
                    ),
                  );
                }
                return;
              }

              await updateProfileImage(file);

              if (context.mounted) {
                Navigator.pop(context);
              }
            }

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

                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const SizedBox(width: 64),
                        const Text(
                          "최근 항목",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(
                          width: 64,
                          child: isLimited
                              ? Align(
                                  alignment: Alignment.centerRight,
                                  child: TextButton(
                                    onPressed: pickMorePhotos,
                                    child: const Text(
                                      "다른 사진",
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                        color: Color(0xFF007AFF),
                                      ),
                                    ),
                                  ),
                                )
                              : const SizedBox(),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  Expanded(
                    child: currentImages.isEmpty
                        ? const Center(child: Text("표시할 사진이 없어요."))
                        : GridView.builder(
                      padding: EdgeInsets.zero,
                      itemCount: currentImages.length,
                      gridDelegate:
                      const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        crossAxisSpacing: 2,
                        mainAxisSpacing: 2,
                      ),
                      itemBuilder: (context, index) {
                        final asset = currentImages[index];

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
                                  // 이미 선택된 사진을 다시 누르면 선택 해제
                                  selectedAsset = isSelected ? null : asset;
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
                        onPressed: (selectedAsset == null || isConfirming)
                            ? null
                            : confirmSelection,
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
                        child: isConfirming
                            ? const SizedBox(
                                width: 22, height: 22,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Text(
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

    dio = ServerTokenManager.authorizedDio;
    profileApi = ProfileApi(dio);

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
    try {
      final token = await ServerTokenManager.getValidAccessToken();

      if (token == null) return;

      final profile =
      await profileApi.getMyProfile(
        token: token,
      );

      nameController.text =
          profile["name"] ?? "";

      phoneController.text =
          profile["phoneNumber"] ?? "";

      profileImageUrl =
      profile["profileImage"]?["imageUrl"];

      if (!mounted) return;

      setState(() {});
    } on DioException catch (e) {
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

      await profileApi.updateProfile(
        token: token,
        name: trimmedName,
        phoneNumber: normalizedPhone,
      );

      final profile = await profileApi.getMyProfile(
        token: token,
      );

      nameController.text =
          profile["name"] ?? "";

      phoneController.text =
          profile["phoneNumber"] ?? "";

      profileImageUrl =
      profile["profileImage"]?["imageUrl"];

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
      debugPrint("${e.response?.statusCode}");
      debugPrint("${e.response?.data}");

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
        SnackBar(
          content: Text(e.toString()),
        ),
      );
    }
  }

  Future<void> _showEditBottomSheet({
    required String title,
    required TextEditingController controller,
  }) async {
    final TextEditingController tempController = TextEditingController(text: controller.text);

    bool isChanged = false;

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
                        onChanged: (value) {
                          setState(() {
                            isChanged =
                                value.trim().isNotEmpty &&
                                    value.trim() != controller.text;
                          });
                        },
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: isChanged
                              ? Colors.white
                              : const Color(0xFFF2F2F7),
                          hintText: "변경할 $title을 입력해주세요",
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(
                              color: Color(0xFF007AFF),
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 28),

                      /// 저장 버튼
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton(
                          onPressed: isChanged
                              ? () {
                            controller.text = tempController.text.trim();
                            Navigator.pop(context);

                            this.setState(() {}); // 부모 화면 갱신
                          }
                              : null,
                          style: ElevatedButton.styleFrom(
                            elevation: 0,
                            backgroundColor: isChanged
                                ? const Color(0xFF007AFF)
                                : const Color(0xFFB7D8F8),
                            disabledBackgroundColor:
                            const Color(0xFFB7D8F8),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
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
                        onTap: _showGalleryBottomSheet,
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
                  ],
                ),

                const SizedBox(height: 30),

                EInfoSectionCard(
                  title: "개인 정보",
                  isEditMode: isEditMode,
                  items: [
                    ["이름", nameController.text],
                    ["휴대폰 번호", phoneController.text],
                  ],
                  onItemTap: (index) {
                    if (index == 0) {
                      _showEditBottomSheet(
                        title: "이름",
                        controller: nameController,
                      );
                    } else if (index == 1) {
                      _showEditBottomSheet(
                        title: "휴대폰 번호",
                        controller: phoneController,
                      );
                    }
                  },
                ),
              ],
            ),
          ),
        ),
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
