import 'package:shared_preferences/shared_preferences.dart';

class SelectedWorkPlaceStorage {
  static const key = 'selectedWorkPlaceId';
  static const legacyKey = 'selected_work_place_id';

  static Future<int?> load() async {
    final prefs = await SharedPreferences.getInstance();
    final current = prefs.getInt(key);
    if (current != null) {
      return current;
    }

    final legacy = prefs.getInt(legacyKey);
    if (legacy != null) {
      await save(legacy);
      await prefs.remove(legacyKey);
    }
    return legacy;
  }

  static Future<void> save(int workPlaceId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(key, workPlaceId);
  }
}
