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
              console.log('Executing token validation and injection script...');
              
              // Pobierz token z localStorage
              var token = localStorage.getItem('token');
              
              var tokenExpiry = localStorage.getItem('token_expiry');
              var currentTime = new Date().getTime();
              
              console.log('Current time:', currentTime);
              console.log('Token expiry time:', tokenExpiry);
              
              if (!token || !tokenExpiry || currentTime > parseInt(tokenExpiry)) {
                console.log('Token is either invalid or expired. Setting a new token...');
                
                // Ustaw nowy token
                localStorage.setItem('token', '${widget.token}');
                
                // Ustaw czas wygaśnięcia tokenu (np. 24 godziny od teraz)
                var expiryTimestamp = currentTime + 600000;  // 10min w ms
                localStorage.setItem('token_expiry', expiryTimestamp.toString());

                // Logowanie tokena i daty wygaśnięcia
                console.log('New token set:', localStorage.getItem('token'));
                console.log('New token expiry time:', localStorage.getItem('token_expiry'));
                
              } else {
                console.log('Token is valid, no need to set a new one.');
              }
            """);


          },
        ),
      )
      ..addJavaScriptChannel(
        'Console', // Nazwa kanału
        onMessageReceived: (JavaScriptMessage message) {
          // Obsługa komunikatów z JavaScript
          print("Console Message: ${message.message}");
        },
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
