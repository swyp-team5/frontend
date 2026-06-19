import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'dart:io';

import '../../../common/widgets/BottomNavBar.dart';
import '../../crews/ECrewPage.dart';
import '../../home/EHomePage.dart';
import '../../mypage/EMyPage.dart';

import '../../../employer/home/notification/RNotificationProvider.dart';

class ENotificationPage extends ConsumerStatefulWidget {
  const ENotificationPage({super.key});

  @override
  ConsumerState<ENotificationPage> createState() => _ENotificationPageState();
}

class _ENotificationPageState extends ConsumerState<ENotificationPage> {

  Map<String, int> getReactionCounts(
      List<String> reactions,
      ) {
    final Map<String, int> counts = {};

    for (final emoji in reactions) {
      counts[emoji] =
          (counts[emoji] ?? 0) + 1;
    }

    return counts;
  }


  @override
  Widget build(BuildContext context) {

    final notices = ref.watch(RNotificationProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),

      /// 공통 BottomNavBar 적용
      bottomNavigationBar: BottomNavBar(
        currentIndex: 0,
        onTap: (index) {
          if (index == 0) {
            Navigator.push(context,
                MaterialPageRoute(builder: (_) => const EHomePage()));
          } else if (index == 1) {
            Navigator.push(context,
                MaterialPageRoute(builder: (_) => const ECrewPage()));
          } else if (index == 4) {
            Navigator.push(
                context, MaterialPageRoute(builder: (_) => const EMyPage()));
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
                            child: Text('공지 게시판',
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

                    final reactionCounts = getReactionCounts(
                      notice.reactions,
                    );

                    return InkWell(
                      onTap: () {
                        // Navigator.push(
                        //   context,
                        //   MaterialPageRoute(
                        //     builder: (_) => ENotiDetailPage(
                        //       notice: notice,
                        //       noticeIndex: index,
                        //     ),
                        //   ),
                        // );
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [

                            /// 작성자
                            Row(
                              children: [
                                Container(
                                  width: 42,
                                  height: 42,
                                  decoration: BoxDecoration(
                                    color: Colors.grey.shade300,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),

                                const SizedBox(width: 12),

                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                    children: [

                                      Row(
                                        children: [
                                          Text(
                                            notice.writer,
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),

                                          const SizedBox(width: 8),

                                          Container(
                                            padding:
                                            const EdgeInsets.symmetric(
                                              horizontal: 6,
                                              vertical: 3,
                                            ),
                                            decoration: BoxDecoration(
                                              color: const Color(0xFFE6F3FF),
                                              borderRadius:
                                              BorderRadius.circular(4),
                                            ),
                                            child: const Text(
                                              '사장님',
                                              style: TextStyle(
                                                fontSize: 10,
                                                color: Color(0xFF0063BF),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),

                                      const SizedBox(height: 4),

                                      Text(
                                        notice.date,
                                        style: TextStyle(
                                          color: Colors.grey.shade600,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                                const Icon(
                                  Icons.more_horiz,
                                  color: Colors.grey,
                                ),
                              ],
                            ),

                            const SizedBox(height: 20),

                            /// 제목 + 내용 + 이미지
                            Row(
                              crossAxisAlignment:
                              CrossAxisAlignment.start,
                              children: [

                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                    children: [

                                      Text(
                                        notice.title,
                                        maxLines: 2,
                                        overflow:
                                        TextOverflow.ellipsis,
                                        style: const TextStyle(
                                          fontSize: 18,
                                          fontWeight:
                                          FontWeight.bold,
                                        ),
                                      ),

                                      const SizedBox(height: 10),

                                      Text(
                                        notice.content,
                                        maxLines: 4,
                                        overflow:
                                        TextOverflow.ellipsis,
                                        style: const TextStyle(
                                          fontSize: 15,
                                          height: 1.4,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                                if (notice.imagePath != null &&
                                    notice.imagePath!.isNotEmpty)
                                  Padding(
                                    padding:
                                    const EdgeInsets.only(
                                      left: 16,
                                    ),
                                    child: ClipRRect(
                                      borderRadius:
                                      BorderRadius.circular(14),
                                      child: Image.file(
                                        File(notice.imagePath!),
                                        width: 110,
                                        height: 110,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  ),
                              ],
                            ),

                            const SizedBox(height: 20),

                            /// 이모지 집계만 표시
                            if (reactionCounts.isNotEmpty)
                              Wrap(
                                spacing: 10,
                                runSpacing: 10,
                                children: reactionCounts.entries
                                    .map(
                                      (entry) => Container(
                                    padding:
                                    const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 6,
                                    ),
                                    decoration: BoxDecoration(
                                      borderRadius:
                                      BorderRadius.circular(
                                          20),
                                      border: Border.all(
                                        color:
                                        Colors.grey.shade300,
                                      ),
                                    ),
                                    child: Row(
                                      mainAxisSize:
                                      MainAxisSize.min,
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
                                            fontSize: 14,
                                            fontWeight:
                                            FontWeight.w500,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                )
                                    .toList(),
                              ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }
}