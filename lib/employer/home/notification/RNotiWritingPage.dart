import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'dart:io';
import 'dart:typed_data';
import 'package:photo_manager/photo_manager.dart';
import '../../../common/auth/server_token_manager.dart';
import '../../../common/image_upload/upload_image_normalizer.dart';
import '../../../common/onboarding/providers/signup_provider.dart';
import '../../../common/widgets/BottomNavBar.dart';
import '../../crews/RCrewPage.dart';
import '../../mypage/RMyPage.dart';
import '../RHomePage.dart';
import 'RNotificationNotifier.dart';
import 'RNotificationModel.dart';
import 'package:dio/dio.dart';
import 'package:kakao_flutter_sdk_user/kakao_flutter_sdk_user.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'api/notice_api.dart';
import 'api/notice_upload_service.dart';

class RNotiWritingPage extends ConsumerStatefulWidget {
  const RNotiWritingPage({super.key});

  @override
  ConsumerState<RNotiWritingPage> createState() => _RNotiWritingPageState();
}

class _RNotiWritingPageState extends ConsumerState<RNotiWritingPage> {
  final TextEditingController titleController = TextEditingController();
  final TextEditingController contentController = TextEditingController();

  File? selectedImage;

  late final NoticeUploadService uploadService;
  late NoticeApi noticeApi;

  // [수정] 등록 요청이 진행 중인지 추적하는 플래그.
  // 이게 true인 동안에는 버튼을 눌러도 _registerNotice()가 다시 실행되지 않는다.
  bool _isSubmitting = false;

  Future<void> _registerNotice() async {
    // [수정] 이미 등록 요청이 진행 중이면 즉시 리턴 — 중복 실행 방지의 핵심 가드.
    // 네트워크 렉으로 버튼이 n번 눌려도 첫 호출만 실제로 진행된다.
    if (_isSubmitting) return;

    setState(() => _isSubmitting = true);

    try {
      final accessToken = await ServerTokenManager.getValidAccessToken();

      if (accessToken == null || accessToken.isEmpty) {
        throw Exception("로그인이 필요합니다.");
      }

      final prefs = await SharedPreferences.getInstance();
      final workPlaceId = prefs.getInt("selectedWorkPlaceId");

      if (workPlaceId == null) {
        throw Exception("근무지 정보를 찾을 수 없습니다. 다시 로그인해주세요.");
      }

      if (titleController.text.trim().isEmpty) {
        throw Exception("제목을 입력해주세요.");
      }
      if (contentController.text.trim().isEmpty) {
        throw Exception("내용을 입력해주세요.");
      }

      List<String> imageObjectKeys = [];

      debugPrint("=== _registerNotice 시작 ===");
      debugPrint("selectedImage: ${selectedImage?.path}");

      //---------------------------------------------------
      // 1. 이미지가 있으면 업로드 URL 발급 → S3 업로드
      //---------------------------------------------------
      if (selectedImage != null) {
        final uploadInfo = await uploadService.getUploadUrl(
          workPlaceId: workPlaceId,
          token: accessToken,
          file: selectedImage!,
        );

        debugPrint("uploadInfo: $uploadInfo");

        await uploadService.uploadImageToS3(
          uploadInfo: uploadInfo,
          file: selectedImage!,
        );

        debugPrint("S3 업로드 완료");

        imageObjectKeys.add(uploadInfo["objectKey"]);

        debugPrint("imageObjectKeys: $imageObjectKeys");
      } else {
        debugPrint("selectedImage가 null이라 이미지 업로드 스킵");
      }

      //---------------------------------------------------
      // 2. 공지 등록
      //---------------------------------------------------
      debugPrint("createNotice 호출 직전 imageObjectKeys: $imageObjectKeys");

      final response = await noticeApi.createNotice(
        workPlaceId: workPlaceId,
        accessToken: accessToken,
        title: titleController.text.trim(),
        content: contentController.text.trim(),
        representative: true,
        imageObjectKeys: imageObjectKeys,
      );

      debugPrint("========== NOTICE 응답 ==========");
      debugPrint(response.data.toString());

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("공지가 등록되었습니다.")),
      );

      Navigator.pop(context);
      Navigator.pop(context);
    } on DioException catch (e) {
      debugPrint("🔴 DioException: ${e.response?.statusCode}");
      debugPrint("🔴 응답 데이터: ${e.response?.data}");

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.response?.data.toString() ?? "등록 실패")),
      );
    } catch (e, stack) {
      debugPrint("🔴 일반 예외: $e");
      debugPrint("스택: $stack");

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    } finally {
      // [수정] 성공/실패/예외 등 어떤 경로로 끝나도 반드시 플래그를 되돌린다.
      // 성공 시에는 화면이 pop되므로 큰 의미는 없지만,
      // 실패 시(같은 화면에 머무르는 경우)에는 이게 없으면 버튼이 영구히 잠긴다.
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  Future<void> _showGalleryBottomSheet() async {
    // 1. 권한 요청 및 확인
    final PermissionState ps = await PhotoManager.requestPermissionExtend();

    // 권한이 거부된 경우 설정창 안내 등
    if (!ps.isAuth && ps != PermissionState.limited) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('갤러리 접근 권한이 필요합니다. 설정에서 허용해주세요.')),
        );
      }
      return;
    }

    // 2. 앨범 목록 가져오기 (전체 사진 포함)
    final List<AssetPathEntity> albums = await PhotoManager.getAssetPathList(
      type: RequestType.image,
      onlyAll: true,
    );

    if (albums.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('불러올 사진이 없습니다.')),
        );
      }
      return;
    }

    final AssetPathEntity recentAlbum = albums.first;
    final List<AssetEntity> images = await recentAlbum.getAssetListPaged(
      page: 0,
      size: 100,
    );

    // 사진 최신 -> 오래된 순
    images.sort(
          (a, b) => b.createDateTime.compareTo(a.createDateTime),
    );

    if (!mounted) return;

    // 바텀 시트 내부에서 선택된 이미지를 추적하기 위한 변수
    AssetEntity? tempSelectedAsset;

    // 3. 바텀 시트 띄우기
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(28),
        ),
      ),
      builder: (context) {
        AssetEntity? tempSelectedAsset;

        return StatefulBuilder(
          builder: (context, setModalState) {
            return SizedBox(
              height: MediaQuery.of(context).size.height * 0.7,
              child: Column(
                children: [
                  const SizedBox(height: 12),

                  /// 상단 드래그 바
                  Container(
                    width: 50,
                    height: 5,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),

                  const SizedBox(height: 12),

                  /// 제목 + 닫기 버튼
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: SizedBox(
                      height: 44,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          const Center(
                            child: Text(
                              '최근 항목',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),

                          Positioned(
                            right: 0,
                            child: GestureDetector(
                              onTap: () {
                                Navigator.pop(context);
                              },
                              child: Container(
                                width: 30,
                                height: 30,
                                decoration: const BoxDecoration(
                                  color: Color(0xFFF2F2F7),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.close,
                                  color: Colors.grey,
                                  size: 20,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 10),

                  Expanded(
                    child: images.isEmpty
                        ? const Center(
                      child: Text('사진이 없습니다.'),
                    )
                        : GridView.builder(
                      padding: EdgeInsets.zero,
                      itemCount: images.length + 1,
                      gridDelegate:
                      const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        crossAxisSpacing: 2,
                        mainAxisSpacing: 2,
                      ),
                      itemBuilder: (context, index) {
                        /// 첫 번째 셀 = 카메라
                        if (index == 0) {
                          return Container(
                            color: const Color(0xFFE5E5EA),
                            child: const Center(
                              child: Icon(
                                Icons.camera_alt_outlined,
                                size: 34,
                                color: Colors.white,
                              ),
                            ),
                          );
                        }

                        final asset = images[index - 1];
                        final isSelected =
                            tempSelectedAsset?.id == asset.id;

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
                                  tempSelectedAsset = asset;
                                });
                              },
                              child: Container(
                                decoration: BoxDecoration(
                                  border: isSelected
                                      ? Border.all(
                                    color: Colors.blue,
                                    width: 3,
                                  )
                                      : null,
                                ),
                                child: Stack(
                                  children: [
                                    Positioned.fill(
                                      child: Image.memory(
                                        snapshot.data!,
                                        fit: BoxFit.cover,
                                      ),
                                    ),

                                    /// 체크박스
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
                                          border: Border.all(
                                            color: Colors.grey.shade300,
                                          ),
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
                      height: 56,
                      child: ElevatedButton(
                        onPressed: tempSelectedAsset == null
                            ? null
                            : () async {
                          final file =
                          await UploadImageNormalizer.normalizeAssetForUpload(tempSelectedAsset!);

                          if (file != null) {
                            setState(() {
                              selectedImage = file;
                            });

                            if (mounted) {
                              Navigator.pop(context);
                            }
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF007AFF),
                          disabledBackgroundColor:
                          const Color(0xFFE5E5EA),
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius:
                            BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          '사진 선택',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
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

  Future<void> _showRegisterBottomSheet() async {
    if (titleController.text.trim().isEmpty ||
        contentController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('제목과 내용을 모두 입력해주세요.'),
        ),
      );
      return;
    }

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      // [수정] 등록 요청이 진행 중일 때는 바텀시트를 손가락으로 내려서
      // 닫아버릴 수 없도록 막는다 (요청이 붕 뜬 채로 남는 것 방지).
      isDismissible: !_isSubmitting,
      enableDrag: !_isSubmitting,
      builder: (context) {
        // [수정] StatefulBuilder로 감싸서, 바텀시트 안에서도
        // _isSubmitting 값 변화(버튼 비활성화/로딩 표시)를 즉시 반영한다.
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              padding: const EdgeInsets.fromLTRB(
                24,
                16,
                24,
                30,
              ),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(
                  top: Radius.circular(28),
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [

                  Container(
                    width: 50,
                    height: 5,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),

                  const SizedBox(height: 28),

                  const Text(
                    '공지글을 등록하시겠습니까?',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 28),

                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      // [수정] 이미 제출 중이면 onPressed를 null로 만들어
                      // 버튼 자체를 비활성화한다. 이게 중복 클릭을 막는
                      // 두 번째 안전장치(첫 번째는 _registerNotice 내부 가드).
                      onPressed: _isSubmitting
                          ? null
                          : () async {
                        // 바텀시트 쪽 로딩 표시를 위해 모달 내부 상태도 갱신
                        setModalState(() {});
                        await _registerNotice();
                        // 실패해서 바텀시트가 아직 떠 있는 상태로 남아있다면
                        // 로딩 표시를 원래대로 되돌린다.
                        if (context.mounted) {
                          setModalState(() {});
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0084FF),
                        disabledBackgroundColor: const Color(0xFFA9D0FB),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: _isSubmitting
                          ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2.5,
                        ),
                      )
                          : const Text(
                        '등록하기',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 18),

                  TextButton(
                    // [수정] 제출 중에는 취소도 못 누르게 막아서
                    // 요청이 진행 중인데 바텀시트만 닫히는 상황을 방지
                    onPressed: _isSubmitting
                        ? null
                        : () {
                      Navigator.pop(context);
                    },
                    child: Text(
                      '취소',
                      style: TextStyle(
                        fontSize: 16,
                        color: _isSubmitting ? Colors.grey : Colors.black,
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

    noticeApi = NoticeApi(ServerTokenManager.authorizedDio);
    uploadService = NoticeUploadService(ServerTokenManager.authorizedDio);
  }

  @override
  void dispose() {
    titleController.dispose();
    contentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: true,
      bottomNavigationBar: BottomNavBar(
        currentIndex: 0,
        onTap: (index) {
          if (index == 0) {
            Navigator.push(
                context, MaterialPageRoute(builder: (_) => const RHomePage()));
          } else if (index == 1) {
            Navigator.push(
                context, MaterialPageRoute(builder: (_) => const RCrewPage()));
          } else if (index == 4) {
            Navigator.push(
                context, MaterialPageRoute(builder: (_) => const RMyPage()));
          }
        },
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: const Icon(
                      Icons.arrow_back_ios_new,
                      size: 22,
                    ),
                  ),
                  Row(
                    children: [
                      IconButton(
                        onPressed: () async {
                          await _showGalleryBottomSheet();
                        },
                        icon: const Icon(
                          Icons.image_outlined,
                          size: 28,
                        ),
                      ),
                      const SizedBox(width: 8),
                      SizedBox(
                        width: 88,
                        height: 40,
                        child: ElevatedButton(
                          onPressed: () {
                            _showRegisterBottomSheet();
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFE6F3FF),
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: const Text(
                            '등록',
                            style: TextStyle(
                              color: Color(0xFF0063BF),
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Expanded(
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 10),

                        TextField(
                          controller: titleController,
                          decoration: const InputDecoration(
                            hintText: '제목을 입력해주세요',
                            border: InputBorder.none,
                            hintStyle: TextStyle(
                              fontSize: 20,
                              color: Color(0xFF999999),
                            ),
                          ),
                          style: const TextStyle(
                            fontSize: 20,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  Divider(
                    color: Colors.grey.shade300,
                    thickness: 1,
                    height: 1,
                  ),
                  const SizedBox(height: 20),
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [

                          TextField(
                            controller: contentController,
                            maxLines: null,
                            decoration: const InputDecoration(
                              hintText: '공지내용을 입력해 주세요',
                              border: InputBorder.none,
                              hintStyle: TextStyle(
                                fontSize: 16,
                                color: Color(0xFF999999),
                              ),
                            ),
                            style: const TextStyle(
                              fontSize: 16,

                            ),
                          ),

                          const SizedBox(height: 20),

                          if (selectedImage != null)
                            Stack(
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: Image.file(
                                    selectedImage!,
                                    width: double.infinity,
                                    fit: BoxFit.cover,
                                  ),
                                ),

                                Positioned(
                                  top: 10, right: 10,
                                  child: GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        selectedImage = null;
                                      });
                                    },
                                    child: Container(width: 32, height: 32,
                                      decoration: BoxDecoration(
                                        color: Colors.grey.shade200,
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(
                                        Icons.close,
                                        color: Colors.black,
                                        size: 18,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                        ],
                      ),
                    ),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}