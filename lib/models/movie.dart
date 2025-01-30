class Movie {
  final String title;
  final String thumbnailUrl;
  final String previewUrl;

  Movie({
    required this.title,
    required this.thumbnailUrl,
    required this.previewUrl,
  });

  factory Movie.fromJson(Map<String, dynamic> json) {
    return Movie(
      title: json['title'] ?? '',
      thumbnailUrl: json['thumbnailUrl'] ?? '',
      previewUrl: json['previewUrl'] ?? '',
    );
  }
}
