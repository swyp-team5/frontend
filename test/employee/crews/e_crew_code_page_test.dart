import 'package:chack_chack/employee/crews/ECrewCodePage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('invite code fields fit a 384px wide screen', (tester) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(384, 800);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(
      const MaterialApp(home: ECrewCodePage()),
    );
    await tester.pump();

    expect(find.byType(TextField), findsNWidgets(6));
    expect(tester.takeException(), isNull);

    final screenWidth = tester.view.physicalSize.width /
        tester.view.devicePixelRatio;
    for (final element in find.byType(TextField).evaluate()) {
      final rect = tester.getRect(find.byWidget(element.widget));
      expect(rect.left, greaterThanOrEqualTo(0));
      expect(rect.right, lessThanOrEqualTo(screenWidth));
    }
  });
}
