import 'package:flutter/material.dart';
import 'package:life_saarthi_app/app/app_shell.dart';

import 'theme/app_theme.dart';

class LifeSaarthiApp extends StatelessWidget {
  const LifeSaarthiApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Life Saarthi',

      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,

      home: const AppShell(),
    );
  }
}
