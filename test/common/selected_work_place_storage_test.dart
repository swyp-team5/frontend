import 'package:chack_chack/common/workplace/selected_work_place_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  test('uses selectedWorkPlaceId as the shared preference key', () {
    expect(SelectedWorkPlaceStorage.key, 'selectedWorkPlaceId');
  });

  test('loads legacy selected_work_place_id and migrates it', () async {
    SharedPreferences.setMockInitialValues({
      SelectedWorkPlaceStorage.legacyKey: 42,
    });

    final id = await SelectedWorkPlaceStorage.load();
    final prefs = await SharedPreferences.getInstance();

    expect(id, 42);
    expect(prefs.getInt(SelectedWorkPlaceStorage.key), 42);
    expect(prefs.getInt(SelectedWorkPlaceStorage.legacyKey), isNull);
  });

  test('saves selected workplace using the standard key', () async {
    SharedPreferences.setMockInitialValues({});

    await SelectedWorkPlaceStorage.save(99);
    final prefs = await SharedPreferences.getInstance();

    expect(prefs.getInt(SelectedWorkPlaceStorage.key), 99);
  });
}
