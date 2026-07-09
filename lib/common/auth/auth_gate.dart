import 'package:flutter/material.dart';

import '../../employee/home/EHomePage.dart';
import '../../employer/home/RHomePage.dart';
import '../onboarding/OnboardingPage.dart';
import 'model/social_auth_models.dart';
import 'server_token_manager.dart';

enum AuthDestination { onboarding, ownerHome, workerHome }

class AuthDestinationResolver {
  final Future<String?> Function() tokenLoader;

  AuthDestinationResolver({Future<String?> Function()? tokenLoader})
    : tokenLoader = tokenLoader ?? ServerTokenManager.getValidAccessToken;

  Future<AuthDestination> resolve() async {
    final token = await tokenLoader();
    if (token == null) {
      return AuthDestination.onboarding;
    }
    switch (ServerTokenManager.roleFromToken(token)) {
      case AuthMemberRole.owner:
        return AuthDestination.ownerHome;
      case AuthMemberRole.worker:
        return AuthDestination.workerHome;
      case null:
        return AuthDestination.onboarding;
    }
  }
}

class AuthGate extends StatefulWidget {
  final AuthDestinationResolver? resolver;
  final WidgetBuilder? onboardingBuilder;
  final WidgetBuilder? ownerHomeBuilder;
  final WidgetBuilder? workerHomeBuilder;

  const AuthGate({
    super.key,
    this.resolver,
    this.onboardingBuilder,
    this.ownerHomeBuilder,
    this.workerHomeBuilder,
  });

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  late final Future<AuthDestination> _destination;

  @override
  void initState() {
    super.initState();
    _destination = (widget.resolver ?? AuthDestinationResolver()).resolve();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<AuthDestination>(
      future: _destination,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Scaffold(
            backgroundColor: Colors.white,
            body: Center(child: CircularProgressIndicator()),
          );
        }

        switch (snapshot.data ?? AuthDestination.onboarding) {
          case AuthDestination.ownerHome:
            return (widget.ownerHomeBuilder ?? (_) => const RHomePage())(
              context,
            );
          case AuthDestination.workerHome:
            return (widget.workerHomeBuilder ?? (_) => const EHomePage())(
              context,
            );
          case AuthDestination.onboarding:
            return (widget.onboardingBuilder ?? (_) => const OnboardingPage())(
              context,
            );
        }
      },
    );
  }
}
