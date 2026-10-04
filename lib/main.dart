import 'package:device_preview/device_preview.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'models/media_entry.dart';
import 'screens/dashboard_screen.dart';
import 'screens/health_screen.dart';
import 'screens/leisure_screen.dart';
import 'screens/work_screen.dart';
import 'services/theme_controller.dart';
import 'theme.dart';
import 'widgets/app_nav.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await ThemeController.instance.load();
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
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: ThemeController.instance,
      builder: (context, themeMode, _) => MaterialApp(
        title: 'Trivet',
        debugShowCheckedModeBanner: false,
        locale: DevicePreview.locale(context),
        builder: DevicePreview.appBuilder,
        theme: appTheme,
        darkTheme: appDarkTheme,
        themeMode: themeMode,
        home: const _AppShell(),
      ),
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

  MediaStatus _leisureFilter = MediaStatus.want;

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
      onSelected: (i) => setState(() {
        _index = i;
        _leisureFilter = MediaStatus.want;
      }),
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
