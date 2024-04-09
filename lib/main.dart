import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'about_movie.dart';
import 'movie_search.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MEDO TV',
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: Colors.black,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.black,
          elevation: 0,
        ),
      ),
      home: HomeScreen(),
    );
  }
}

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('MEDO TV'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              showSearch(context: context, delegate: MovieSearch());
            },
          ),
        ],
      ),
      body: ConnectionCheck(),
    );
  }
}

class ConnectionCheck extends StatefulWidget {
  @override
  _ConnectionCheckState createState() => _ConnectionCheckState();
}

class _ConnectionCheckState extends State<ConnectionCheck> {
  late List<dynamic> _movies = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadMovies();
  }

  Future<void> _loadMovies() async {
    const String apiKey = '7e9e257a750efd22f499952f4744d6f7';
    String apiUrl =
        'https://api.themoviedb.org/3/discover/movie?api_key=$apiKey&primary_release_date.lte=${DateTime.now().toString().split(' ')[0]}';

    setState(() {
      _isLoading = true;
    });

    try {
      final response = await http.get(Uri.parse(apiUrl));
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        final List<dynamic> movies = data['results'];
        setState(() {
          _movies = movies;
          _isLoading = false;
        });
      } else {
        _showErrorSnackBar('Failed to load movies');
      }
    } catch (e) {
      _showErrorSnackBar('Failed to connect to server');
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  void _showMovieDetails(int index) async {
    final movie = _movies[index];
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AboutMovie(
          movieName: movie['title'],
          overview: movie['overview'],
          voteAverage: movie['vote_average'].toDouble(),
          releaseDate: movie['release_date'], // Added release date
          posterPath: movie['poster_path'],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return _isLoading
        ? Center(child: CircularProgressIndicator())
        : ListView.builder(
            itemCount: _movies.length,
            itemBuilder: (context, index) {
              final movie = _movies[index];
              return GestureDetector(
                onTap: () => _showMovieDetails(index),
                child: Card(
                  color: Colors.grey[900],
                  margin: const EdgeInsets.all(6),
                  child: Padding(
                    padding: const EdgeInsets.all(6),
                    child: Row(
                      children: [
                        if (movie['poster_path'] != null)
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.network(
                              'https://image.tmdb.org/t/p/w500${movie['poster_path']}',
                              width: 100,
                              height: 150,
                              fit: BoxFit.cover,
                            ),
                          ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                movie['title'],
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(height: 7),
                              Row(
                                children: [
                                  const Icon(
                                    Icons.star,
                                    color: Colors.amber,
                                  ),
                                  const SizedBox(width: 5),
                                  Text(
                                    movie['vote_average'].toString(),
                                    style: const TextStyle(
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 5),
                              Text(
                                _getGenres(movie['genre_ids']),
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey,
                                ),
                              ),
                              const SizedBox(height: 5),
                              Text(
                                'Release Date: ${movie['release_date']}',
                                style: const TextStyle(
                                  fontSize: 10,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
  }

  String _getGenres(List<dynamic> genreIds) {
    List<String> genres = [];
    for (int genreId in genreIds) {
      switch (genreId) {
        case 28:
          genres.add('Action');
          break;
        case 12:
          genres.add('Adventure');
          break;
        case 16:
          genres.add('Animation');
          break;
        case 35:
          genres.add('Comedy');
          break;
        case 80:
          genres.add('Crime');
          break;
        case 18:
          genres.add('Drama');
          break;
        case 27:
          genres.add('Horror');
          break;
      }
    }
    return genres.join(', ');
  }
}
