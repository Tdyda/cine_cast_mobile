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
            print('TOKEN ${widget.token}');
            _controller.runJavaScript("""
              console.log('Executing token injection script...');
              var tokenSet = localStorage.getItem('tokenSet');
              
              // Resetowanie tokenSet po określonym czasie (np. 24 godziny)
              var lastSetTime = localStorage.getItem('tokenSetTime');
              var currentTime = new Date().getTime();
              
              if (lastSetTime && currentTime - lastSetTime > 86400000) {  // 600000 ms = 10min
                localStorage.setItem('tokenSet', 'false');
                console.log('TokenSet expired, resetting.');
              }

              // Ustawiamy nowy token tylko, jeśli tokenSet jest false
              if (!localStorage.getItem('tokenSet')) {
                localStorage.setItem('token', '${widget.token}');
                localStorage.setItem('tokenSet', 'true');
                localStorage.setItem('tokenSetTime', currentTime.toString());  // Ustawiamy czas ustawienia tokena
                console.log('Token set:', localStorage.getItem('token'));
                window.location.reload();
              } else {
                console.log('Token already set, skipping injection.');
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
