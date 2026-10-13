import 'package:flutter/material.dart';
import 'core/constants/app_strings.dart';
import 'core/theme/app_theme.dart';
import 'core/extensions/context_extension.dart';

class DepositGuardApp extends StatelessWidget {
  const DepositGuardApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppStrings.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: ThemeMode.system,
      home: const _PlaceholderScreen(),
    );
  }
}

/// Temporary screen to verify the theme. Replaced in the next step.
class _PlaceholderScreen extends StatelessWidget {
  const _PlaceholderScreen();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text(AppStrings.appName)),
      body: Center(
        child: Text(
          AppStrings.tagline,
          style: context.text.titleMedium,
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}