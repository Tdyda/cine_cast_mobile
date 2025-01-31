import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class MovieCardWidget extends StatefulWidget {
  final String title;
  final String thumbnailUrl;
  final String previewUrl;
  final String videoId;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const MovieCardWidget({
    Key? key,
    required this.title,
    required this.thumbnailUrl,
    required this.previewUrl,
    required this.videoId,
    this.onEdit,
    this.onDelete,
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
        onTap: () {
          Navigator.pushNamed(context, '/video', arguments: {'id': widget.videoId, 'title': widget.title});
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
                          base64Decode(movie.thumbnailUrl.split(',')[1]),
                          fit: BoxFit.cover,                                                  
                        ):
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
