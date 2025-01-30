import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:cine_cast/models/movie.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  static const String baseUrl =
      'https://doublecodestudio.pl:51821/videoService/api';

  // Funkcja do odczytu tokenu z shared_preferences
  static Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  static Future<List<Movie>> fetchMoviesByCategory(
      String category, int limit) async {
    final url = Uri.parse('$baseUrl/MoviesCatalog/tags');

    // Odczyt tokenu przed wykonaniem zapytania
    final token = await _getToken();

    // Przygotowanie nagłówków z tokenem
    final headers = {
      'Content-Type': 'application/json',
      'Authorization': token != null ? 'Bearer $token' : '',
    };

    final Uri requestUrl = Uri.parse('$baseUrl/MoviesCatalog/tags').replace(
      queryParameters: {
        'limit': '$limit',
        'offset': '0',
        'tags[]': category, // Wysłanie tagu jako tablicy
      },
    );

    final response = await http.get(requestUrl, headers: headers);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['\$values'] != null) {
        return List<Movie>.from(
          data['\$values'].map((movie) => Movie.fromJson(movie)),
        );
      }
    }
    throw Exception('Failed to load movies for category $category');
  }

  static Future<String> fetchThumbnail(String movieTitle) async {
    final url = '$baseUrl/MoviesCatalog/thumbnail/$movieTitle/thumbnail.jpg';
    final token = await _getToken();
    final headers = {
      'Content-Type': 'application/json',
      'Authorization': token != null ? 'Bearer $token' : '',
    };

    final Uri requestUrl = Uri.parse('$url');
    final response = await http.get(requestUrl, headers: headers);

    if (response.statusCode == 200) {
      print('response: ${response.body}');
      return url; // Zwracamy URL miniaturki
    } else {
      throw Exception('Failed to load thumbnail');
    }
  }

  static Future<String> fetchPreview(String movieTitle) async {
    final url = '$baseUrl/MoviesCatalog/preview/$movieTitle/thumbnail.mp4';

    final token = await _getToken();
    final headers = {
      'Content-Type': 'application/json',
      'Authorization': token != null ? 'Bearer $token' : '',
    };

    final Uri requestUrl = Uri.parse('$url');
    final response = await http.get(requestUrl, headers: headers);

    if (response.statusCode == 200) {
      return url;
    } else {
      throw Exception('Failed to load preview');
    }
  }
}
