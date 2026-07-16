import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';

import '../../../common/auth/server_token_manager.dart';
import '../../../employer/home/notification/RNotificationModel.dart';
import '../../../employer/home/notification/api/notice_api.dart';
import '../../../employer/home/notification/widgets/NoticeReactionBar.dart';
import 'ENotificationProvider.dart';

class ENotiDetailPage extends ConsumerStatefulWidget {
  final int noticeId;

  /// 목록에서 넘어올 때 바로 보여줄 초기 데이터 (선택)
  final NoticeModel? initialNotice;

  const ENotiDetailPage({
    super.key,
    required this.noticeId,
    this.initialNotice,
  });

  @override
  ConsumerState<ENotiDetailPage> createState() => _ENotiDetailPageState();
}

class _ENotiDetailPageState extends ConsumerState<ENotiDetailPage> {

  late final NoticeApi noticeApi;

  NoticeModel? notice;
  bool isLoading = true;
  String? error;

  @override
  void initState() {
    super.initState();

    noticeApi = NoticeApi(ServerTokenManager.authorizedDio);

    notice = widget.initialNotice;
    isLoading = widget.initialNotice == null;

    _fetchDetail();
  }

  Future<void> _fetchDetail() async {
    try {
      final accessToken = await ServerTokenManager.getValidAccessToken();

      if (accessToken == null || accessToken.isEmpty) {
        throw Exception("로그인이 필요합니다.");
      }

      final result = await noticeApi.getNoticeDetail(
        noticeId: widget.noticeId,
        accessToken: accessToken,
      );

      if (!mounted) return;

      setState(() {
        notice = result;
        isLoading = false;
        error = null;
      });
    } catch (e) {
      debugPrint("🔴 공지 상세 조회 실패: $e");

      if (!mounted) return;

      setState(() {
        isLoading = false;
        error = notice == null ? e.toString() : null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading && notice == null) {
      return const Scaffold(
        backgroundColor: Colors.white,
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (notice == null) {
      return Scaffold(
        backgroundColor: Colors.white,
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(error ?? '공지를 불러오지 못했습니다.'),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: _fetchDetail,
                child: const Text('다시 시도'),
              ),
            ],
          ),
        ),
      );
    }

    final currentNotice = notice!;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            /// 상단바
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: const Icon(Icons.arrow_back_ios_new),
                  ),
                ],
              ),
            ),

            Expanded(
              child: RefreshIndicator(
                onRefresh: _fetchDetail,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 20),
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
                                          color: Color(0xFF0063BF),
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
                        style: const TextStyle(fontSize: 16, height: 1.7),
                      ),

                      const SizedBox(height: 20),

                      /// 이미지 (서버 URL 기반, 여러 장 지원)
                      if (currentNotice.images.isNotEmpty)
                        Column(
                          children: currentNotice.images.map((img) {
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(16),
                                child: Image.network(
                                  img.imageUrl,
                                  width: double.infinity,
                                  fit: BoxFit.cover,
                                  loadingBuilder: (context, child, progress) {
                                    if (progress == null) return child;
                                    return Container(
                                      height: 200,
                                      color: Colors.grey.shade200,
                                      alignment: Alignment.center,
                                      child: const SizedBox(
                                        width: 24,
                                        height: 24,
                                        child: CircularProgressIndicator(strokeWidth: 2),
                                      ),
                                    );
                                  },
                                  errorBuilder: (context, error, stack) => Container(
                                    height: 200,
                                    color: Colors.grey.shade200,
                                    alignment: Alignment.center,
                                    child: const Icon(
                                      Icons.broken_image_outlined,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ),

                      const SizedBox(height: 30),

                      /// 공감 (근무자 화면 — 탭 가능)
                      NoticeReactionBar(
                        reactions: currentNotice.reactions,
                        myReactionType: currentNotice.myReactionType,
                        canReact: true,
                        onSelect: (reactionType) async {
                          try {
                            final result = await ref
                                .read(ENotificationProvider.notifier)
                                .selectReaction(
                              noticeId: currentNotice.noticeId,
                              reactionType: reactionType,
                            );

                            if (!mounted) return;

                            setState(() {
                              notice = currentNotice.copyWith(
                                myReactionType: result.myReactionType,
                                reactions: result.reactions,
                              );
                            });
                          } catch (e) {
                            if (!mounted) return;

                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  e.toString().replaceFirst("Exception: ", ""),
                                ),
                              ),
                            );
                          }
                        },
                      ),

                      const SizedBox(height: 30),
                    ],
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