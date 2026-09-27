import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/theme/app_theme.dart';
import '../features/splash/splash_screen.dart';
import '../repositories/history_repository.dart';
import '../services/history_service.dart';
import '../viewmodels/assistant_viewmodel.dart';
import '../viewmodels/compose_viewmodel.dart';
import '../viewmodels/history_viewmodel.dart';
import 'navigation.dart';

class MailCraftApp extends StatefulWidget {
  const MailCraftApp({super.key});

  @override
  State<MailCraftApp> createState() => _MailCraftAppState();
}

class _MailCraftAppState extends State<MailCraftApp> {
  ThemeMode _themeMode = ThemeMode.dark;

  void _toggleTheme() {
    setState(() {
      _themeMode = _themeMode == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ComposeViewModel()),
        ChangeNotifierProvider(create: (_) => AssistantViewModel()),
        ChangeNotifierProvider(
          create: (_) => HistoryViewModel(
            repository: HistoryRepository(service: HistoryService()),
          ),
        ),
      ],
      child: MaterialApp(
        title: 'MailCraft AI',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: _themeMode,
        onGenerateRoute: AppRoutes.generateRoute,
        home: SplashScreen(
          onToggleTheme: _toggleTheme,
          isDarkMode: _themeMode == ThemeMode.dark,
        ),
      ),
    );
  }
}
