import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cine_cast/navigation/app_routes.dart';
import 'package:cine_cast/providers/auth_provider.dart';
import 'package:flutter_svg/flutter_svg.dart';


class Navigation extends StatelessWidget {
  const Navigation({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, _) {
        return Drawer(
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              // Logo
              DrawerHeader(
                decoration: const BoxDecoration(color: Colors.black87),
                child: Center(
                  child: SvgPicture.asset(
                    'assets/images/logo.svg',
                    height: 50,
                  ),
                ),
              ),
              // Strona główna
              ListTile(
                leading: const Icon(Icons.home, color: Colors.white),
                title: const Text('Strona główna', style: TextStyle(color: Colors.white)),
                onTap: () {
                  Navigator.pushReplacementNamed(context, AppRoutes.home);
                },
              ),
              if (!authProvider.isAuthenticated) ...[
                // Logowanie
                ListTile(
                  leading: const Icon(Icons.login, color: Colors.white),
                  title: const Text('Logowanie', style: TextStyle(color: Colors.white)),
                  onTap: () {
                    Navigator.pushReplacementNamed(context, AppRoutes.login);
                  },
                ),
                // Rejestracja
                ListTile(
                  leading: const Icon(Icons.app_registration, color: Colors.white),
                  title: const Text('Rejestracja', style: TextStyle(color: Colors.white)),
                  onTap: () {
                    Navigator.pushReplacementNamed(context, AppRoutes.register);
                  },
                ),
              ],
              if (authProvider.isAuthenticated) ...[
                // Katalog filmów
                ListTile(
                  leading: const Icon(Icons.movie, color: Colors.white),
                  title: const Text('Katalog filmów', style: TextStyle(color: Colors.white)),
                  onTap: () {
                    Navigator.pushReplacementNamed(context, AppRoutes.catalog);
                  },
                ),
                // Kategorie
                // ListTile(
                //   leading: const Icon(Icons.category, color: Colors.white),
                //   title: const Text('Kategorie', style: TextStyle(color: Colors.white)),
                //   onTap: () {
                //     Navigator.pushReplacementNamed(context, '/tags');
                //   },
                // ),
                // Wylogowanie
                ListTile(
                  leading: const Icon(Icons.logout, color: Colors.white),
                  title: const Text('Wyloguj', style: TextStyle(color: Colors.white)),
                  onTap: () async {
                    await authProvider.logout();
                    Navigator.pushReplacementNamed(context, AppRoutes.login);
                  },
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}
