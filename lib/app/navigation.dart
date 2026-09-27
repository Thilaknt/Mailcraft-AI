import 'package:flutter/material.dart';

import '../features/about/about_screen.dart';
import '../features/assistant/assistant_screen.dart';
import '../features/generator/generator_screen.dart';
import '../features/navigation/main_screen.dart';
import '../features/result/result_screen.dart';
import '../features/settings/settings_screen.dart';

class AppRoutes {
  static const String homeRoute = '/';
  static const String assistantRoute = '/assistant';
  static const String generatorRoute = '/generator';
  static const String resultRoute = '/result';
  static const String historyRoute = '/history';
  static const String settingsRoute = '/settings';
  static const String aboutRoute = '/about';
  static const String templatesRoute = '/templates';

  static Route<dynamic> generateRoute(RouteSettings routeSettings) {
    switch (routeSettings.name) {
      case assistantRoute:
        return PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) => const AssistantScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            const begin = Offset(0.0, 0.08);
            const end = Offset.zero;
            const curve = Curves.easeOutCubic;

            var slideTween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
            var fadeTween = Tween<double>(begin: 0.0, end: 1.0).chain(CurveTween(curve: curve));

            return SlideTransition(
              position: animation.drive(slideTween),
              child: FadeTransition(
                opacity: animation.drive(fadeTween),
                child: child,
              ),
            );
          },
          transitionDuration: const Duration(milliseconds: 300),
        );

      case generatorRoute:
        final args = routeSettings.arguments as Map<String, dynamic>?;
        return PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) => GeneratorScreen(
            initialMode: args?['mode'] as String?,
          ),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            const begin = Offset(0.0, 0.08);
            const end = Offset.zero;
            const curve = Curves.easeOutCubic;

            var slideTween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
            var fadeTween = Tween<double>(begin: 0.0, end: 1.0).chain(CurveTween(curve: curve));

            return SlideTransition(
              position: animation.drive(slideTween),
              child: FadeTransition(
                opacity: animation.drive(fadeTween),
                child: child,
              ),
            );
          },
          transitionDuration: const Duration(milliseconds: 350),
        );

      case resultRoute:
        final args = routeSettings.arguments as Map<String, dynamic>?;
        return MaterialPageRoute(
          builder: (_) => ResultScreen(
            response: args!['response'],
            request: args['request'],
          ),
        );

      case historyRoute:
        return MaterialPageRoute(
          builder: (_) => const MainNavigationShell(initialIndex: 3),
        );

      case settingsRoute:
        return MaterialPageRoute(
          builder: (_) => const SettingsScreen(),
        );

      case aboutRoute:
        return MaterialPageRoute(
          builder: (_) => const AboutScreen(),
        );

      case templatesRoute:
        return MaterialPageRoute(
          builder: (_) => const MainNavigationShell(initialIndex: 2),
        );

      case homeRoute:
      default:
        return MaterialPageRoute(
          builder: (_) => const MainNavigationShell(initialIndex: 0),
        );
    }
  }
}