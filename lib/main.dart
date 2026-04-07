import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rabis_abc_center/core/theme/app_theme.dart';
import 'package:rabis_abc_center/core/router/app_router.dart';
import 'package:rabis_abc_center/features/auth/presentation/providers/auth_notifier.dart';
import 'package:rabis_abc_center/features/auth/presentation/screens/login_screen.dart';
import 'package:rabis_abc_center/features/dashboard/presentation/screens/dashboard_screen.dart';

void main() {
  runApp(
    const ProviderScope(
      child: ABCDogTrackingApp(),
    ),
  );
}

class ABCDogTrackingApp extends ConsumerStatefulWidget {
  const ABCDogTrackingApp({super.key});

  @override
  ConsumerState<ABCDogTrackingApp> createState() => _ABCDogTrackingAppState();
}

class _ABCDogTrackingAppState extends ConsumerState<ABCDogTrackingApp> {
  @override
  void initState() {
    super.initState();
    // Trigger session check on app startup
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(authProvider.notifier).checkSession();
    });
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);

    return MaterialApp(
      title: 'ABC Dog Tracking System',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.light,
      onGenerateRoute: AppRouter.generateRoute,
      home: _getHome(authState),
    );
  }

  Widget _getHome(AuthState authState) {
    if (!authState.isInitialized) {
      return const Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('Checking session...', style: TextStyle(color: Colors.grey)),
            ],
          ),
        ),
      );
    }

    return authState.user != null ? const DashboardScreen() : const LoginScreen();
  }
}
