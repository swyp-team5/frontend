import 'dart:io';
import 'dart:typed_data';

import 'package:chack_chack/employer/home/notification/widgets/NoticeImageCacheBuster.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:dio/dio.dart';

import '../../../common/auth/server_token_manager.dart';
import '../../../common/image_upload/upload_image_normalizer.dart';
import 'RNotificationModel.dart';
import 'RNotificationNotifier.dart';
import 'api/notice_api.dart';
import 'api/notice_upload_service.dart';

class RNotiEditPage extends ConsumerStatefulWidget {
  final NoticeModel notice;

  const RNotiEditPage({
    super.key,
    required this.notice,
  });

  @override
  ConsumerState<RNotiEditPage> createState() => _RNotiEditPageState();
}

class _RNotiEditPageState extends ConsumerState<RNotiEditPage> {
  late TextEditingController titleController;
  late TextEditingController contentController;

  late final NoticeApi noticeApi;
  late final NoticeUploadService uploadService;

  /// 새로 갤러리에서 고른 로컬 이미지 (없으면 null)
  File? newSelectedImage;

  /// 기존에 서버에 저장돼 있던 대표 이미지 (없으면 null)
  NoticeImage? existingImage;

  /// 사용자가 이미지를 완전히 제거했는지 여부
  bool imageRemoved = false;

  bool isSubmitting = false;

  @override
  void initState() {
    super.initState();

    titleController = TextEditingController(text: widget.notice.title);
    contentController = TextEditingController(text: widget.notice.content);

    existingImage =
    widget.notice.images.isNotEmpty ? widget.notice.images.first : null;

    noticeApi = NoticeApi(ServerTokenManager.authorizedDio);
    uploadService = NoticeUploadService(ServerTokenManager.authorizedDio);
  }

  @override
  void dispose() {
    titleController.dispose();
    contentController.dispose();
    super.dispose();
  }

  /// 현재 화면에 보여줄 이미지가 있는지
  bool get _hasDisplayableImage =>
      newSelectedImage != null || (existingImage != null && !imageRemoved);

  Future<void> _updateNotice() async {
    setState(() => isSubmitting = true);

    try {
      final accessToken = await ServerTokenManager.getValidAccessToken();

      if (accessToken == null || accessToken.isEmpty) {
        throw Exception("로그인이 필요합니다.");
      }

      List<String> imageObjectKeys = [];

      debugPrint("=== _updateNotice 시작 ===");
      debugPrint("newSelectedImage: ${newSelectedImage?.path}");
      debugPrint("existingImage: ${existingImage?.objectKey}");
      debugPrint("imageRemoved: $imageRemoved");

      if (newSelectedImage != null) {
        // 1) 새 이미지를 새로 선택한 경우 → 업로드 후 objectKey 사용
        final uploadInfo = await uploadService.getUploadUrl(
          workPlaceId: widget.notice.workPlaceId,
          token: accessToken,
          file: newSelectedImage!,
        );

        debugPrint("uploadInfo: $uploadInfo");

        await uploadService.uploadImageToS3(
          uploadInfo: uploadInfo,
          file: newSelectedImage!,
        );

        debugPrint("S3 업로드 완료");

        imageObjectKeys.add(uploadInfo["objectKey"]);
      } else if (existingImage != null && !imageRemoved) {
        // 2) 기존 이미지를 그대로 유지하는 경우 → 기존 objectKey 재전송
        imageObjectKeys.add(existingImage!.objectKey);
      }
      // 3) 그 외(이미지 없음 / 삭제됨) → imageObjectKeys는 빈 배열 그대로

      debugPrint("최종 imageObjectKeys: $imageObjectKeys");

      final updated = await noticeApi.updateNotice(
        noticeId: widget.notice.noticeId,
        accessToken: accessToken,
        title: titleController.text.trim(),
        content: contentController.text.trim(),
        representative: widget.notice.representative,
        imageObjectKeys: imageObjectKeys,
      );

      debugPrint("updateNotice 성공: ${updated.noticeId}");

      // ⚠️ 서버가 같은 objectKey/URL 경로에 이미지를 덮어쓰는 구조라서,
      //    수정 전/후 imageUrl 문자열이 동일할 수 있다.
      //    그런데 Flutter의 Image 위젯은 NetworkImage의 URL이 이전과
      //    "완전히 동일"하면, ImageCache를 비워도 아예 새로 네트워크
      //    요청을 하지 않고 기존에 표시 중이던 이미지 스트림을 그대로
      //    유지해버린다 (didUpdateWidget에서 provider가 == 이면 스킵).
      //    → 그래서 imageCache.clear()만으로는 목록 화면의 이미지가
      //      바뀌지 않는다.
      //    실제로 "값이 바뀌는" 캐시버전을 기록해서, 목록 화면이
      //    이 noticeId의 이미지를 그릴 때 URL 뒤에 새 쿼리 파라미터를
      //    붙이도록 한다 (RNotificationPage._cacheBustedUrl 참고).
      NoticeImageCacheBuster.bump(widget.notice.noticeId);

      // 혹시 모를 인메모리 캐시 잔여분도 함께 정리 (안전장치)
      PaintingBinding.instance.imageCache.clear();
      PaintingBinding.instance.imageCache.clearLiveImages();

      // 목록 상태 갱신 (RNotificationProvider가 noticeId 기반 갱신 메서드를 제공한다면 사용)
      // 예: ref.read(RNotificationProvider.notifier).replaceNotice(updated);
      // ✅ await 없이 던져두면 갱신이 끝나기 전에 pop되어버리고,
      //    실패해도 조용히 무시되어 목록에 예전 사진이 남아있을 수 있다.
      await ref.read(RNotificationProvider.notifier).fetchFirstPage();

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("공지가 수정되었습니다.")),
      );

      Navigator.pop(context);
      Navigator.pop(context);
    } on DioException catch (e) {
      debugPrint("🔴 DioException: ${e.response?.statusCode} / ${e.response?.data}");

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.response?.data.toString() ?? "수정 실패")),
      );
    } catch (e, stack) {
      debugPrint("🔴 일반 예외: $e");
      debugPrint("스택: $stack");

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    } finally {
      if (mounted) setState(() => isSubmitting = false);
    }
  }

  Future<void> _showEditDialog() async {
    if (titleController.text.trim().isEmpty ||
        contentController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('제목과 내용을 모두 입력해주세요.')),
      );
      return;
    }

    final confirm = await showDialog<bool>(
      context: context,
      barrierColor: Colors.black54,
      builder: (context) {
        return Align(
          alignment: Alignment.bottomCenter,
          child: Container(
            margin: const EdgeInsets.only(left: 16, right: 16, bottom: 20),
            child: Material(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      '공지글을 수정하시겠습니까?',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                        decoration: TextDecoration.none,
                      ),
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        onPressed: () => Navigator.pop(context, true),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF0084FF),
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          '수정하기',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(context, false),
                        style: OutlinedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          '취소',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );

    if (confirm == true) {
      await _updateNotice();
    }
  }

  Future<void> _showGalleryBottomSheet() async {
    try {
      final PermissionState ps = await PhotoManager.requestPermissionExtend();
      debugPrint("🔵 permission state: $ps (isAuth: ${ps.isAuth})");

      if (!ps.isAuth && ps != PermissionState.limited) {
        debugPrint("🔴 권한 거부됨 → 갤러리 열기 중단");
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('갤러리 접근 권한이 필요합니다. 설정에서 허용해주세요.'),
              action: SnackBarAction(
                label: '설정으로 이동',
                onPressed: () => PhotoManager.openSetting(),
              ),
            ),
          );
        }
        return;
      }

      // iOS "제한된 접근"이면 사진 선택 UI를 먼저 띄운다 (Android는 no-op)
      if (ps == PermissionState.limited) {
        debugPrint("🟡 제한된 접근 → presentLimited 호출");
        await PhotoManager.presentLimited();
      }

      final albums = await PhotoManager.getAssetPathList(
        type: RequestType.image,
        onlyAll: true,
      );
      debugPrint("🔵 albums.length: ${albums.length}");

      if (albums.isEmpty) {
        debugPrint("🔴 앨범이 비어있음 → 갤러리 열기 중단");
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('불러올 수 있는 사진이 없습니다.')),
          );
        }
        return;
      }

      final images = await albums.first.getAssetListPaged(page: 0, size: 100);
      debugPrint("🔵 images.length: ${images.length}");

      images.sort((a, b) => b.createDateTime.compareTo(a.createDateTime));

      if (!mounted) return;

      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.white,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        builder: (context) {
          AssetEntity? tempSelectedAsset;
          bool isPickingFile = false;

          return StatefulBuilder(
            builder: (context, setModalState) {
              return SizedBox(
                height: MediaQuery.of(context).size.height * 0.7,
                child: Column(
                  children: [
                    const SizedBox(height: 12),
                    Container(
                      width: 50,
                      height: 5,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    const SizedBox(height: 12),
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
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            Positioned(
                              right: 0,
                              child: GestureDetector(
                                onTap: () => Navigator.pop(context),
                                child: Container(
                                  width: 36,
                                  height: 36,
                                  decoration: const BoxDecoration(
                                    color: Color(0xFFF2F2F7),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.close,
                                    color: Colors.grey,
                                    size: 22,
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
                          ? const Center(child: Text('사진이 없습니다.'))
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
                                    color: Colors.grey.shade200);
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
                                        color: Colors.blue, width: 3)
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
                      padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
                      child: SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton(
                          onPressed: tempSelectedAsset == null || isPickingFile
                              ? null
                              : () async {
                            setModalState(() => isPickingFile = true);

                            final file =
                            await UploadImageNormalizer.normalizeAssetForUpload(tempSelectedAsset!);

                            if (file == null) {
                              setModalState(
                                      () => isPickingFile = false);
                              if (mounted) {
                                ScaffoldMessenger.of(context)
                                    .showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                        '사진을 불러오지 못했습니다. 다시 시도해주세요.'),
                                  ),
                                );
                              }
                              return;
                            }

                            // 바깥(_RNotiEditPageState)의 setState를
                            // 호출해야 미리보기/제출 로직에 반영된다.
                            setState(() {
                              newSelectedImage = file;
                              imageRemoved = false;
                            });

                            if (mounted) {
                              Navigator.pop(context);
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF007AFF),
                            disabledBackgroundColor: const Color(0xFFE5E5EA),
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: isPickingFile
                              ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                              : const Text(
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
    } catch (e, stack) {
      debugPrint("🔴 갤러리 로딩 중 예외 발생: $e");
      debugPrint("$stack");

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('갤러리를 여는 중 오류가 발생했습니다: $e')),
        );
      }
    }
  }

  Widget _buildImagePreview() {
    if (newSelectedImage != null) {
      // 새로 선택한 로컬 이미지 미리보기
      return Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.file(newSelectedImage!, width: double.infinity, fit: BoxFit.cover),
          ),
          Positioned(
            top: 10,
            right: 10,
            child: GestureDetector(
              onTap: () {
                setState(() {
                  newSelectedImage = null;
                  imageRemoved = true;
                });
              },
              child: Container(
                width: 32,
                height: 32,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.close, size: 20),
              ),
            ),
          ),
        ],
      );
    }

    if (existingImage != null && !imageRemoved) {
      // 서버에 있던 기존 이미지 미리보기
      return Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.network(
              existingImage!.imageUrl,
              width: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stack) => Container(
                height: 200,
                color: Colors.grey.shade200,
                alignment: Alignment.center,
                child: const Icon(Icons.broken_image_outlined, color: Colors.grey),
              ),
            ),
          ),
          Positioned(
            top: 10,
            right: 10,
            child: GestureDetector(
              onTap: () {
                setState(() {
                  imageRemoved = true;
                });
              },
              child: Container(
                width: 32,
                height: 32,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.close, size: 20),
              ),
            ),
          ),
        ],
      );
    }

    return const SizedBox.shrink();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: const Icon(Icons.arrow_back_ios_new),
                  ),
                  Row(
                    children: [
                      IconButton(
                        onPressed: isSubmitting ? null : _showGalleryBottomSheet,
                        icon: const Icon(Icons.image_outlined, size: 28),
                      ),
                      const SizedBox(width: 8),
                      SizedBox(
                        width: 88,
                        height: 40,
                        child: ElevatedButton(
                          onPressed: isSubmitting ? null : _showEditDialog,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFE6F3FF),
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: isSubmitting
                              ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                              : const Text(
                            '수정',
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
                    child: TextField(
                      controller: titleController,
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        hintText: '제목을 입력해주세요.',
                      ),
                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Divider(color: Color(0xFFE5E5E5)),
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          TextField(
                            controller: contentController,
                            maxLines: null,
                            decoration: const InputDecoration(
                              border: InputBorder.none,
                              hintText: '공지내용을 입력해 주세요.',
                            ),
                            style: const TextStyle(fontSize: 16),
                          ),
                          const SizedBox(height: 20),
                          if (_hasDisplayableImage) _buildImagePreview(),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
