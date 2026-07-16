import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../common/auth/server_token_manager.dart';
import '../../../employer/home/notification/RNotificationModel.dart';
import '../../../employer/home/notification/api/notice_list_api.dart';
import 'api/notice_reaction_api.dart';

class ENotificationState {
  final List<NoticeModel> notices;
  final bool isLoading;
  final bool isLoadingMore;
  final String? error;
  final int currentPage;
  final bool hasNextPage;

  const ENotificationState({
    this.notices = const [],
    this.isLoading = false,
    this.isLoadingMore = false,
    this.error,
    this.currentPage = 0,
    this.hasNextPage = true,
  });

  ENotificationState copyWith({
    List<NoticeModel>? notices,
    bool? isLoading,
    bool? isLoadingMore,
    String? error,
    int? currentPage,
    bool? hasNextPage,
  }) {
    return ENotificationState(
      notices: notices ?? this.notices,
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      error: error,
      currentPage: currentPage ?? this.currentPage,
      hasNextPage: hasNextPage ?? this.hasNextPage,
    );
  }
}

class ENotificationNotifier extends StateNotifier<ENotificationState> {
  ENotificationNotifier() : super(const ENotificationState());

  late final NoticeListApi _noticeListApi = NoticeListApi(ServerTokenManager.authorizedDio);
  late final NoticeReactionApi _noticeReactionApi = NoticeReactionApi(ServerTokenManager.authorizedDio);

  static const int _pageSize = 20;

  Future<int?> _getWorkPlaceId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt("selectedWorkPlaceId");
  }

  Future<void> fetchFirstPage() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final accessToken = await ServerTokenManager.getValidAccessToken();

      if (accessToken == null || accessToken.isEmpty) {
        throw Exception("로그인이 필요합니다.");
      }

      final workPlaceId = await _getWorkPlaceId();

      if (workPlaceId == null) {
        throw Exception("근무지 정보를 찾을 수 없습니다.");
      }

      final json = await _noticeListApi.getNotices(
        workPlaceId: workPlaceId,
        page: 0,
        size: _pageSize,
      );

      final result = NoticePageResponse.fromJson(json);

      state = state.copyWith(
        notices: result.content,
        isLoading: false,
        currentPage: 0,
        hasNextPage: result.page + 1 < result.totalPages,
        error: null,
      );

      debugPrint("=== ENotification fetchFirstPage 완료, count=${result.content.length} ===");
    } catch (e) {
      debugPrint("🔴 ENotification fetchFirstPage 실패: $e");

      state = state.copyWith(
        isLoading: false,
        error: e.toString().replaceFirst("Exception: ", ""),
      );
    }
  }

  Future<void> fetchNextPage() async {
    if (state.isLoadingMore || !state.hasNextPage) return;

    state = state.copyWith(isLoadingMore: true);

    try {
      final accessToken = await ServerTokenManager.getValidAccessToken();

      if (accessToken == null || accessToken.isEmpty) {
        throw Exception("로그인이 필요합니다.");
      }

      final workPlaceId = await _getWorkPlaceId();

      if (workPlaceId == null) {
        throw Exception("근무지 정보를 찾을 수 없습니다.");
      }

      final nextPage = state.currentPage + 1;

      final json = await _noticeListApi.getNotices(
        workPlaceId: workPlaceId,
        page: nextPage,
        size: _pageSize,
      );

      final result = NoticePageResponse.fromJson(json);

      state = state.copyWith(
        notices: [...state.notices, ...result.content],
        isLoadingMore: false,
        currentPage: nextPage,
        hasNextPage: result.page + 1 < result.totalPages,
      );
    } catch (e) {
      debugPrint("🔴 ENotification fetchNextPage 실패: $e");
      state = state.copyWith(isLoadingMore: false);
    }
  }

  // 공감 선택/변경/취소 — 근무자 전용.
  // 성공하면 목록(state.notices) 안의 해당 공지만 갱신해서, 상세에서 목록으로 돌아가도
  // 최신 집계가 바로 보이게 한다. 호출부(상세 페이지)가 로컬 상태도 갱신할 수 있도록 결과를 반환한다.
  Future<NoticeReactionResult> selectReaction({
    required int noticeId,
    required String reactionType,
  }) async {
    final accessToken = await ServerTokenManager.getValidAccessToken();

    if (accessToken == null || accessToken.isEmpty) {
      throw Exception("로그인이 필요합니다.");
    }

    final result = await _noticeReactionApi.selectReaction(
      noticeId: noticeId,
      accessToken: accessToken,
      reactionType: reactionType,
    );

    state = state.copyWith(
      notices: [
        for (final n in state.notices)
          if (n.noticeId == noticeId)
            n.copyWith(
              myReactionType: result.myReactionType,
              reactions: result.reactions,
            )
          else
            n,
      ],
    );

    return result;
  }
}

final ENotificationProvider =
StateNotifierProvider<ENotificationNotifier, ENotificationState>(
      (ref) => ENotificationNotifier(),
);