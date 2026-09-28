import 'package:device_preview/device_preview.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'models/media_entry.dart';
import 'screens/dashboard_screen.dart';
import 'screens/health_screen.dart';
import 'screens/leisure_screen.dart';
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

  // Only Want-status onward matters here; Leisure defaults to Want when
  // opened normally, and switches to In progress when Dashboard's SEE ALL
  // is tapped — matching the mockup's "opens 04 Leisure filtered to In
  // progress" spec.
  MediaStatus _leisureFilter = MediaStatus.want;

  // Rebuilt on every build() rather than kept as a static const list, since
  // DashboardScreen now needs a closure (onSeeAllLeisure), which a const
  // constructor can't hold. This costs nothing extra: only the screen at
  // `_index` is ever mounted (see the body below), so the other three
  // screens in this list are never actually built regardless.
  List<Widget> _buildScreens() => [
        DashboardScreen(
          onSeeAllLeisure: () => setState(() {
            _leisureFilter = MediaStatus.inProgress;
            _index = 3;
          }),
        ),
        const WorkScreen(),
        const HealthScreen(),
        LeisureScreen(initialFilter: _leisureFilter),
      ];

  @override
  Widget build(BuildContext context) {
    final screens = _buildScreens();
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
            Expanded(child: screens[_index]),
          ],
        ),
      );
    }

    return Scaffold(
      body: screens[_index],
      bottomNavigationBar: nav,
    );
  }
}
