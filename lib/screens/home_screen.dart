import 'package:flutter/material.dart';
import 'package:cine_cast/services/api_service.dart';
import 'package:cine_cast/widgets/slider_widget.dart';
import 'package:cine_cast/models/movie.dart';
import 'package:cine_cast/navigation/navigation.dart'; // Dodajemy import Navigation

class HomeScreen extends StatefulWidget {
  final bool isAdmin;
  final bool isUserLoggedIn;

  const HomeScreen(
      {Key? key, this.isAdmin = false, this.isUserLoggedIn = false})
      : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Map<String, List<Movie>> moviesByCategory = {};
  Map<String, String> thumbnails = {}; // Miniaturki filmów
  Map<String, String> previews = {}; // Podglądy filmów
  bool isLoading = false;
  String? errorMessage;

  final List<String> categories = ['Thriller', 'Horror'];
  final int limit = 15;

  @override
  void initState() {
    super.initState();
    fetchMovies();
  }

  Future<void> fetchMovies() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      Map<String, List<Movie>> categoryMovies = {};
      for (String category in categories) {
        final movies = await ApiService.fetchMoviesByCategory(category, limit);
        if (movies.isNotEmpty) {
          categoryMovies[category] = movies;
        }
      }

      setState(() {
        moviesByCategory = categoryMovies;
      });

      // Pobieranie miniaturek i podglądów
      for (var category in moviesByCategory.keys) {
        for (var movie in moviesByCategory[category]!) {
          // Pobieramy miniaturkę
          final thumbnail = await ApiService.fetchThumbnail(movie.title);
          setState(() {
            thumbnails[movie.title] = thumbnail;
          });

          // Pobieramy podgląd
          // final preview = await ApiService.fetchPreview(movie.title);
          setState(() {
            // previews[movie.title] = preview;
          });
          moviesByCategory.forEach((key, value) {});
        }
      }
    } catch (e) {
      setState(() {
        errorMessage = 'Failed to load movies';
      });
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Strona główna'),
      ),
      drawer: Navigation(
        isUserLoggedIn: widget.isUserLoggedIn,
        isAdmin: widget.isAdmin,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : errorMessage != null
              ? Center(child: Text(errorMessage!))
              : moviesByCategory.isNotEmpty
                  ? ListView(
                      children: moviesByCategory.keys.map((category) {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                category,
                                style: const TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            SliderWidget(
                              movies: moviesByCategory[category]!,
                              isAdmin: widget.isAdmin,
                              // thumbnails: thumbnails,
                              previews: previews,
                            ),
                          ],
                        );
                      }).toList(),
                    )
                  : const Center(child: Text('Brak dostępnych filmów')),
    );
  }
}
