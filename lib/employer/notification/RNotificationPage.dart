import 'package:chack_chack/employer/notification/RNotiWritingPage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../common/widgets/BottomNavBar.dart';
import '../crews/RCrewPage.dart';
import '../home/RHomePage.dart';
import '../mypage/RMyPage.dart';
import 'NotificationProvider.dart';
import 'RNotificationModel.dart';

class RNotificationPage extends ConsumerStatefulWidget {
  const RNotificationPage({super.key});

  @override
  ConsumerState<RNotificationPage> createState() => _RNotificationPageState();
}

class _RNotificationPageState extends ConsumerState<RNotificationPage> {
  void _showEmojiPicker(BuildContext context, int index) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(20),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(2))),
              const SizedBox(height: 20),
              const Text('반응 선택하기',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 30),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: ['❤️', '👍', '✅', '😊'].map((emoji) {
                  return GestureDetector(
                    onTap: () {
                      // Provider를 통해 리액션 추가 및 자동 저장
                      ref
                          .read(NotificationProvider.notifier)
                          .addReaction(index, emoji);
                      Navigator.pop(context);
                    },
                    child: Text(emoji, style: const TextStyle(fontSize: 36)),
                  );
                }).toList(),
              ),
              const SizedBox(height: 30),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // Provider로부터 저장된 공지 목록을 실시간으로 가져옵니다.
    final notices = ref.watch(NotificationProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      bottomNavigationBar: BottomNavBar(
        currentIndex: 0,
        onTap: (index) {
          if (index == 0) {
            Navigator.push(context,
                MaterialPageRoute(builder: (_) => const RHomePage()));
          } else if (index == 1) {
            Navigator.push(context,
                MaterialPageRoute(builder: (_) => const RCrewPage()));
          } else if (index == 4) {
            Navigator.push(
                context, MaterialPageRoute(builder: (_) => const RMyPage()));
          }
        },
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding:
                const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: const Icon(Icons.arrow_back_ios_new, size: 22),
                    ),
                    const Expanded(
                        child: Center(
                            child: Text('공지',
                                style: TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold)))),
                    const SizedBox(width: 22),
                  ],
                ),
              ),
              if (notices.isEmpty)
                const Padding(
                  padding: EdgeInsets.only(top: 100),
                  child: Center(
                      child: Text('등록된 공지사항이 없습니다.',
                          style: TextStyle(fontSize: 16, color: Colors.grey))),
                )
              else
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: notices.length,
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final notice = notices[index];
                    return Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                  width: 42,
                                  height: 42,
                                  decoration: BoxDecoration(
                                      color: Colors.grey.shade300,
                                      borderRadius: BorderRadius.circular(10))),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Text(notice.writer,
                                            style: const TextStyle(
                                                fontWeight: FontWeight.bold)),
                                        const SizedBox(width: 4),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 4, vertical: 2),
                                          decoration: BoxDecoration(
                                              color: Colors.grey.shade300,
                                              borderRadius:
                                              BorderRadius.circular(4)),
                                          child: const Text('사장님',
                                              style: TextStyle(fontSize: 10)),
                                        ),
                                      ],
                                    ),
                                    Text(notice.date,
                                        style: TextStyle(
                                            color: Colors.grey.shade600,
                                            fontSize: 12)),
                                  ],
                                ),
                              ),
                              const Icon(Icons.more_horiz),
                            ],
                          ),
                          const SizedBox(height: 20),
                          Text(notice.title,
                              style: const TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 8),
                          Text(notice.content,
                              style: const TextStyle(fontSize: 16)),
                          const SizedBox(height: 24),
                          Row(
                            children: [
                              if (notice.reactions.isNotEmpty)
                                ...notice.reactions
                                    .map((emoji) => Padding(
                                  padding:
                                  const EdgeInsets.only(right: 8),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 14, vertical: 8),
                                    decoration: BoxDecoration(
                                        color: const Color(0xFFE8E8ED),
                                        borderRadius:
                                        BorderRadius.circular(20)),
                                    child: Text(emoji,
                                        style: const TextStyle(
                                            fontSize: 16)),
                                  ),
                                ))
                                    .toList(),
                              GestureDetector(
                                onTap: () => _showEmojiPicker(context, index),
                                child: const CircleAvatar(
                                  radius: 20,
                                  backgroundColor: Color(0xFFE8E8ED),
                                  child: Icon(Icons.add,
                                      color: Colors.black, size: 20),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (_) => const RNotiWritingPage()));
        },
        backgroundColor: Colors.black,
        elevation: 2,
        shape: const CircleBorder(),
        child: const Icon(Icons.add, color: Colors.white, size: 32),
      ),
    );
  }
}