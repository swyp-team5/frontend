import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'model/AlarmResponse.dart';
import 'providers/AlarmProvider.dart';

import '../auth/server_token_manager.dart';
import '../auth/model/social_auth_models.dart';
import '../../employer/home/notification/RNotificationPage.dart';
import '../../employer/home/widgets/RWorkChangeRequestListPage.dart';
import '../../employee/home/EHomePage.dart';
import '../../employee/home/notification/ENotificationPage.dart';
import '../../employee/mypage/ReceivedWorkChangeRequestsPage.dart';
import '../../employee/schedule/EMainSchedulePage.dart';

/// 알림 종류(notificationType)와 data를 참고해 관련 화면으로 이동한다.
/// 서버가 모든 알림에 workPlaceId를 data로 함께 내려주므로, data에서
/// 바로 꺼내 쓴다 (별도 저장소 폴백 불필요).
Future<void> _navigateForAlarm(BuildContext context, AlarmItem alarm) async {
  final data = alarm.data ?? {};

  int? intFromData(String key) {
    final raw = data[key];
    if (raw == null) return null;
    return int.tryParse(raw.toString());
  }

  final workPlaceId = intFromData("workPlaceId");

  switch (alarm.notificationType) {
    // 1. 공지 -> 공지내역 페이지
    case "NOTICE":
      if (workPlaceId == null) return;

      final token = await ServerTokenManager.getValidAccessToken();
      final role = token != null ? ServerTokenManager.roleFromToken(token) : null;
      if (!context.mounted) return;

      if (role == AuthMemberRole.owner) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => RNotificationPage(workPlaceId: workPlaceId),
          ),
        );
      } else {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const ENotificationPage()),
        );
      }
      break;

    // 2, 3, 10. 근무자 스케줄 조건 생성/초기화/제출 반려 -> 홈으로
    case "SCHEDULE_CONDITION_CREATED":
    case "SCHEDULE_CONDITION_RESET":
    case "WORKER_SELECT_REJECTED":
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const EHomePage()),
      );
      break;

    // 4, 5. 스케줄 생성/수정·추가 -> 근무자 스케줄 탭
    case "SCHEDULE_CONFIMED":
    case "SCHEDULE_UPDATED":
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const EMainSchedulePage()),
      );
      break;

    // 6, 8, 9. 근무자가 받는 교대/대타 요청 관련 알림 -> 근무자 받은 요청 내역
    case "WORK_CHANGE_REQUESTED":
    case "WORK_CHANGE_TARGET_REJECTED":
    case "WORK_CHANGE_OWNER_APPROVED":
    case "WORK_CHANGE_OWNER_REJECTED":
      if (workPlaceId == null) return;

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ReceivedWorkChangeRequestsPage(workPlaceId: workPlaceId),
        ),
      );
      break;

    // 7. 사장님이 받는 "근무자 수락" 알림 -> 사장 받은 승인 내역
    case "WORK_CHANGE_TARGET_ACCEPTED":
      if (workPlaceId == null) return;

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => RWorkChangeRequestListPage(workPlaceId: workPlaceId),
        ),
      );
      break;

    default:
      // 알 수 없는 알림 타입은 이동하지 않는다.
      break;
  }
}

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
                      separatorBuilder: (_, _) =>
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
      onTap: () async {
        ref.read(alarmListProvider.notifier).markAsRead(alarm.notificationId);
        await _navigateForAlarm(context, alarm);
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