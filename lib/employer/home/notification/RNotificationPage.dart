import 'package:chack_chack/employer/home/notification/widgets/NoticeImageCacheBuster.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:dio/dio.dart';

import '../../../common/widgets/BottomNavBar.dart';
import '../../../common/auth/server_token_manager.dart';
import '../../crews/RCrewPage.dart';
import '../../mypage/RMyPage.dart';
import '../../mypage/api/profile_api.dart';
import '../RHomePage.dart';
import 'RNotiDetailPage.dart';
import 'RNotificationProvider.dart';
import 'RNotiWritingPage.dart';
import 'RNotificationModel.dart';

class RNotificationPage extends ConsumerStatefulWidget {
  final int workPlaceId;

  const RNotificationPage({super.key, required this.workPlaceId});

  @override
  ConsumerState<RNotificationPage> createState() => _RNotificationPageState();
}

class _RNotificationPageState extends ConsumerState<RNotificationPage> {
  final ScrollController _scrollController = ScrollController();

  // 사장님(작성자) 프로필 - 공지 리스트와 별개로 독립 조회
  String ownerName = "사장님";
  String? ownerProfileImageUrl;

  final ProfileApi profileApi = ProfileApi(
    Dio(
      BaseOptions(
        baseUrl: "https://chackchack.shop",
      ),
    ),
  );

  @override
  void initState() {
    super.initState();

    Future.microtask(() {
      ref.read(RNotificationProvider.notifier).fetchFirstPage();
    });

    _loadOwnerProfile();

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

  /// 사장님(나) 프로필 조회 - 공지 목록 조회 성공 여부와 무관하게 독립적으로 동작
  Future<void> _loadOwnerProfile() async {
    try {
      final token = await ServerTokenManager.getValidAccessToken();

      if (token == null) {
        debugPrint("[RNotificationPage] 토큰 없음");
        return;
      }

      final profile = await profileApi.getMyProfile(token: token);

      debugPrint("[RNotificationPage] 사장님 프로필 조회 성공: $profile");

      if (!mounted) return;

      setState(() {
        ownerName = profile["name"]?.toString() ?? "사장님";
        ownerProfileImageUrl = profile["profileImage"]?["imageUrl"];
      });
    } catch (e) {
      debugPrint("🔴 [RNotificationPage] 사장님 프로필 조회 실패: $e");
    }
  }

  /// 서버가 같은 objectKey/URL 경로에 이미지를 덮어쓰는 구조라면,
  /// Flutter의 Image 위젯은 NetworkImage의 URL이 이전과 완전히 같으면
  /// (ImageCache를 비워도) 새로 네트워크 요청을 하지 않고 기존 이미지
  /// 스트림을 그대로 유지해버린다. 그래서 "실제로 값이 바뀌는" 쿼리
  /// 파라미터를 URL 뒤에 붙여서 캐시를 무효화해야 한다.
  ///
  /// 우선순위:
  /// 1) NoticeImageCacheBuster에 기록된 값이 있으면 그걸 사용한다.
  ///    → RNotiEditPage에서 수정(이미지 포함)이 성공할 때마다
  ///      해당 noticeId의 버전을 현재 시각으로 갱신해두기 때문에,
  ///      수정 직후에는 반드시 새로운 값이 붙어 새 이미지를 받아온다.
  /// 2) 기록된 값이 없으면(한 번도 수정된 적 없는 공지) 기존 방식대로
  ///    noticeId_date를 사용한다.
  String _cacheBustedUrl(NoticeModel notice) {
    final url = notice.imageUrl!;
    final separator = url.contains('?') ? '&' : '?';
    final bumpedVersion = NoticeImageCacheBuster.versionFor(notice.noticeId);
    final version = bumpedVersion?.toString() ?? '${notice.noticeId}_${notice.date}';
    return '$url${separator}v=$version';
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
                        final activeReactions = notice.activeReactions;

                        return InkWell(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => RNotiDetailPage(
                                  noticeId: notice.noticeId,
                                  initialNotice: notice,
                                ),
                              ),
                            );
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(20),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                /// 작성자
                                Row(
                                  children: [
                                    CircleAvatar(
                                      radius: 20,
                                      backgroundColor: Colors.grey.shade300,
                                      backgroundImage: (ownerProfileImageUrl !=
                                          null &&
                                          ownerProfileImageUrl!.isNotEmpty)
                                          ? NetworkImage(
                                          ownerProfileImageUrl!)
                                          : const AssetImage(
                                          "assets/images/profile.png")
                                      as ImageProvider,
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
                                    // const Icon(
                                    //   Icons.more_horiz,
                                    //   color: Colors.grey,
                                    // ),
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
                                            // ✅ 캐시 무효화 파라미터를 붙여서
                                            // 수정 후에도 새 이미지가 보이도록 함
                                            _cacheBustedUrl(notice),
                                            // notice.noticeId를 key로 넘겨서,
                                            // URL 문자열이 우연히 같더라도
                                            // Flutter가 이 Image 위젯을
                                            // "다른 위젯"으로 인식하고
                                            // 새로 이미지를 다시 resolve하도록
                                            // 보장한다.
                                            key: ValueKey(
                                              '${notice.noticeId}_${NoticeImageCacheBuster.versionFor(notice.noticeId) ?? notice.date}',
                                            ),
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
                                if (activeReactions.isNotEmpty)
                                  Wrap(
                                    spacing: 10,
                                    runSpacing: 10,
                                    children: activeReactions
                                        .map(
                                          (r) => Container(
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
                                            if (reactionAssetMap[r.reactionType] != null)
                                              SvgPicture.asset(
                                                reactionAssetMap[r.reactionType]!,
                                                width: 16,
                                                height: 16,
                                              ),
                                            const SizedBox(width: 4),
                                            Text(
                                              r.count.toString(),
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