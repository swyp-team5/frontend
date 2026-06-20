import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'RNotiEditPage.dart';
import 'RNotificationModel.dart';
import 'RNotificationProvider.dart';

class RNotificationDetailPage extends ConsumerWidget {
  final RNotificationModel notice;
  final int noticeIndex;

  const RNotificationDetailPage({
    super.key,
    required this.notice,
    required this.noticeIndex,
  });

  Map<String, int> getReactionCounts(List<String> reactions,) {
    final Map<String, int> counts = {};

    for (final emoji in reactions) {
      counts[emoji] = (counts[emoji] ?? 0) + 1;
    }

    return counts;
  }

  void _showEmojiMenu(
      BuildContext context,
      WidgetRef ref,
      int index,
      RelativeRect position,
      ) async {
    final selected = await showMenu<String>(
      context: context,
      position: position,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      items: [
        PopupMenuItem(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _emoji(context, '❤️'),
              const SizedBox(width: 16),
              _emoji(context, '👍'),
              const SizedBox(width: 16),
              _emoji(context, '✅'),
              const SizedBox(width: 16),
              _emoji(context, '😊'),
            ],
          ),
        ),
      ],
    );

    if (selected != null) {
      ref.read(RNotificationProvider.notifier).addReaction(index, selected);
    }
  }

  Widget _emoji(BuildContext context, String emoji) {
    return GestureDetector(
      onTap: () => Navigator.pop(context, emoji),
      child: Text(
        emoji,
        style: const TextStyle(fontSize: 28),
      ),
    );
  }


  void _showMoreMenu(
      BuildContext context,
      WidgetRef ref,
      RelativeRect position,
      RNotificationModel currentNotice,
      int noticeIndex,
      ) async {
    final result = await showMenu<String>(
      context: context,
      position: position,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      items: const [
        PopupMenuItem(
          value: 'edit',
          child: Row(
            children: [
              SizedBox(width: 10),
              Icon(
                Icons.edit_outlined,
                size: 20,
                color: Colors.black,
              ),
              SizedBox(width: 10),
              Text('수정', style: TextStyle(fontSize: 15),),
            ],
          ),
        ),
        PopupMenuItem(
          value: 'delete',
          child: Row(
            children: [
              SizedBox(width: 10),
              Icon(
                Icons.delete_outline,
                size: 20,
                color: Colors.red,
              ),
              SizedBox(width: 10),
              Text(
                '삭제',
                style: TextStyle(
                  fontSize: 15,
                  color: Colors.red,
                ),
              ),
            ],
          ),
        ),
      ],
    );

    /// 수정 → 바로 수정 페이지 이동
    if (result == 'edit') {
      if (context.mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => RNotiEditPage(
              notice: currentNotice,
              noticeIndex: noticeIndex,
            ),
          ),
        );
      }
    }

    /// 삭제
    if (result == 'delete') {
      final confirm = await showDialog<bool>(
        context: context,
        barrierColor: Colors.black54,
        builder: (context) {
          return Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              margin: const EdgeInsets.only(
                left: 16,
                right: 16,
                bottom: 20,
              ),
              child: Material(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        '공지글을 삭제하시겠습니까?',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                          decoration: TextDecoration.none,
                        ),
                      ),

                      const SizedBox(height: 24),

                      /// 삭제 버튼
                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.pop(context, true);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF0084FF),
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius:
                              BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text(
                            '삭제',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 12),

                      /// 취소 버튼
                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: OutlinedButton(
                          onPressed: () {
                            Navigator.pop(context, false);
                          },
                          style: OutlinedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                              borderRadius:
                              BorderRadius.circular(12),
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
        ref
            .read(RNotificationProvider.notifier)
            .removeNotice(noticeIndex);

        if (context.mounted) {
          Navigator.pop(context);
        }
      }
    }
  }

  @override
  Widget build(
      BuildContext context,
      WidgetRef ref,
      ) {
    final notices =
    ref.watch(RNotificationProvider);

    if (noticeIndex >= notices.length) {
      return const Scaffold(
        body: Center(
          child: Text('공지를 찾을 수 없습니다.'),
        ),
      );
    }

    final currentNotice =
    notices[noticeIndex];

    final reactionCounts =
    getReactionCounts(
      currentNotice.reactions,
    );

    return Scaffold(
      backgroundColor: Colors.white,

      body: SafeArea(
        child: Column(
          children: [
            /// 상단바
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 30,
              ),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () =>
                        Navigator.pop(context),
                    child: const Icon(
                      Icons.arrow_back_ios_new,
                    ),
                  ),
                ],
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                ),
                child: Column(
                  crossAxisAlignment:
                  CrossAxisAlignment.start,
                  children: [
                    /// 작성자
                    Row(
                      children: [
                        Container(
                          width: 42,
                          height: 42,
                          decoration: BoxDecoration(
                            color: Colors.grey.shade300,
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),

                        const SizedBox(width: 12),

                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    currentNotice.writer,
                                    style: const TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),

                                  const SizedBox(width: 6),

                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 6,
                                      vertical: 2,
                                    ),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFE6F3FF),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: const Text(
                                      '사장님',
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: Color(0xFF0063BF)
                                      ),
                                    ),
                                  ),
                                ],
                              ),

                              Text(
                                currentNotice.date,
                                style: TextStyle(
                                  color: Colors.grey.shade600,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),

                        Builder(
                          builder: (buttonContext) {
                            return IconButton(
                              onPressed: () {
                                final RenderBox button =
                                buttonContext.findRenderObject() as RenderBox;

                                final RenderBox overlay =
                                Overlay.of(context).context.findRenderObject() as RenderBox;

                                final position = RelativeRect.fromRect(
                                  Rect.fromPoints(
                                    button.localToGlobal(
                                      Offset.zero,
                                      ancestor: overlay,
                                    ),
                                    button.localToGlobal(
                                      button.size.bottomRight(Offset.zero),
                                      ancestor: overlay,
                                    ),
                                  ),
                                  Offset.zero & overlay.size,
                                );

                                _showMoreMenu(
                                  context,
                                  ref,
                                  position,
                                  currentNotice,
                                  noticeIndex,
                                );
                              },
                              icon: const Icon(Icons.more_horiz),
                            );
                          },
                        ),
                      ],
                    ),

                    const SizedBox(height: 30),

                    /// 제목
                    Text(
                      currentNotice.title,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 20),

                    /// 내용
                    Text(
                      currentNotice.content,
                      style: const TextStyle(
                        fontSize: 16,
                        height: 1.7,
                      ),
                    ),

                    const SizedBox(height: 20),

                    /// 이미지
                    if (currentNotice.imagePath !=
                        null)
                      ClipRRect(
                        borderRadius:
                        BorderRadius.circular(
                          16,
                        ),
                        child: Image.file(
                          File(
                            currentNotice
                                .imagePath!,
                          ),
                          width: double.infinity,
                          fit: BoxFit.cover,
                        ),
                      ),

                    const SizedBox(height: 30),

                    /// 이모지 현황
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: [

                        /// 이모지 추가 버튼
                        Builder(
                          builder: (buttonContext) {
                            return GestureDetector(
                              onTap: () {
                                final RenderBox button =
                                buttonContext.findRenderObject() as RenderBox;

                                final RenderBox overlay =
                                Overlay.of(context)
                                    .context
                                    .findRenderObject() as RenderBox;

                                final position = RelativeRect.fromRect(
                                  Rect.fromPoints(
                                    button.localToGlobal(
                                      Offset.zero,
                                      ancestor: overlay,
                                    ),
                                    button.localToGlobal(
                                      button.size.bottomRight(
                                        Offset.zero,
                                      ),
                                      ancestor: overlay,
                                    ),
                                  ),
                                  Offset.zero & overlay.size,
                                );

                                _showEmojiMenu(
                                  context,
                                  ref,
                                  noticeIndex,
                                  position,
                                );
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 14,
                                  vertical: 8,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFE8E8ED),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: const Icon(
                                  Icons.add,
                                  size: 18,
                                ),
                              ),
                            );
                          },
                        ),

                        /// 등록된 이모지
                        ...reactionCounts.entries.map(
                              (entry) => Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFE8E8ED),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  entry.key,
                                  style: const TextStyle(
                                    fontSize: 16,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  entry.value.toString(),
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 30),
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