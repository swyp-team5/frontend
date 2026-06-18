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
      onlyAll: true, // 전체 보기 앨범만 우선 가져오도록 설정
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
      size: 60, // 로딩 속도를 위해 사이즈 조절
    );

    if (!mounted) return;

    // 3. 바텀 시트 띄우기
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (context) {
        return SizedBox(
          height: MediaQuery.of(context).size.height * 0.7, // 높이 소폭 조정
          child: Column(
            children: [
              const SizedBox(height: 12),
              Container(
                width: 50, height: 5,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                '최근 항목',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              Expanded(
                child: images.isEmpty
                    ? const Center(child: Text('사진이 없습니다.'))
                    : GridView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 2),
                  itemCount: images.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 2,
                    mainAxisSpacing: 2,
                  ),
                  itemBuilder: (context, index) {
                    return FutureBuilder<Uint8List?>(
                      future: images[index].thumbnailDataWithSize(const ThumbnailSize(300, 300)),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.done && snapshot.hasData) {
                          return GestureDetector(
                            onTap: () async {
                              final file = await images[index].originFile; // file 대신 originFile 사용 권장
                              if (file != null) {
                                setState(() {
                                  selectedImage = file;
                                });
                                Navigator.pop(context);
                              }
                            },
                            child: Image.memory(snapshot.data!, fit: BoxFit.cover),
                          );
                        }
                        return Container(color: Colors.grey.shade100);
                      },
                    );
                  },
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
      backgroundColor: const Color(0xFFF5F5F5),
      resizeToAvoidBottomInset: true,
      bottomNavigationBar: BottomNavBar(
        currentIndex: 0,
        onTap: (index) {
          if (index == 0) {
            Navigator.push(context, MaterialPageRoute(builder: (_) => const RHomePage()));
          } else if (index == 1) {
            Navigator.push(context, MaterialPageRoute(builder: (_) => const RCrewPage()));
          } else if (index == 4) {
            Navigator.push(context, MaterialPageRoute(builder: (_) => const RMyPage()));
          }
        },
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
              child:
              Padding(
                padding: const EdgeInsets.all(0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [

                    /// 뒤로가기
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: const Icon(
                        Icons.arrow_back_ios_new,
                        size: 22,
                      ),
                    ),

                    /// 이미지 + 등록
                    Row(
                      children: [
                        IconButton(
                          onPressed: () async {
                            await _showGalleryBottomSheet();
                          },
                          icon: const Icon(
                            Icons.image_outlined,
                            size: 34,
                          ),
                        ),

                        const SizedBox(width: 8),

                        SizedBox(
                          width: 88, height: 40,
                          child: ElevatedButton(
                            onPressed: () async { // async 추가
                              if (titleController.text.trim().isEmpty ||
                                  contentController.text.trim().isEmpty) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('제목과 내용을 모두 입력해주세요.')));
                                return;
                              }

                              final newNotice = RNotificationModel(
                                title: titleController.text,
                                content: contentController.text,
                                writer: '김다빈',
                                date: DateFormat('M월 d일 HH:mm').format(DateTime.now()),
                                reactions: [],
                              );

                              // 저장이 완료될 때까지 기다림 (await 추가)
                              await ref.read(RNotificationProvider.notifier).addNotice(newNotice);

                              // 저장이 끝난 후 이전 화면으로 돌아감
                              if (mounted) {
                                Navigator.pop(context);
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFE8E8ED),
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                            child: const Text(
                              '등록',
                              style: TextStyle(
                                color: Colors.black,
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

                        if (selectedImage != null)
                          Padding(
                            padding: const EdgeInsets.only(
                              bottom: 20,
                            ),
                            child: ClipRRect(
                              borderRadius:
                              BorderRadius.circular(12),
                              child: Image.file(
                                selectedImage!,
                                width: double.infinity,
                                height: 180,
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),

                        TextField(
                          controller: titleController,
                          decoration: const InputDecoration(
                            hintText: '제목을 입력해주세요.',
                            border: InputBorder.none,
                            hintStyle: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFFC8C8C8),
                            ),
                          ),
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20,),
                  Divider(
                    color: Colors.grey.shade300,
                    thickness: 1,
                    height: 1,
                  ),
                  const SizedBox(height: 20,),

                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: TextField(
                        controller: contentController,
                        maxLines: null,
                        expands: true,
                        textAlignVertical: TextAlignVertical.top,
                        decoration: const InputDecoration(
                          hintText: '공지내용을 입력해 주세요.',
                          border: InputBorder.none,
                          hintStyle: TextStyle(
                            fontSize: 18,
                            color: Color(0xFFC8C8C8),
                          ),
                        ),
                        style: const TextStyle(fontSize: 18),
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