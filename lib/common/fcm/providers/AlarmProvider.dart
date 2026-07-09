import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../api/AlarmApi.dart';
import '../model/AlarmResponse.dart';

// 알림함 리스트 화면의 페이징 상태
// - cursorId 기반이라 "다음 페이지"는 마지막으로 받은 알림의 notificationId를 그대로 커서로 넘긴다.
class AlarmListState {
  final List<AlarmItem> alarms;
  final bool isLoading;
  final bool isLoadingMore;
  final String? error;
  final bool hasNext;

  const AlarmListState({
    this.alarms = const [],
    this.isLoading = false,
    this.isLoadingMore = false,
    this.error,
    this.hasNext = true,
  });

  AlarmListState copyWith({
    List<AlarmItem>? alarms,
    bool? isLoading,
    bool? isLoadingMore,
    String? error,
    bool? hasNext,
  }) {
    return AlarmListState(
      alarms: alarms ?? this.alarms,
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      error: error,
      hasNext: hasNext ?? this.hasNext,
    );
  }
}

class AlarmListNotifier extends StateNotifier<AlarmListState> {
  AlarmListNotifier() : super(const AlarmListState());

  static const int _pageSize = 20;

  // 최초 진입 / pull-to-refresh 시 첫 페이지부터 새로 로드
  Future<void> fetchFirstPage() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final result = await AlarmApi.getList(size: _pageSize);

      state = state.copyWith(
        alarms: result.content,
        isLoading: false,
        hasNext: result.hasNext,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString().replaceFirst("Exception: ", ""),
      );
    }
  }

  // 스크롤이 하단에 닿았을 때 다음 페이지 로드
  Future<void> fetchNextPage() async {
    if (state.isLoadingMore || !state.hasNext || state.alarms.isEmpty) return;

    state = state.copyWith(isLoadingMore: true);

    try {
      final lastId = state.alarms.last.notificationId;

      final result = await AlarmApi.getList(
        cursorId: lastId,
        size: _pageSize,
      );

      state = state.copyWith(
        alarms: [...state.alarms, ...result.content],
        isLoadingMore: false,
        hasNext: result.hasNext,
      );
    } catch (_) {
      state = state.copyWith(isLoadingMore: false);
    }
  }

  // 알림 단건 탭 시 읽음 처리 — 전체 재조회 대신 해당 아이템만 로컬에서 교체
  Future<void> markAsRead(int notificationId) async {
    final index =
    state.alarms.indexWhere((a) => a.notificationId == notificationId);
    if (index == -1 || state.alarms[index].read) return; // 이미 읽었으면 호출 생략

    try {
      final updated = await AlarmApi.readOne(notificationId: notificationId);

      state = state.copyWith(
        alarms: [
          for (final a in state.alarms)
            if (a.notificationId == notificationId) updated else a,
        ],
      );
    } catch (_) {
      // 읽음 처리 실패로 목록 UX 자체를 막을 필요는 없어서 조용히 무시한다
    }
  }
}

final alarmListProvider =
StateNotifierProvider<AlarmListNotifier, AlarmListState>(
      (ref) => AlarmListNotifier(),
);