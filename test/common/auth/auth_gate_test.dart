import 'dart:convert';

import 'package:chack_chack/common/auth/auth_gate.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('missing token resolves onboarding', () async {
    final resolver = AuthDestinationResolver(tokenLoader: () async => null);

    expect(await resolver.resolve(), AuthDestination.onboarding);
  });

  test('valid OWNER token resolves owner home', () async {
    final resolver = AuthDestinationResolver(
      tokenLoader: () async => _jwt('OWNER'),
    );

    expect(await resolver.resolve(), AuthDestination.ownerHome);
  });

  test('valid WORKER token resolves worker home', () async {
    final resolver = AuthDestinationResolver(
      tokenLoader: () async => _jwt('WORKER'),
    );

    expect(await resolver.resolve(), AuthDestination.workerHome);
  });

  testWidgets('gate renders the resolved destination', (tester) async {
    final resolver = AuthDestinationResolver(
      tokenLoader: () async => _jwt('OWNER'),
    );

    await tester.pumpWidget(
      MaterialApp(
        home: AuthGate(
          resolver: resolver,
          onboardingBuilder: (_) => const Text('onboarding'),
          ownerHomeBuilder: (_) => const Text('owner home'),
          workerHomeBuilder: (_) => const Text('worker home'),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('owner home'), findsOneWidget);
    expect(find.text('onboarding'), findsNothing);
  });
}

String _jwt(String role) {
  String encode(Map<String, Object> value) =>
      base64Url.encode(utf8.encode(jsonEncode(value))).replaceAll('=', '');
  final expiresAt = DateTime.now().add(const Duration(minutes: 30));
  return '${encode({'alg': 'HS256', 'typ': 'JWT'})}.'
      '${encode({'exp': expiresAt.millisecondsSinceEpoch ~/ 1000, 'role': role, 'typ': 'ACCESS'})}.signature';
}
