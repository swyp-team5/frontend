import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../common/auth/server_token_manager.dart';
import '../../../employer/home/notification/RNotificationModel.dart';
import '../../../employer/home/notification/api/notice_list_api.dart';

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

  final Dio _dio = Dio()..options.baseUrl = "https://chackchack.shop";
  late final NoticeListApi _noticeListApi = NoticeListApi(_dio);

  static const int _pageSize = 20;

  Future<int?> _getWorkPlaceId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt("selectedWorkPlaceId");
  }

  Future<void> fetchFirstPage() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final accessToken = await ServerTokenManager.getAccessToken();

      if (accessToken == null || accessToken.isEmpty) {
        throw Exception("로그인이 필요합니다.");
      }

      final workPlaceId = await _getWorkPlaceId();

      if (workPlaceId == null) {
        throw Exception("근무지 정보를 찾을 수 없습니다.");
      }

      final json = await _noticeListApi.getNotices(
        workPlaceId: workPlaceId,
        accessToken: accessToken,
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
      final accessToken = await ServerTokenManager.getAccessToken();

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
        accessToken: accessToken,
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
}

final ENotificationProvider =
StateNotifierProvider<ENotificationNotifier, ENotificationState>(
      (ref) => ENotificationNotifier(),
);