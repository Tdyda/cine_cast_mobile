import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  late Dio dio;

  // Singleton - jedna instancja Dio dla całej aplikacji
  static final ApiService _instance = ApiService._internal();

  factory ApiService() {
    return _instance;
  }

  ApiService._internal() {
    dio = Dio(
      BaseOptions(
        baseUrl: "https://doublecodestudio.pl:51821/videoService/api",
        connectTimeout: Duration(seconds: 5),
        receiveTimeout: Duration(seconds: 5),
        headers: {
          "Content-Type": "application/json",
        },
      ),
    );

    // Dodanie interceptorów (np. logowanie, tokeny)
    dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        // Pobierz token za każdym razem przed wysłaniem zapytania
        String? token = await _getToken();
        
        if (token != null) {
          options.headers["Authorization"] = 'Bearer $token';
        }
        print("Wysyłanie żądania: ${options.method} ${options.path}");
        return handler.next(options);
      },
      onResponse: (response, handler) {
        print("Odpowiedź: ${response.statusCode}");
        return handler.next(response);
      },
      onError: (DioException e, handler) {
        print("Błąd: ${e.message}");
        return handler.next(e);
      },
    ));
  }

  // Funkcja do pobrania tokena z SharedPreferences
  static Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  // GET
  Future<Response> getRequest(String endpoint, {Options? options, Map<String, dynamic>? queryParameters}) async {
    final fullUrl = dio.options.baseUrl + endpoint;
    print('Get Request URL: $fullUrl');
    print('Query Parameters: $queryParameters');

    return await dio.get(
      endpoint,
      options: options ?? Options(responseType: ResponseType.json),
      queryParameters: queryParameters,
    );
  }


  // POST
  Future<Response> postRequest(String endpoint, Map<String, dynamic> data) async {
    final fullUrl = dio.options.baseUrl + endpoint;
    print('Post Request URL: $fullUrl');
    return await dio.post(endpoint, data: data);
  }
}



// import 'dart:convert';
// import 'package:http/http.dart' as http;
// import 'package:cine_cast/models/movie.dart';
// import 'package:shared_preferences/shared_preferences.dart';

// class ApiService {
//   static const String baseUrl =
//       'https://doublecodestudio.pl:51821/videoService/api';

  // Funkcja do odczytu tokenu z shared_preferences
  // static Future<String?> _getToken() async {
  //   final prefs = await SharedPreferences.getInstance();
  //   return prefs.getString('token');
  // }

//   static Future<List<Movie>> fetchMoviesByCategory(
//       String category, int limit) async {
//     final url = Uri.parse('$baseUrl/MoviesCatalog/tags');

//     // Odczyt tokenu przed wykonaniem zapytania
//     final token = await _getToken();

//     // Przygotowanie nagłówków z tokenem
//     final headers = {
//       'Content-Type': 'application/json',
//       'Authorization': token != null ? 'Bearer $token' : '',
//     };

//     final Uri requestUrl = Uri.parse('$baseUrl/MoviesCatalog/tags').replace(
//       queryParameters: {
//         'limit': '$limit',
//         'offset': '0',
//         'tags[]': category, // Wysłanie tagu jako tablicy
//       },
//     );

//     final response = await http.get(requestUrl, headers: headers);

//     if (response.statusCode == 200) {
//       final data = jsonDecode(response.body);
//       if (data['\$values'] != null) {
//         return List<Movie>.from(
//           data['\$values'].map((movie) => Movie.fromJson(movie)),
//         );
//       }
//     }
//     throw Exception('Failed to load movies for category $category');
//   }

//   static Future<String> fetchThumbnail(String movieTitle) async {
//     final url = '$baseUrl/MoviesCatalog/thumbnail/$movieTitle/thumbnail.jpg';
//     final token = await _getToken();
//     final headers = {
//       'Content-Type': 'application/json',
//       'Authorization': token != null ? 'Bearer $token' : '',
//     };

//     final Uri requestUrl = Uri.parse('$url');
//     final response = await http.get(requestUrl, headers: headers);

//     if (response.statusCode == 200) {
//       print('response: ${response.body}');
//       return url; // Zwracamy URL miniaturki
//     } else {
//       throw Exception('Failed to load thumbnail');
//     }
//   }

//   static Future<String> fetchPreview(String movieTitle) async {
//     final url = '$baseUrl/MoviesCatalog/preview/$movieTitle/thumbnail.mp4';

//     final token = await _getToken();
//     final headers = {
//       'Content-Type': 'application/json',
//       'Authorization': token != null ? 'Bearer $token' : '',
//     };

//     final Uri requestUrl = Uri.parse('$url');
//     final response = await http.get(requestUrl, headers: headers);

//     if (response.statusCode == 200) {
//       return url;
//     } else {
//       throw Exception('Failed to load preview');
//     }
//   }
// }
