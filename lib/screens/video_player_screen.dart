import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

class VideoPlayerScreen extends StatefulWidget {
  final String videoId;
  final String title;
  final String token; // Nowy parametr do przekazania tokena

  const VideoPlayerScreen({
    Key? key,
    required this.videoId,
    required this.title,
    required this.token,  // Dodajemy token do konstruktora
  }) : super(key: key);

  @override
  _VideoPlayerScreenState createState() => _VideoPlayerScreenState();
}

class _VideoPlayerScreenState extends State<VideoPlayerScreen> {
  late final WebViewController _controller;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0x00000000))
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageFinished: (url) async {
            // Wstrzykujemy token w JavaScript do localStorage
            _controller.runJavaScript("""
              if (!localStorage.getItem('tokenSet')) {
                localStorage.setItem('token', '${widget.token}');
                localStorage.setItem('tokenSet', 'true');  // Ustawiamy flagę, że token został ustawiony
                window.location.reload();  // Odświeżenie strony tylko raz
              }
            """);
          },
        ),
      )
      ..loadRequest(Uri.parse("https://doublecodestudio.pl:51821/video/${widget.videoId}?title=${Uri.encodeComponent(widget.title)}"));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      body: WebViewWidget(controller: _controller),
    );
  }
}
