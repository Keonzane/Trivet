import 'package:device_preview/device_preview.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'screens/health_screen.dart';
import 'screens/leisure_screen.dart';
import 'screens/placeholder_screen.dart';
import 'screens/work_screen.dart';
import 'theme.dart';
import 'widgets/app_nav.dart';

void main() {
  runApp(
    DevicePreview(
      enabled: !kReleaseMode,
      builder: (context) => const TrivetApp(),
    ),
  );
}

class TrivetApp extends StatelessWidget {
  const TrivetApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Trivet',
      debugShowCheckedModeBanner: false,
      useInheritedMediaQuery: true,
      locale: DevicePreview.locale(context),
      builder: DevicePreview.appBuilder,
      theme: appTheme,
      darkTheme: appDarkTheme,
      themeMode: ThemeMode.system,
      home: const _AppShell(),
    );
  }
}

class _AppShell extends StatefulWidget {
  const _AppShell();

  @override
  State<_AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<_AppShell> {
  int _index = 0;

  static const _screens = [
    PlaceholderScreen(
      title: 'This week',
      note: 'Dashboard is scheduled for a later build.\n'
          'Work, Health and Leisure are live',
    ),
    WorkScreen(),
    HealthScreen(),
    LeisureScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.sizeOf(context).width >= 900;
    final nav = AppNav(
      selectedIndex: _index,
      onSelected: (i) => setState(() => _index = i),
    );

    if (isWide) {
      return Scaffold(
        body: Row(
          children: [
            nav,
            const VerticalDivider(width: 1),
            Expanded(child: _screens[_index]),
          ],
        ),
      );
    }

    return Scaffold(
      body: _screens[_index],
      bottomNavigationBar: nav,
    );
  }
}
