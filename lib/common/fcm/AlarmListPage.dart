import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'model/AlarmResponse.dart';
import 'providers/AlarmProvider.dart';

// 종 아이콘을 눌렀을 때 진입하는 알림함(Alarm) 리스트 화면.
// - 공지사항 목록(RNotificationPage)과 다른 도메인이라 별도 페이지로 분리했다.
// - 사장님/근무자 공용 화면이라 role별 BottomNavBar는 두지 않고 뒤로가기만 제공한다.
class AlarmListPage extends ConsumerStatefulWidget {
  const AlarmListPage({super.key});

  @override
  ConsumerState<AlarmListPage> createState() => _AlarmListPageState();
}

class _AlarmListPageState extends ConsumerState<AlarmListPage> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();

    Future.microtask(() {
      ref.read(alarmListProvider.notifier).fetchFirstPage();
    });

    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
          _scrollController.position.maxScrollExtent - 200) {
        ref.read(alarmListProvider.notifier).fetchNextPage();
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
    final state = ref.watch(alarmListProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () => ref.read(alarmListProvider.notifier).fetchFirstPage(),
          child: SingleChildScrollView(
            controller: _scrollController,
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                /// 헤더 (뒤로가기 + 중앙 타이틀)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: const Icon(Icons.arrow_back_ios_new, size: 22),
                      ),
                      const Expanded(
                        child: Center(
                          child: Text(
                            '알림',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                      const SizedBox(width: 22), // 뒤로가기 아이콘과 대칭 맞추는 spacer
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
                          Text(state.error!, style: const TextStyle(color: Colors.red)),
                          const SizedBox(height: 12),
                          ElevatedButton(
                            onPressed: () =>
                                ref.read(alarmListProvider.notifier).fetchFirstPage(),
                            child: const Text("다시 시도"),
                          ),
                        ],
                      ),
                    ),
                  )
                else if (state.alarms.isEmpty)
                    const Padding(
                      padding: EdgeInsets.only(top: 100),
                      child: Center(
                        child: Text(
                          '도착한 알림이 없어요',
                          style: TextStyle(fontSize: 15, color: Color(0xFF999999)),
                        ),
                      ),
                    )
                  else
                    ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: state.alarms.length,
                      separatorBuilder: (_, __) =>
                      const Divider(height: 1, color: Color(0xFFF2F2F2)),
                      itemBuilder: (context, index) {
                        final alarm = state.alarms[index];
                        return _AlarmTile(alarm: alarm);
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
    );
  }
}

class _AlarmTile extends ConsumerWidget {
  final AlarmItem alarm;

  const _AlarmTile({required this.alarm});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 안읽음: 연한 파란 배경 / 읽음: 흰 배경 + 아이콘·텍스트 회색톤
    final backgroundColor = alarm.read ? Colors.white : const Color(0xFFEAF3FF);
    final iconOpacity = alarm.read ? 0.4 : 1.0;
    final titleColor = alarm.read ? const Color(0xFF999999) : Colors.black;
    final labelColor = alarm.read ? const Color(0xFFBBBBBB) : const Color(0xFF767676);

    return InkWell(
      onTap: () {
        ref.read(alarmListProvider.notifier).markAsRead(alarm.notificationId);
        // TODO: notificationType(NOTICE 등)에 따라 관련 상세 화면으로 이동하는 라우팅은
        // 알림 종류가 확정되면 여기서 alarm.data를 참고해 분기 처리한다.
      },
      child: Container(
        color: backgroundColor,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Opacity(
              opacity: iconOpacity,
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: const Color(0xFF0084FF),
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.all(8),
                child: Image.asset(
                  "assets/images/logo/chackchack.png",
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    alarm.title,
                    style: TextStyle(fontSize: 12, color: labelColor),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    alarm.body,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: alarm.read ? FontWeight.w500 : FontWeight.bold,
                      color: titleColor,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    alarm.relativeTime,
                    style: const TextStyle(fontSize: 12, color: Color(0xFF999999)),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}