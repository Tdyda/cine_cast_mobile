import 'package:flutter/material.dart';
import 'package:cine_cast/models/movie.dart';
import 'package:flutter/services.dart';
import 'dart:convert';
import '../screens/video_player_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:video_player/video_player.dart';


class SliderWidget extends StatelessWidget {
  final List<Movie> movies;

  final Map<String, String> previews;

  const SliderWidget({
    Key? key,
    required this.movies,
    required this.previews,
  }) : super(key: key);

  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 300, // Wysokość Slidera
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: movies.length,
        itemBuilder: (context, index) {
          final movie = movies[index];
          final thumbnail = movie.thumbnailUrl;
          final preview = previews[movie.title]; // Podgląd

          return GestureDetector(
            onTap: () async {
              // Pobieramy token
              final token = await _getToken();

              // Jeśli token istnieje, przekazujemy go do ekranu odtwarzacza
              if (token != null) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => VideoPlayerScreen(
                      videoId: movie.id.toString(),
                      title: movie.title,
                      token: token,  // Przekazujemy token do VideoPlayerScreen
                    ),
                  ),
                );
              } else {
                // Jeśli token jest null, możesz dodać odpowiednią logikę (np. pokazać komunikat)
                print('Token nie jest dostępny');
              }
            },
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  thumbnail != null
                      ? Image.memory(
                          base64Decode(movie.thumbnailUrl.split(',')[1]),  // Wyodrębniamy tylko część Base64
                          width: 150,
                          height: 200,
                          fit: BoxFit.cover,                                                  
                        ):
                  const SizedBox(
                    width: 150,
                    height: 200,
                    child: Center(child: CircularProgressIndicator()),
                  ),
                  Text(
                    movie.title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  preview != null
                      ? IconButton(
                          icon: const Icon(Icons.play_arrow),
                          onPressed: () {
                            // Możesz otworzyć odtwarzacz video lub inne działanie
                          },
                        )
                      : const SizedBox.shrink(),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
