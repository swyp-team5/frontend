import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'ENotificationModel.dart';
import 'ENotificationProvider.dart';

class ENotiDetailPage extends ConsumerWidget {
  final ENotificationModel notice;
  final int noticeIndex;

  const ENotiDetailPage({
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
      ref.read(ENotificationProvider.notifier).addReaction(index, selected);
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

  @override
  Widget build(
      BuildContext context,
      WidgetRef ref,
      ) {
    final notices =
    ref.watch(ENotificationProvider);

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