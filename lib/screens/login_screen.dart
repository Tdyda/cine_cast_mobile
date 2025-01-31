import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/api_service.dart';
import 'package:provider/provider.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  String? _errorMessage;

  // Funkcja do zapisywania tokenu w shared_preferences
  Future<void> _saveToken(
      String token, String refreshToken, String userId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('token', token);
    await prefs.setString('refreshToken', refreshToken);
    await prefs.setString('userId', userId);
  }

  static Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  Future<void> _handleLogin() async {
    final apiService = Provider.of<ApiService>(context, listen: false);

    setState(() {
      _errorMessage = null;
    });

    final String email = _emailController.text;
    final String password = _passwordController.text;

    try {
      final response = await apiService.postRequest(
        '/Account/login', // endpoint
        {
          'email': email,
          'password': password,
        },
      );
      
      if (response.statusCode == 200) {
        
        final data = response.data;
        print(response.data);
        await _saveToken(
          data['token'],
          data['refreshToken'],
          data['userId'],
        );
        
        Navigator.pushReplacementNamed(context, '/');
      } else {
        setState(() {
          _errorMessage = 'Błędny e-mail lub hasło';
        });
      }
    } catch (err) {
      setState(() {
        _errorMessage = 'Wystąpił błąd. Spróbuj ponownie.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromRGBO(35, 31, 31, 1),
      body: Center(
        child: Container(
          width: double
              .infinity, // Ustawienie szerokości na 100% dostępnej przestrzeni
          height: 600,
          padding: EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.black54,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Logowanie',
                style: TextStyle(fontSize: 24, color: Colors.white),
              ),
              SizedBox(height: 20),
              TextField(
                controller: _emailController,
                decoration: InputDecoration(
                  labelText: 'Email',
                  labelStyle: TextStyle(color: Colors.white),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.white38),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.white, width: 2),
                  ),
                ),
                style: TextStyle(color: Colors.white),
                keyboardType: TextInputType.emailAddress,
              ),
              SizedBox(height: 15),
              TextField(
                controller: _passwordController,
                decoration: InputDecoration(
                  labelText: 'Hasło',
                  labelStyle: TextStyle(color: Colors.white),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.white38),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.white, width: 2),
                  ),
                ),
                style: TextStyle(color: const Color.fromRGBO(255, 255, 255, 1)),
                obscureText: true,
              ),
              SizedBox(height: 15),
              if (_errorMessage != null)
                Text(
                  _errorMessage!,
                  style: TextStyle(color: const Color.fromRGBO(229, 9, 20, 1)),
                ),
              SizedBox(height: 15),
              ElevatedButton(
                onPressed: _handleLogin,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromRGBO(229, 9, 20, 1),
                  padding: EdgeInsets.symmetric(vertical: 10),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4),
                  ),
                  fixedSize: Size(400, 44),
                ),
                child: Text(
                  'Zaloguj się',
                  style:
                      TextStyle(color: const Color.fromRGBO(255, 255, 255, 1)),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
