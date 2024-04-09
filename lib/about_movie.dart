import 'package:flutter/material.dart';

class AboutMovie extends StatelessWidget {
  final String movieName;
  final String overview;
  final double voteAverage;
  final String posterPath;

  const AboutMovie({Key? key, 
    required this.movieName,
    required this.overview,
    required this.voteAverage,
    required this.posterPath, required releaseDate,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'التفاصيل ',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.black,
        elevation: 0,
      ),
      backgroundColor: Colors.black,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            if (posterPath.isNotEmpty)
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.network(
                  'https://image.tmdb.org/t/p/w500$posterPath',
                  width: MediaQuery.of(context).size.width * 0.7,
                  height: MediaQuery.of(context).size.height * 0.6,
                  fit: BoxFit.cover,
                ),
              ),
            const SizedBox(height: 20),
            Text(
              movieName,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 25,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.star, color: Colors.amber),
                const SizedBox(width: 5),
                Text(
                  voteAverage.toString(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Text(
                overview,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 16, color: Colors.white),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
