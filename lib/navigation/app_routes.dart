import 'package:flutter/material.dart';
import 'package:cine_cast/screens/home_screen.dart';
import 'package:cine_cast/screens/login_screen.dart';
import 'package:cine_cast/screens/catalog_screen.dart';

class AppRoutes {
  static const String home = '/';
  static const String login = '/login';
  static const String register = '/register';
  static const String catalog = '/catalog';

  static final Map<String, Widget Function(BuildContext)> routes = {
    home: (context) => const HomeScreen(),
    login: (context) => LoginScreen(),
    catalog: (context) => const CatalogScreen(),
  };

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case home:
        return MaterialPageRoute(builder: (_) => const HomeScreen());
      case login:
        return MaterialPageRoute(builder: (_) => LoginScreen());
      case catalog:
        return MaterialPageRoute(builder: (_) => const CatalogScreen());
      default:
        return MaterialPageRoute(
          builder: (_) => const Scaffold(
            body: Center(child: Text('Nieznana trasa')),
          ),
        );
    }
  }
}
