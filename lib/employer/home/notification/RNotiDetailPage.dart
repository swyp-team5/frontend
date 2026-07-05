import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';

import '../../../common/auth/server_token_manager.dart';
import 'RNotiEditPage.dart';
import 'RNotificationModel.dart';
import 'RNotificationProvider.dart';
import 'api/notice_api.dart';

class RNotiDetailPage extends ConsumerStatefulWidget {
  final int noticeId;

  /// 목록에서 넘어올 때 바로 보여줄 초기 데이터 (선택)
  /// 없으면 로딩 스피너부터 보여주고 API 결과로 채움
  final NoticeModel? initialNotice;

  const RNotiDetailPage({
    super.key,
    required this.noticeId,
    this.initialNotice,
  });

  @override
  ConsumerState<RNotiDetailPage> createState() => _RNotiDetailPageState();
}

class _RNotiDetailPageState extends ConsumerState<RNotiDetailPage> {
  late final Dio dio;
  late final NoticeApi noticeApi;

  NoticeModel? notice;
  bool isLoading = true;
  String? error;

  @override
  void initState() {
    super.initState();

    dio = Dio();
    dio.options.baseUrl = "https://chackchack.shop";
    noticeApi = NoticeApi(dio);

    // 목록에서 받은 데이터로 우선 보여주고, 최신 상세를 다시 조회
    notice = widget.initialNotice;
    isLoading = widget.initialNotice == null;

    _fetchDetail();
  }

  Future<void> _fetchDetail() async {
    try {
      final accessToken = await ServerTokenManager.getAccessToken();

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
        // initialNotice가 있으면 화면은 그대로 유지하고 에러는 표시만
        error = notice == null ? e.toString() : null;
      });
    }
  }

  void _showEmojiMenu(
      BuildContext context,
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
      // TODO: RNotificationProvider에 리액션 등록 메서드와 연동
      // 예: ref.read(RNotificationProvider.notifier).addReaction(widget.noticeId, selected);
      debugPrint("선택된 이모지: $selected (연동 API 필요)");
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
      RelativeRect position,
      NoticeModel currentNotice,
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
              Icon(Icons.edit_outlined, size: 20, color: Colors.black),
              SizedBox(width: 10),
              Text('수정', style: TextStyle(fontSize: 15)),
            ],
          ),
        ),
        PopupMenuItem(
          value: 'delete',
          child: Row(
            children: [
              SizedBox(width: 10),
              Icon(Icons.delete_outline, size: 20, color: Colors.red),
              SizedBox(width: 10),
              Text(
                '삭제',
                style: TextStyle(fontSize: 15, color: Colors.red),
              ),
            ],
          ),
        ),
      ],
    );

    if (result == 'edit') {
      if (context.mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => RNotiEditPage(
              notice: currentNotice,
            ),
          ),
        );
      }
    }

    if (result == 'delete') {
      final confirm = await showDialog<bool>(
        context: context,
        barrierColor: Colors.black54,
        builder: (context) {
          return Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              margin: const EdgeInsets.only(left: 16, right: 16, bottom: 20),
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
                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: ElevatedButton(
                          onPressed: () => Navigator.pop(context, true),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF0084FF),
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
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
                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: OutlinedButton(
                          onPressed: () => Navigator.pop(context, false),
                          style: OutlinedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
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
        try {
          final accessToken = await ServerTokenManager.getAccessToken();

          if (accessToken == null || accessToken.isEmpty) {
            throw Exception("로그인이 필요합니다.");
          }

          await noticeApi.deleteNotice(
            noticeId: currentNotice.noticeId,
            accessToken: accessToken,
          );

          debugPrint("공지 삭제 성공: noticeId=${currentNotice.noticeId}");

          // 목록 상태 갱신
          ref.read(RNotificationProvider.notifier).fetchFirstPage();

          if (!context.mounted) return;

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("공지가 삭제되었습니다.")),
          );

          Navigator.pop(context);
        } catch (e) {
          debugPrint("🔴 공지 삭제 실패: $e");

          if (!context.mounted) return;

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(e.toString().replaceFirst("Exception: ", ""))),
          );
        }
      }
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
    final reactionCounts = currentNotice.reactionCounts;

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
                          Builder(
                            builder: (buttonContext) {
                              return IconButton(
                                onPressed: () {
                                  final RenderBox button = buttonContext
                                      .findRenderObject() as RenderBox;
                                  final RenderBox overlay = Overlay.of(context)
                                      .context
                                      .findRenderObject() as RenderBox;

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

                                  _showMoreMenu(context, position, currentNotice);
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

                      /// 이모지 현황
                      Wrap(
                        spacing: 10,
                        runSpacing: 10,
                        children: [
                          Builder(
                            builder: (buttonContext) {
                              return GestureDetector(
                                onTap: () {
                                  final RenderBox button = buttonContext
                                      .findRenderObject() as RenderBox;
                                  final RenderBox overlay = Overlay.of(context)
                                      .context
                                      .findRenderObject() as RenderBox;

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

                                  _showEmojiMenu(context, position);
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
                                  child: const Icon(Icons.add, size: 18),
                                ),
                              );
                            },
                          ),
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
                                  Text(entry.key, style: const TextStyle(fontSize: 16)),
                                  const SizedBox(width: 4),
                                  Text(
                                    entry.value.toString(),
                                    style: const TextStyle(fontWeight: FontWeight.w600),
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
            ),
          ],
        ),
      ),
    );
  }
}