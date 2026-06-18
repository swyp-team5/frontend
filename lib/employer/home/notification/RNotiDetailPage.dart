import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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

  Map<String, int> getReactionCounts(
      List<String> reactions,
      ) {
    final Map<String, int> counts = {};

    for (final emoji in reactions) {
      counts[emoji] = (counts[emoji] ?? 0) + 1;
    }

    return counts;
  }

  void _showEmojiPicker(
      BuildContext context,
      WidgetRef ref,
      int index,
      ) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(20),
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
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),

              const SizedBox(height: 20),

              const Text(
                '반응 선택하기',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 30),

              Row(
                mainAxisAlignment:
                MainAxisAlignment.spaceEvenly,
                children: [
                  '❤️',
                  '👍',
                  '✅',
                  '😊',
                ].map((emoji) {
                  return GestureDetector(
                    onTap: () {
                      ref
                          .read(
                        RNotificationProvider.notifier,
                      )
                          .addReaction(
                        index,
                        emoji,
                      );

                      Navigator.pop(context);
                    },
                    child: Text(
                      emoji,
                      style: const TextStyle(
                        fontSize: 36,
                      ),
                    ),
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
              padding: const EdgeInsets.all(20),
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
                            color:
                            Colors.grey.shade300,
                            borderRadius:
                            BorderRadius.circular(
                              10,
                            ),
                          ),
                        ),

                        const SizedBox(width: 12),

                        Expanded(
                          child: Column(
                            crossAxisAlignment:
                            CrossAxisAlignment
                                .start,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    currentNotice
                                        .writer,
                                    style:
                                    const TextStyle(
                                      fontWeight:
                                      FontWeight
                                          .bold,
                                    ),
                                  ),

                                  const SizedBox(
                                      width: 6),

                                  Container(
                                    padding:
                                    const EdgeInsets
                                        .symmetric(
                                      horizontal: 6,
                                      vertical: 2,
                                    ),
                                    decoration:
                                    BoxDecoration(
                                      color:
                                      const Color(
                                        0xFFE6F3FF,
                                      ),
                                      borderRadius:
                                      BorderRadius
                                          .circular(
                                        4,
                                      ),
                                    ),
                                    child:
                                    const Text(
                                      '사장님',
                                      style:
                                      TextStyle(
                                        fontSize: 11,
                                      ),
                                    ),
                                  ),
                                ],
                              ),

                              const SizedBox(
                                  height: 2),

                              Text(
                                currentNotice.date,
                                style: TextStyle(
                                  color: Colors
                                      .grey.shade600,
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
                        fontSize: 30,
                        fontWeight:
                        FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 20),

                    /// 내용
                    Text(
                      currentNotice.content,
                      style: const TextStyle(
                        fontSize: 17,
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
                    if (reactionCounts.isNotEmpty)
                      Wrap(
                        spacing: 10,
                        runSpacing: 10,
                        children:
                        reactionCounts.entries
                            .map(
                              (entry) =>
                              Container(
                                padding:
                                const EdgeInsets
                                    .symmetric(
                                  horizontal:
                                  14,
                                  vertical: 8,
                                ),
                                decoration:
                                BoxDecoration(
                                  color:
                                  const Color(
                                    0xFFE8E8ED,
                                  ),
                                  borderRadius:
                                  BorderRadius
                                      .circular(
                                    20,
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize:
                                  MainAxisSize
                                      .min,
                                  children: [
                                    Text(
                                      entry.key,
                                      style:
                                      const TextStyle(
                                        fontSize:
                                        16,
                                      ),
                                    ),
                                    const SizedBox(
                                        width:
                                        4),
                                    Text(
                                      entry.value
                                          .toString(),
                                      style:
                                      const TextStyle(
                                        fontWeight:
                                        FontWeight
                                            .w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                        )
                            .toList(),
                      ),

                    const SizedBox(height: 30),
                  ],
                ),
              ),
            ),

            /// 하단 반응 버튼
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                color: Colors.white,
                border: Border(
                  top: BorderSide(
                    color: Color(0xFFEAEAEA),
                  ),
                ),
              ),
              child: ElevatedButton.icon(
                onPressed: () {
                  _showEmojiPicker(
                    context,
                    ref,
                    noticeIndex,
                  );
                },
                icon: const Icon(
                  Icons.add_reaction_outlined,
                ),
                label: const Text(
                  '반응 남기기',
                ),
                style:
                ElevatedButton.styleFrom(
                  minimumSize:
                  const Size.fromHeight(
                    52,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}