import 'package:flutter/material.dart';
import 'package:rabis_abc_center/features/auth/presentation/screens/login_screen.dart';
import 'package:rabis_abc_center/features/dashboard/presentation/screens/dashboard_screen.dart';
import 'package:rabis_abc_center/features/dog_details/presentation/screens/dog_details_screen.dart';

class AppRouter {
  static const String login = '/';
  static const String dashboard = '/dashboard';
  static const String dogDetails = '/dog-details';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case login:
        return MaterialPageRoute(builder: (_) => const LoginScreen());
      case dashboard:
        return MaterialPageRoute(builder: (_) => const DashboardScreen());
      case dogDetails:
        final dogId = settings.arguments as String?;
        return MaterialPageRoute(
          builder: (_) => DogDetailsScreen(dogId: dogId),
        );
      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(
              child: Text('No route defined for ${settings.name}'),
            ),
          ),
        );
    }
  }
}
