import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rabis_abc_center/core/theme/app_theme.dart';
import 'package:rabis_abc_center/core/router/app_router.dart';

void main() {
  runApp(
    const ProviderScope(
      child: ABCDogTrackingApp(),
    ),
  );
}

class ABCDogTrackingApp extends StatelessWidget {
  const ABCDogTrackingApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ABC Dog Tracking System',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.light,
      onGenerateRoute: AppRouter.generateRoute,
      initialRoute: AppRouter.login,
    );
  }
}
