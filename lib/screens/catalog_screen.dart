import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/api_service.dart';
import '../navigation/navigation.dart'; // Zaimportuj Navigation widget
import '../main.dart'; // Zaimportuj AuthProvider

class CatalogScreen extends StatefulWidget {
  final String? searchQuery;
  final Function(String)? onError;

  const CatalogScreen({
    Key? key,
    this.searchQuery,
    this.onError,
  }) : super(key: key);

  @override
  _CatalogScreenState createState() => _CatalogScreenState();
}

class _CatalogScreenState extends State<CatalogScreen> {
  List<dynamic> movies = [];
  int total = 0;
  int currentPage = 1;
  bool loading = false;
  String? error;
  final int limit = 15;

  @override
  void initState() {
    super.initState();
    fetchMovies();
  }

  Future<void> fetchMovies() async {
    final apiService = Provider.of<ApiService>(context, listen: false);
    setState(() => loading = true);
    try {
      int offset = (currentPage - 1) * limit;
      final response = await apiService.getRequest(
        '/MoviesCatalog/get-videos',
        queryParameters: {
          'limit': limit,
          'offset': offset,
          'query': widget.searchQuery ?? '',
        },
      );

      if (response.statusCode == 200) {
        setState(() {
          movies = response.data['movies']['\$values'] ?? [];
          total = response.data['total'];
        });
      } else {
        setState(() => error = 'Error fetching data');
        widget.onError?.call('Error fetching data');
      }
    } catch (e) {
      if (e.toString().contains('access denied')) {
        setState(() => error = 'Access denied');
        widget.onError?.call('Access denied');
      }
    } finally {
      setState(() => loading = false);
    }
  }

  void nextPage() {
    if (currentPage * limit < total) {
      setState(() {
        currentPage++;
      });
      fetchMovies();
    }
  }

  void previousPage() {
    if (currentPage > 1) {
      setState(() {
        currentPage--;
      });
      fetchMovies();
    }
  }

  @override
  Widget build(BuildContext context) {
    // Zamiast używać widget.isUserLoggedIn, użyj AuthProvider
    final isUserLoggedIn = Provider.of<AuthProvider>(context).isUserLoggedIn;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Strona główna'),
      ),
      drawer: Navigation(
        isUserLoggedIn: isUserLoggedIn, // Zmieniamy na stan z AuthProvider
      ),
      body: Column(
        children: [
          if (loading) CircularProgressIndicator(),
          if (error != null) Text('Error: $error', style: TextStyle(color: Colors.red)),
          Expanded(
            child: ListView.builder(
              itemCount: movies.length,
              itemBuilder: (context, index) {
                final movie = movies[index];
                return ListTile(
                  title: Text(movie['title']),
                  subtitle: Text('ID: ${movie['id']}'),
                  onTap: () {
                    // Tutaj możesz przekierować do ekranu VideoPlayerScreen
                  },
                );
              },
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              TextButton(onPressed: previousPage, child: Text('Previous')),
              Text('Page $currentPage'),
              TextButton(onPressed: nextPage, child: Text('Next')),
            ],
          ),
        ],
      ),
    );
  }
}
