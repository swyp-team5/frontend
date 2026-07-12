import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('employee profile image delete action is wired to deleteProfileImage', () {
    final source =
        File('lib/employee/mypage/EProfileEditPage.dart').readAsStringSync();

    expect(source, contains('Future<void> deleteProfileImage() async'));
    expect(source, contains('await deleteProfileImage();'));
    expect(source, isNot(contains('//   await deleteProfileImage();')));
  });
}
