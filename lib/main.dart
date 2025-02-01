import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cine_cast/providers/auth_provider.dart';
import 'package:cine_cast/screens/home_screen.dart';
import 'package:cine_cast/screens/login_screen.dart';
import 'package:cine_cast/screens/catalog_screen.dart';
import 'package:cine_cast/services/api_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final authProvider = AuthProvider();
  await authProvider.checkAuthStatus();

  runApp(MyApp(authProvider: authProvider));
}

class MyApp extends StatelessWidget {
  final AuthProvider authProvider;

  MyApp({required this.authProvider});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: authProvider),
        Provider<ApiService>(create: (_) => ApiService()),
      ],
      child: Consumer<AuthProvider>(
        builder: (context, auth, _) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'CineCast',
            theme: ThemeData.dark(),
            initialRoute: auth.isAuthenticated ? '/' : '/login',
            routes: {
              '/': (context) => HomeScreen(),
              '/login': (context) => LoginScreen(),
              '/catalog': (context) => CatalogScreen(),
            },
          );
        },
      ),
    );
  }
}
