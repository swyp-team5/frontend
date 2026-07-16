import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../common/auth/server_token_manager.dart';
import 'RNotificationModel.dart';
import 'api/notice_list_api.dart';

class NoticeListState {
  final List<NoticeModel> notices;
  final bool isLoading;
  final bool isLoadingMore;
  final String? error;
  final int page;
  final int totalPages;

  const NoticeListState({
    this.notices = const [],
    this.isLoading = false,
    this.isLoadingMore = false,
    this.error,
    this.page = 0,
    this.totalPages = 1,
  });

  bool get hasMore => page + 1 < totalPages;

  NoticeListState copyWith({
    List<NoticeModel>? notices,
    bool? isLoading,
    bool? isLoadingMore,
    String? error,
    int? page,
    int? totalPages,
  }) {
    return NoticeListState(
      notices: notices ?? this.notices,
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      error: error,
      page: page ?? this.page,
      totalPages: totalPages ?? this.totalPages,
    );
  }
}

class RNotificationNotifier extends StateNotifier<NoticeListState> {
  RNotificationNotifier() : super(const NoticeListState());

  final NoticeListApi _api = NoticeListApi(ServerTokenManager.authorizedDio);

  static const int _pageSize = 20;

  Future<int?> _getWorkPlaceId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt("selectedWorkPlaceId");
  }

  Future<void> fetchFirstPage() async {

    state = state.copyWith(isLoading: true, error: null);

    try {
      final token = await ServerTokenManager.getValidAccessToken();
      final workPlaceId = await _getWorkPlaceId();

      debugPrint("=== fetchFirstPage 시작 ===");
      debugPrint("token: ${token != null ? '있음(${token.length}자)' : 'null'}");
      debugPrint("workPlaceId: $workPlaceId");

      if (token == null || token.isEmpty) {
        throw Exception("로그인이 필요합니다.");
      }
      if (workPlaceId == null) {
        throw Exception("근무지 정보를 찾을 수 없습니다.");
      }

      final json = await _api.getNotices(
        workPlaceId: workPlaceId,
        page: 0,
        size: _pageSize,
      );

      debugPrint("API 원본 응답: $json");

      final result = NoticePageResponse.fromJson(json);

      debugPrint("파싱된 공지 개수: ${result.content.length}");
      for (final n in result.content) {
        debugPrint(
            "noticeId=${n.noticeId} title=${n.title} images=${n.images.length} imageUrl=${n.imageUrl}");
      }

      state = state.copyWith(
        notices: result.content,
        isLoading: false,
        page: result.page,
        totalPages: result.totalPages,
      );

      debugPrint("=== fetchFirstPage 완료, state.notices.length=${state.notices.length} ===");
    } catch (e, stack) {
      debugPrint("🔴 fetchFirstPage 에러: $e");
      debugPrint("스택: $stack");
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> fetchNextPage() async {
    if (state.isLoadingMore || !state.hasMore) return;

    state = state.copyWith(isLoadingMore: true);

    try {
      final token = await ServerTokenManager.getValidAccessToken();
      final workPlaceId = await _getWorkPlaceId();

      if (token == null || workPlaceId == null) {
        state = state.copyWith(isLoadingMore: false);
        return;
      }

      final nextPage = state.page + 1;

      final json = await _api.getNotices(
        workPlaceId: workPlaceId,
        page: nextPage,
        size: _pageSize,
      );

      final result = NoticePageResponse.fromJson(json);

      state = state.copyWith(
        notices: [...state.notices, ...result.content],
        isLoadingMore: false,
        page: result.page,
        totalPages: result.totalPages,
      );
    } catch (e) {
      state = state.copyWith(isLoadingMore: false, error: e.toString());
    }
  }
}

final RNotificationProvider =
StateNotifierProvider<RNotificationNotifier, NoticeListState>(
      (ref) => RNotificationNotifier(),
);