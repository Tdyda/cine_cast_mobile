import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/api_service.dart';
import '../navigation/navigation.dart'; // Zaimportuj Navigation widget
import '../main.dart'; // Zaimportuj AuthProvider
import '../widgets/pagination_widget.dart';
import '../widgets/movie_card_widget.dart'; // Zaimportuj MovieCardWidget
import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/services.dart'; // Do Image.memory
import 'package:dio/dio.dart';


class CatalogScreen extends StatefulWidget {
  final String? searchQuery;
  final Function(String)? onError;

  const CatalogScreen({
    Key? key,
    this.searchQuery,
    this.onError,
  }) : super(key: key);

  @override
  _CatalogScreenState createState() => _CatalogScreenState();
}

class _CatalogScreenState extends State<CatalogScreen> {
  List<dynamic> movies = [];
  int total = 0;
  int currentPage = 1;
  bool loading = false;
  String? error;
  final int limit = 15;
  Map<String, bool> hoveredMovies = {}; // Zmienna przechowująca informacje o najechanych filmach
  Map<String, bool> loadedPreviews = {}; // Zmienna do przechowywania załadowanych podglądów

  @override
  void initState() {
    super.initState();
    fetchMovies();
  }  

  Future<void> fetchMovies() async {
    final apiService = Provider.of<ApiService>(context, listen: false);
    setState(() => loading = true);
    try {
      int offset = (currentPage - 1) * limit;
      final response = await apiService.getRequest(
        '/MoviesCatalog/get-videos',
        queryParameters: {
          'limit': limit,
          'offset': offset,
          'query': widget.searchQuery ?? '',
        },
      );

      if (response.statusCode == 200) {
        setState(() {
          movies = response.data['movies']['\$values'] ?? [];
          total = response.data['total'];
        });
      } else {
        setState(() => error = 'Error fetching data');
        widget.onError?.call('Error fetching data');
      }
    } catch (e) {
      if (e.toString().contains('access denied')) {
        setState(() => error = 'Access denied');
        widget.onError?.call('Access denied');
      }
    } finally {
      setState(() => loading = false);
    }

    for (var movie in movies) {
      final options = Options(responseType: ResponseType.bytes);

      // Jeśli miniaturka jest w formacie Base64
      final response = await apiService.getRequest(
        '/MoviesCatalog/thumbnail/${movie['title']}/thumbnail.jpg',
        options: options,
      );

      if (response.statusCode == 200) {
        final Uint8List thumbnail = response.data;
        setState(() {
          // Zapisujemy miniaturkę jako Base64 string
          movie['thumbnailUrl'] = "data:image/jpeg;base64," + base64Encode(thumbnail);
        });
      }
    }
  }

  void handleMouseEnter(String movieId, String movieTitle) {
    setState(() {
      hoveredMovies[movieId] = true;
    });

    if (!(loadedPreviews[movieId] ?? false)){
      // Załaduj podgląd, jeśli nie został jeszcze załadowany
      fetchPreview(movieTitle, movieId);
    }
  }

  Future<void> fetchPreview(String movieTitle, String movieId) async {
    // Fetch the media preview logic here (example: calling API to get preview)
    final apiService = Provider.of<ApiService>(context, listen: false);
    try {
      final previewResponse = await apiService.getRequest(
        '/MoviesCatalog/preview/$movieTitle',
      );

      if (previewResponse.statusCode == 200) {
        // Logika przechowywania załadowanego podglądu
        setState(() {
          loadedPreviews[movieId] = true;
        });
      }
    } catch (e) {
      print("Error fetching preview for $movieId: $e");
    }
  }

  void nextPage() {
    if (currentPage * limit < total) {
      setState(() {
        currentPage++;
      });
      fetchMovies();
    }
  }

  void previousPage() {
    if (currentPage > 1) {
      setState(() {
        currentPage--;
      });
      fetchMovies();
    }
  }

  @override
  Widget build(BuildContext context) {
    // Zamiast używać widget.isUserLoggedIn, użyj AuthProvider
    final isUserLoggedIn = Provider.of<AuthProvider>(context).isUserLoggedIn;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Strona główna'),
      ),
      drawer: Navigation(
        isUserLoggedIn: isUserLoggedIn,
      ),
      body: Column(
        children: [
          if (loading) const CircularProgressIndicator(),
          if (error != null)
            Text('Error: $error', style: const TextStyle(color: Colors.red)),
          Expanded(
            child: GridView.builder(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2, // Dwa elementy w jednym wierszu
                crossAxisSpacing: 10.0,
                mainAxisSpacing: 10.0,
                childAspectRatio: 1.0,
              ),
              itemCount: movies.length,
              itemBuilder: (context, index) {
                final movie = movies[index];
                final thumbnailUrl = movie['thumbnailUrl']; // Pobieramy URL miniaturki (w Base64)
                final movieId = movie['id'].toString();

                return MouseRegion(
                  onEnter: (_) => handleMouseEnter(movieId, movie['title']),
                  onExit: (_) => setState(() {
                    hoveredMovies[movieId] = false;
                  }),
                  child: MovieCardWidget(
                    title: movie['title'],
                    thumbnailUrl: thumbnailUrl ?? '', // Jeśli miniatura jest dostępna w Base64
                    previewUrl: movie['previewUrl'] ?? '', // Użyj URL do podglądu
                    videoId: movie['id'].toString(),
                    isHovered: hoveredMovies[movieId] ?? false, // Przekazujemy stan hover
                  ),
                );
              },
            ),
          ),
          Pagination(
            currentPage: currentPage,
            totalPages: (total / limit).ceil(),
            setCurrentPage: (page) {
              setState(() {
                currentPage = page;
              });
              fetchMovies(); // Odświeżanie danych po zmianie strony
            },
          ),
        ],
      ),
    );
  }
}
