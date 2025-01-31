import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/api_service.dart';

class AuthProvider extends ChangeNotifier {
  String? _token;
  String? _refreshToken;
  DateTime? _expiryDate;
  bool _isAuthenticated = false;

  bool get isAuthenticated => _isAuthenticated;
  String? get token => _token;

  final ApiService _apiService = ApiService();

  /// ✅ Logowanie użytkownika
  Future<bool> login(String email, String password) async {
    try {
      // Wywołanie zapytania login poprzez ApiService
      final response = await _apiService.postRequest(
        "/Account/login", 
        {"email": email, "password": password}
      );

      if (response.statusCode == 200) {
        final data = response.data;

        _token = data["token"];
        _refreshToken = data["refreshToken"];

        // Dekodowanie tokenu JWT, aby wyciągnąć datę wygaśnięcia
        _expiryDate = _getExpiryDateFromToken(_token);

        final prefs = await SharedPreferences.getInstance();
        await prefs.setString("token", _token!);
        await prefs.setString("refresh_token", _refreshToken!);

        // Jeśli _expiryDate jest null, zapiszemy to jako 0
        await prefs.setInt("token_expiry", _expiryDate?.millisecondsSinceEpoch ?? 0);

        _isAuthenticated = true;
        notifyListeners();

        return true; // Logowanie udane
      } else {
        throw Exception("Błędne dane logowania");
      }
    } catch (e) {
      print("Błąd logowania: $e");
      return false; // Logowanie nieudane
    }
  }

  /// Funkcja do wyciągania daty wygaśnięcia z tokenu JWT
  DateTime? _getExpiryDateFromToken(String? token) {
    if (token == null) return null;

    try {
      // Zdekodowanie tokenu JWT
      final jwt = JWT.decode(token);

      // Pobranie wartości "exp" (czas wygaśnięcia)
      final expTimestamp = jwt.payload['exp'];

      if (expTimestamp is int) {
        // Przekształcenie timestampu w DateTime
        return DateTime.fromMillisecondsSinceEpoch(expTimestamp * 1000); // Tokeny JWT używają sekund
      }
    } catch (e) {
      print("Błąd dekodowania tokenu: $e");
    }
    return null;
  }

  /// ✅ Wylogowanie użytkownika
  Future<void> logout() async {
    _token = null;
    _refreshToken = null;
    _expiryDate = null;
    _isAuthenticated = false;

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove("jwt_token");
    await prefs.remove("refresh_token");
    await prefs.remove("token_expiry");

    notifyListeners();
  }

  /// ✅ Sprawdzenie, czy użytkownik jest zalogowany
  Future<void> checkAuthStatus() async {
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString("jwt_token");
    _refreshToken = prefs.getString("refresh_token");
    final expiryTimestamp = prefs.getInt("token_expiry");

    if (_token != null && expiryTimestamp != null) {
      _expiryDate = DateTime.fromMillisecondsSinceEpoch(expiryTimestamp);
      if (_expiryDate!.isBefore(DateTime.now())) {
        await refreshAuthToken(); // 🔹 Jeśli token wygasł → spróbuj odświeżyć
      } else {
        _isAuthenticated = true;
      }
    } else {
      _isAuthenticated = false;
    }

    notifyListeners();
  }

  /// ✅ Odświeżanie tokenu JWT
  Future<void> refreshAuthToken() async {
    if (_refreshToken == null) {
      await logout();
      return;
    }

    try {
      final response = await _apiService.postRequest(
        "/Account/refresh", 
        {"refreshToken": _refreshToken}
      );

      if (response.statusCode == 200) {
        final data = response.data;
        _token = data["token"];
        _expiryDate = _getExpiryDateFromToken(_token);

        final prefs = await SharedPreferences.getInstance();
        await prefs.setString("jwt_token", _token!);
        await prefs.setInt("token_expiry", _expiryDate!.millisecondsSinceEpoch);

        _isAuthenticated = true;
      } else {
        await logout();
      }
    } catch (e) {
      print("Błąd odświeżania tokenu: $e");
      await logout();
    }

    notifyListeners();
  }
}
