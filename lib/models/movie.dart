class Movie {
  final int id;
  final String title;
  String thumbnailUrl;
  String previewUrl;

  Movie({
    required this.id,
    required this.title,
    required this.thumbnailUrl,
    required this.previewUrl,
  });

   @override
  String toString() {
    return 'Movie{id: $id, title: $title}';
  }

  factory Movie.fromJson(Map<String, dynamic> json) {
    return Movie(
      id: json['id'],
      title: json['title'] ?? '',
      thumbnailUrl: json['thumbnailUrl'] ?? '',
      previewUrl: json['previewUrl'] ?? '',
    );
  }
}
