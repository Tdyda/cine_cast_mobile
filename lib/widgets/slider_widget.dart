import 'package:flutter/material.dart';
import 'package:cine_cast/models/movie.dart';

class SliderWidget extends StatelessWidget {
  final List<Movie> movies;
  final bool isAdmin;
  // final Map<String, String> thumbnails;
  final Map<String, String> previews; // Parametr dla podglądów

  // Dodajemy parametry 'thumbnails' i 'previews' do konstruktor widgetu
  const SliderWidget({
    Key? key,
    required this.movies,
    required this.isAdmin,
    // required this.thumbnails,
    required this.previews,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 300, // Wysokość Slidera
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: movies.length,
        itemBuilder: (context, index) {
          final movie = movies[index];
          // final thumbnail = thumbnails[movie.title];
          final preview = previews[movie.title]; // Podgląd

          return GestureDetector(
            onTap: () {
              // Tutaj możesz dodać logikę kliknięcia w film
            },
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // thumbnail != null
                  //     ? Image.network(
                  //         thumbnail, // Wyświetlanie miniaturki
                  //         width: 150,
                  //         height: 200,
                  //         fit: BoxFit.cover,
                  //       )
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
