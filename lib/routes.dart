import 'package:dentist_ms/core/constants/app_routes.dart';
import 'package:dentist_ms/core/widgets/adaptive_scaffold.dart';
import 'package:dentist_ms/features/auth/presentation/pages/login_page.dart';
import 'package:flutter/material.dart';


class AppRouter {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case AppRoutes.login:
        return MaterialPageRoute(builder: (_) => const LoginPage());

      case AppRoutes.dashboardShell:
        final arg = settings.arguments;
        final int initialIndex = (arg is int) ? arg : 0;
        return MaterialPageRoute(
          builder: (_) => AdaptiveScaffold(initialIndex: initialIndex),
        );

      default:
        return MaterialPageRoute(
          builder: (_) =>
              const Scaffold(body: Center(child: Text('404 - Page Not Found'))),
        );
    }
  }
}
