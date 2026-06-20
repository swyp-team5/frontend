import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'dart:io';
import 'dart:typed_data';
import 'package:photo_manager/photo_manager.dart';
import '../../../common/widgets/BottomNavBar.dart';
import '../../crews/RCrewPage.dart';
import '../../mypage/RMyPage.dart';
import '../RHomePage.dart';
import 'RNotificationProvider.dart';
import 'RNotificationModel.dart';

class RNotiWritingPage extends ConsumerStatefulWidget {
  const RNotiWritingPage({super.key});

  @override
  ConsumerState<RNotiWritingPage> createState() => _RNotiWritingPageState();
}

class _RNotiWritingPageState extends ConsumerState<RNotiWritingPage> {
  final TextEditingController titleController = TextEditingController();
  final TextEditingController contentController = TextEditingController();

  File? selectedImage;

  Future<void> _registerNotice() async {

    final newNotice = RNotificationModel(
      title: titleController.text,
      content: contentController.text,
      writer: '김다빈',
      date: DateFormat('M월 d일 HH:mm')
          .format(DateTime.now()),
      imagePath: selectedImage?.path,
      reactions: [],
    );

    await ref
        .read(RNotificationProvider.notifier)
        .addNotice(newNotice);

    if (!mounted) return;

    Navigator.pop(context); // 바텀시트 닫기
    Navigator.pop(context); // 작성페이지 닫기
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
                          await tempSelectedAsset!.originFile;

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
      builder: (context) {
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
                  onPressed: _registerNotice,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0084FF),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
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
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text(
                  '취소',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.black,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
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
