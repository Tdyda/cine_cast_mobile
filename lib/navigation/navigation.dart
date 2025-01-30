// lib/navigation/navigation.dart

import 'package:flutter/material.dart';
import 'package:cine_cast/navigation/app_routes.dart';

class Navigation extends StatelessWidget {
  final bool isUserLoggedIn;
  final bool isAdmin;

  const Navigation({
    Key? key,
    required this.isUserLoggedIn,
    required this.isAdmin,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          // Logo
          DrawerHeader(
            decoration: BoxDecoration(color: Colors.black87),
            child: Center(
              child: Image.asset(
                'assets/logo.png',
                height: 50,
              ),
            ),
          ),
          // Strona główna
          ListTile(
            leading: Icon(Icons.home, color: Colors.white),
            title: Text('Strona główna', style: TextStyle(color: Colors.white)),
            onTap: () {
              Navigator.popAndPushNamed(
                  context, AppRoutes.home); // Zamykanie Drawer + nawigacja
            },
          ),
          if (!isUserLoggedIn) ...[
            // Logowanie
            ListTile(
              leading: Icon(Icons.login, color: Colors.white),
              title: Text('Logowanie', style: TextStyle(color: Colors.white)),
              onTap: () {
                Navigator.popAndPushNamed(
                    context, AppRoutes.login); // Zamykanie Drawer + nawigacja
              },
            ),
            // Rejestracja
            ListTile(
              leading: Icon(Icons.app_registration, color: Colors.white),
              title: Text('Rejestracja', style: TextStyle(color: Colors.white)),
              onTap: () {
                Navigator.popAndPushNamed(context,
                    AppRoutes.register); // Zamykanie Drawer + nawigacja
              },
            ),
          ],
          if (isUserLoggedIn) ...[
            // Katalog filmów
            ListTile(
              leading: Icon(Icons.movie, color: Colors.white),
              title:
                  Text('Katalog filmów', style: TextStyle(color: Colors.white)),
              onTap: () {
                Navigator.popAndPushNamed(
                    context, AppRoutes.catalog); // Zamykanie Drawer + nawigacja
              },
            ),
            // Kategorie
            ListTile(
              leading: Icon(Icons.category, color: Colors.white),
              title: Text('Kategorie', style: TextStyle(color: Colors.white)),
              onTap: () {
                Navigator.popAndPushNamed(
                    context, '/tags'); // Zamykanie Drawer + nawigacja
              },
            ),
            // Wylogowanie
            ListTile(
              leading: Icon(Icons.logout, color: Colors.white),
              title: Text('Wyloguj', style: TextStyle(color: Colors.white)),
              onTap: () {
                Navigator.popAndPushNamed(
                    context, '/logout'); // Zamykanie Drawer + nawigacja
              },
            ),
          ],
        ],
      ),
    );
  }
}
