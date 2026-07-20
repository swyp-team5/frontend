import 'package:chack_chack/common/auth/auth_session_expiry_navigator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('session expiry replaces the full stack with login', (
    tester,
  ) async {
    final navigatorKey = GlobalKey<NavigatorState>();
    final expiryNavigator = AuthSessionExpiryNavigator(
      navigatorKey: navigatorKey,
      loginBuilder: (_) => const _TestPage(label: 'login'),
    );

    await tester.pumpWidget(
      MaterialApp(
        navigatorKey: navigatorKey,
        home: const _TestPage(label: 'home'),
      ),
    );
    navigatorKey.currentState!.push(
      MaterialPageRoute(builder: (_) => const _TestPage(label: 'details')),
    );
    await tester.pumpAndSettle();

    expiryNavigator.handleExpiry();
    expiryNavigator.handleExpiry();
    await tester.pumpAndSettle();

    expect(find.text('login'), findsOneWidget);
    expect(find.text('home'), findsNothing);
    expect(find.text('details'), findsNothing);
  });
}

class _TestPage extends StatelessWidget {
  final String label;

  const _TestPage({required this.label});

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: Center(child: Text(label)));
  }
}
