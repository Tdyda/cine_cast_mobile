import 'package:flutter/material.dart';
import 'screens/home_screen.dart';
import 'screens/login_screen.dart';
import 'screens/catalog_screen.dart';
import 'navigation/app_routes.dart';
import 'services/api_service.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Provider dla autentykacji
class AuthProvider with ChangeNotifier {
  bool _isUserLoggedIn = false;

  bool get isUserLoggedIn => _isUserLoggedIn;

  Future<void> checkUserLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    final String? token = prefs.getString('token');
    
    if (token == null || token.isEmpty) {
      _isUserLoggedIn = false;
    } else {
      final int? expiryTimestamp = prefs.getInt('token_expiry');
      if (expiryTimestamp != null) {
        final DateTime expiryDate = DateTime.fromMillisecondsSinceEpoch(expiryTimestamp);
        if (expiryDate.isBefore(DateTime.now())) {
          _isUserLoggedIn = false;
        } else {
          _isUserLoggedIn = true;
        }
      }
    }
    notifyListeners();
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<AuthProvider>(
          create: (_) => AuthProvider()..checkUserLoggedIn(),
        ),
        Provider<ApiService>(create: (_) => ApiService()), // Dodanie ApiService jako provider
      ],
      child: Consumer<AuthProvider>(
        builder: (context, authProvider, _) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            theme: ThemeData.dark(),
            initialRoute: authProvider.isUserLoggedIn ? '/catalog' : '/login', // Wybór trasy na podstawie logowania
            routes: AppRoutes.routes,
          );
        },
      ),
    );
  }
}
