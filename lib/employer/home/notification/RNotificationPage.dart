import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../common/widgets/BottomNavBar.dart';
import '../../crews/RCrewPage.dart';
import '../../mypage/RMyPage.dart';
import '../RHomePage.dart';
import 'RNotiDetailPage.dart';
import 'RNotificationProvider.dart';
import 'RNotiWritingPage.dart';
import 'RNotificationModel.dart';

class RNotificationPage extends ConsumerStatefulWidget {
  const RNotificationPage({super.key});

  @override
  ConsumerState<RNotificationPage> createState() => _RNotificationPageState();
}

class _RNotificationPageState extends ConsumerState<RNotificationPage> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();

    Future.microtask(() {
      ref.read(RNotificationProvider.notifier).fetchFirstPage();
    });

    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
          _scrollController.position.maxScrollExtent - 200) {
        ref.read(RNotificationProvider.notifier).fetchNextPage();
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(RNotificationProvider);

    return Scaffold(
      backgroundColor: Colors.white,
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
        child: RefreshIndicator(
          onRefresh: () =>
              ref.read(RNotificationProvider.notifier).fetchFirstPage(),
          child: SingleChildScrollView(
            controller: _scrollController,
            physics: const AlwaysScrollableScrollPhysics(),
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
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold)))),
                      const SizedBox(width: 22),
                    ],
                  ),
                ),

                if (state.isLoading)
                  const Padding(
                    padding: EdgeInsets.only(top: 100),
                    child: Center(child: CircularProgressIndicator()),
                  )
                else if (state.error != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 100),
                    child: Center(
                      child: Column(
                        children: [
                          Text(state.error!,
                              style: const TextStyle(color: Colors.red)),
                          const SizedBox(height: 12),
                          ElevatedButton(
                            onPressed: () => ref
                                .read(RNotificationProvider.notifier)
                                .fetchFirstPage(),
                            child: const Text("다시 시도"),
                          ),
                        ],
                      ),
                    ),
                  )
                else if (state.notices.isEmpty)
                    const Padding(
                      padding: EdgeInsets.only(top: 100),
                      child: Center(
                          child: Text('작성된 글이 없어요',
                              style: TextStyle(
                                  fontSize: 18, color: Color(0xFF999999)))),
                    )
                  else
                    ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: state.notices.length,
                      separatorBuilder: (_, __) => const Divider(height: 1),
                      itemBuilder: (context, index) {
                        final notice = state.notices[index];
                        final reactionCounts = notice.reactionCounts;

                        return InkWell(
                          onTap: () {
                            // Navigator.push(
                            //   context,
                            //   MaterialPageRoute(
                            //     builder: (_) => RNotiDetailPage(
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
                                      width: 40,
                                      height: 40,
                                      decoration: BoxDecoration(
                                        color: Colors.grey.shade300,
                                        borderRadius:
                                        BorderRadius.circular(12),
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
                                                  fontSize: 14,
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
                                                  color:
                                                  const Color(0xFFE6F3FF),
                                                  borderRadius:
                                                  BorderRadius.circular(4),
                                                ),
                                                child: const Text(
                                                  '사장님',
                                                  style: TextStyle(
                                                    fontSize: 11,
                                                    color: Color(0xFF0063BF),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            notice.date,
                                            style: const TextStyle(
                                              color: Color(0xFF767676),
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
                                /// 이미지는 사장님이 공지 작성 시 첨부한 사진(서버 images[0].imageUrl)
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            notice.title,
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                            style: const TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          const SizedBox(height: 10),
                                          Text(
                                            notice.content,
                                            maxLines: 4,
                                            overflow: TextOverflow.ellipsis,
                                            style: const TextStyle(
                                              fontSize: 14,
                                              height: 1.4,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),

                                    if (notice.imageUrl != null &&
                                        notice.imageUrl!.isNotEmpty)
                                      Padding(
                                        padding: const EdgeInsets.only(
                                          left: 16,
                                        ),
                                        child: ClipRRect(
                                          borderRadius:
                                          BorderRadius.circular(14),
                                          child: Image.network(
                                            notice.imageUrl!,
                                            width: 110,
                                            height: 110,
                                            fit: BoxFit.cover,
                                            loadingBuilder: (context, child,
                                                progress) {
                                              if (progress == null) {
                                                return child;
                                              }
                                              return Container(
                                                width: 110,
                                                height: 110,
                                                color: Colors.grey.shade200,
                                                alignment: Alignment.center,
                                                child: const SizedBox(
                                                  width: 20,
                                                  height: 20,
                                                  child:
                                                  CircularProgressIndicator(
                                                    strokeWidth: 2,
                                                  ),
                                                ),
                                              );
                                            },
                                            errorBuilder:
                                                (context, error, stack) =>
                                                Container(
                                                  width: 110,
                                                  height: 110,
                                                  color:
                                                  Colors.grey.shade200,
                                                  alignment: Alignment.center,
                                                  child: const Icon(
                                                    Icons
                                                        .broken_image_outlined,
                                                    color: Colors.grey,
                                                  ),
                                                ),
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
                                          BorderRadius.circular(20),
                                          border: Border.all(
                                            color: Colors.grey.shade300,
                                          ),
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
                                                fontSize: 14,
                                                fontWeight: FontWeight.w500,
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

                if (state.isLoadingMore)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 20),
                    child: Center(child: CircularProgressIndicator()),
                  ),

                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (_) => const RNotiWritingPage()));
          ref.read(RNotificationProvider.notifier).fetchFirstPage();
        },
        backgroundColor: const Color(0xFF0084FF),
        elevation: 2,
        shape: const CircleBorder(),
        child: const Icon(Icons.edit, color: Colors.white, size: 28),
      ),
    );
  }
}