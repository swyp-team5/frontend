import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'ENotificationModel.dart';

final ENotificationProvider = StateNotifierProvider<ENotificationNotifier, List<ENotificationModel>>((ref) {
  return ENotificationNotifier();
});

class ENotificationNotifier extends StateNotifier<List<ENotificationModel>> {
  ENotificationNotifier() : super([]) {
    _init();
  }

  static const String _key = 'notifications_persistence_key';

  Future<void> _init() async {
    await _loadNotices();
  }

  // 저장소에서 데이터 불러오기
  Future<void> _loadNotices() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? jsonString = prefs.getString(_key);
      if (jsonString != null) {
        final List<dynamic> jsonList = json.decode(jsonString);
        state = jsonList.map((e) => ENotificationModel.fromJson(e)).toList();
      }
    } catch (e) {
      print('공지사항 로드 오류: $e');
    }
  }

  // 공지사항 추가 (최신순)
  Future<void> addNotice(ENotificationModel notice) async {
    state = [notice, ...state];
    await _saveToPrefs();
  }

  // 반응 추가
  Future<void> addReaction(int index, String emoji) async {
    if (index < 0 || index >= state.length) return;

    final List<ENotificationModel> currentList = [...state];
    final target = currentList[index];

    currentList[index] = target.copyWith(
      reactions: [...target.reactions, emoji],
    );

    state = currentList;
    await _saveToPrefs();
  }

  // 실제 물리 저장소에 쓰기
  Future<void> _saveToPrefs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String jsonString = json.encode(state.map((e) => e.toJson()).toList());
      await prefs.setString(_key, jsonString);
    } catch (e) {
      print('공지사항 저장 오류: $e');
    }
  }
}