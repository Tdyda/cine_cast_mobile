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