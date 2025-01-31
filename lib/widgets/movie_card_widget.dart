import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:video_player/video_player.dart';
import '../screens/video_player_screen.dart';

class MovieCardWidget extends StatefulWidget {
  final String title;
  final String thumbnailUrl;
  final String previewUrl;
  final String videoId;
  final bool isHovered;
  const MovieCardWidget({
    Key? key,
    required this.title,
    required this.thumbnailUrl,
    required this.previewUrl,
    required this.videoId,
    this.isHovered = false,
  }) : super(key: key);

  @override
  _MovieCardWidgetState createState() => _MovieCardWidgetState();
}

class _MovieCardWidgetState extends State<MovieCardWidget> {
  late VideoPlayerController _videoController;
  bool _isHovered = false;

  @override
  void initState() {
    super.initState();
    _videoController = VideoPlayerController.network(widget.previewUrl)
      ..setLooping(true)
      ..initialize().then((_) {
        if (mounted) setState(() {});
      });
  }

  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  @override
  void dispose() {
    _videoController.dispose();
    super.dispose();
  }

  void _playPreview() {
    if (_videoController.value.isInitialized) {
      _videoController.play();
    }
  }

  void _stopPreview() {
    if (_videoController.value.isInitialized) {
      _videoController.pause();
      _videoController.seekTo(Duration.zero);
    }
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) {
        setState(() {
          _isHovered = true;
          _playPreview();
        });
      },
      onExit: (_) {
        setState(() {
          _isHovered = false;
          _stopPreview();
        });
      },
      child: GestureDetector(
        onTap: () async {
              // Pobieramy token
              final token = await _getToken();

              // Jeśli token istnieje, przekazujemy go do ekranu odtwarzacza
              if (token != null) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => VideoPlayerScreen(
                      videoId: widget.videoId,  // Użyj widget.videoId
                      title: widget.title,       // Użyj widget.title
                      token: token,  // Przekazujemy token do VideoPlayerScreen
                    ),
                  ),
                );
              } else {
                // Jeśli token jest null, możesz dodać odpowiednią logikę (np. pokazać komunikat)
                print('Token nie jest dostępny');
              }
            },
        child: Card(
          elevation: 4,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          child: Column(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.vertical(top: Radius.circular(10)),
                child: AspectRatio(
                  aspectRatio: 16 / 9,
                  child: _isHovered && _videoController.value.isInitialized
                      ? VideoPlayer(_videoController)
                      : Image.memory(
                          base64Decode(widget.thumbnailUrl.split(',')[1]), // Użyj widget.thumbnailUrl
                          fit: BoxFit.cover,
                        ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  widget.title,
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
