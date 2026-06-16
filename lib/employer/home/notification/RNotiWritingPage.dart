import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
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
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  SizedBox(
                    width: 90,
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: const Icon(Icons.arrow_back_ios_new, size: 22),
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 88,
                    height: 40,
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
                            borderRadius: BorderRadius.circular(10)),
                      ),
                      child: const Text('게시',
                          style: TextStyle(
                              color: Colors.black,
                              fontSize: 18,
                              fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 30),
                    TextField(
                      controller: titleController,
                      decoration: const InputDecoration(
                        hintText: '제목을 입력해주세요.',
                        border: InputBorder.none,
                        hintStyle: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFFC8C8C8)),
                      ),
                      style: const TextStyle(
                          fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 20),
                    Expanded(
                      child: TextField(
                        controller: contentController,
                        maxLines: null,
                        expands: true,
                        textAlignVertical: TextAlignVertical.top,
                        decoration: const InputDecoration(
                          hintText: '내용을 입력해 주세요.',
                          border: InputBorder.none,
                          hintStyle: TextStyle(
                              fontSize: 18, color: Color(0xFFC8C8C8)),
                        ),
                        style: const TextStyle(fontSize: 18),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}