import 'package:flutter/material.dart';
import 'package:cine_cast/services/api_service.dart';
import 'package:cine_cast/widgets/slider_widget.dart';
import 'package:cine_cast/models/movie.dart';
import 'package:cine_cast/navigation/navigation.dart'; // Dodajemy import Navigation
import '../services/api_service.dart';
import 'package:provider/provider.dart';
import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/services.dart'; // Do Image.memory
import 'package:dio/dio.dart';


class HomeScreen extends StatefulWidget {
  final bool isUserLoggedIn;

  const HomeScreen(
      {Key? key, this.isUserLoggedIn = false})
      : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Map<String, List<Movie>> moviesByCategory = {};
  Map<String, String> thumbnails = {};
  Map<String, String> previews = {};
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
    final apiService = Provider.of<ApiService>(context, listen: false);
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      Map<String, List<Movie>> categoryMovies = {};
      for (String category in categories) {
        final apiService = Provider.of<ApiService>(context, listen: false);
        final url = '/MoviesCatalog/tags?tags[]=$category';
        final response = await apiService.getRequest(url);

        if(response.statusCode == 200)
        {
          print('Odpowiedź OK: ${response.data}');

          final movies = (response.data['\$values'] as List)
            .map((movieJson) => Movie.fromJson(movieJson))
            .toList();


            print('Movies: $movies');

            if (movies.isNotEmpty) {
              categoryMovies[category] = movies;
            }
        }        
      }

      setState(() {
        moviesByCategory = categoryMovies;
      });

      for (var category in moviesByCategory.keys) {
        for (var movie in moviesByCategory[category]!) {
          final options = Options(responseType: ResponseType.bytes);

          final response = await apiService.getRequest(
            '/MoviesCatalog/thumbnail/${movie.title}/thumbnail.jpg',
            options: options,
          );

          if(response.statusCode == 200)
          {
            final Uint8List thumbnail = response.data;
            setState(() {
              movie.thumbnailUrl = "data:image/jpeg;base64," + base64Encode(thumbnail);
            });
            moviesByCategory.forEach((key, value) {});
          }
        }
      }
    } catch (e) {
      setState(() {
        errorMessage = '$e';
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
        // isUserLoggedIn: widget.isUserLoggedIn,
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
