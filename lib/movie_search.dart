import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'about_movie.dart';

class MovieSearch extends SearchDelegate<String> {
  List<String> searchHistory = [];

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () {
          query = '';
        },
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () {
        close(context, '');
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    _addToSearchHistory(query);
    return _buildSearchResults(context, query);
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return ListView.builder(
      itemCount: searchHistory.length,
      itemBuilder: (context, index) {
        return ListTile(
          title: Text(searchHistory[index]),
          onTap: () {
            query = searchHistory[index];
            showResults(context);
          },
        );
      },
    );
  }

  Widget _buildSearchResults(BuildContext context, String query) {
    return FutureBuilder(
      future: _searchMovies(query),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: CircularProgressIndicator(),
          );
        } else if (snapshot.hasError) {
          return Center(
            child: Text('Error: ${snapshot.error}'),
          );
        } else {
          List<dynamic> movies = snapshot.data as List<dynamic>;
          return ListView.builder(
            itemCount: movies.length,
            itemBuilder: (context, index) {
              final movie = movies[index];
              return GestureDetector(
                onTap: () {
                  _showMovieDetails(context, movie);
                },
                child: _buildMovieCard(movie),
              );
            },
          );
        }
      },
    );
  }

  Widget _buildMovieCard(dynamic movie) {
    return Card(
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
    );
  }

  Future<List<dynamic>> _searchMovies(String query) async {
    final String apiKey = '7e9e257a750efd22f499952f4744d6f7';
    final String baseUrl = 'https://api.themoviedb.org/3/search/movie';
    final String url =
        '$baseUrl?api_key=$apiKey&query=$query&include_adult=false';

    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      final jsonData = json.decode(response.body);
      final List<dynamic> results = jsonData['results'];
      return results;
    } else {
      throw Exception('Failed to load movies');
    }
  }

  void _showMovieDetails(BuildContext context, dynamic movie) {
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

  void _addToSearchHistory(String query) {
    if (!searchHistory.contains(query)) {
      searchHistory.insert(0, query);
    }
    if (searchHistory.length > 5) {
      searchHistory.removeLast();
    }
  }
}
