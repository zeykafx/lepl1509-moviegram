import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:projet_lepl1509_groupe_17/models/search_movie.dart';
import 'package:projet_lepl1509_groupe_17/pages/movie/movie_page.dart';

import '../../main.dart';

enum SlidableMovieListType { popular, now_playing, top_rated, recommendations }

class SlidableMovieList extends StatefulWidget {
  final double size;
  final SlidableMovieListType type;
  final int id;
  final EdgeInsets padding;

  const SlidableMovieList(
      {super.key, required this.size, required this.type, this.id = 0, this.padding = EdgeInsets.zero});

  @override
  _SlidableMovieListState createState() => _SlidableMovieListState();
}

class _SlidableMovieListState extends State<SlidableMovieList> {
  List<SearchMovie> popularMovies = [];

  initState() {
    super.initState();
    getPopularMovies();
  }

  Future<void> getPopularMovies() async {
    List<SearchMovie> movies = [];
    String uri;
    if (widget.type != SlidableMovieListType.recommendations) {
      uri =
          "https://api.themoviedb.org/3/movie/${widget.type.toString().split(".").last}?api_key=$themoviedbApi&language=en-US&page=1";
    } else {
      uri =
          "https://api.themoviedb.org/3/movie/${widget.id}/recommendations?api_key=$themoviedbApi&language=en-US&page=1";
    }
    var response = await http.get(Uri.parse(uri));
    if (response.statusCode == 200) {
      setState(() {
        popularMovies = [];
      });
      Map<String, dynamic> jsonResponse = json.decode(response.body);
      var results = jsonResponse['results'];
      for (var result in results) {
        SearchMovie movie = SearchMovie.fromJson(result);
        movies.add(movie);
      }
      setState(() {
        popularMovies = List.from(movies);
      });
    } else {
      print('Request failed with status: ${response.statusCode}.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox.fromSize(
      size: Size.fromHeight(widget.size),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: widget.padding,
            child: Text(
              widget.type == SlidableMovieListType.popular
                  ? "Popular now"
                  : widget.type == SlidableMovieListType.now_playing
                      ? "Now playing"
                      : widget.type == SlidableMovieListType.recommendations
                          ? "Recommended"
                          : "Top rated",
              style: const TextStyle(fontSize: 20),
            ),
          ),
          const SizedBox(
            height: 10.0,
          ),
          Expanded(
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                ...popularMovies.map((movie) {
                  return Padding(
                    padding: const EdgeInsets.only(left: 8.0),
                    child: Card(
                      elevation: 2.0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: InkWell(
                        onTap: () {
                          Get.back();
                          Get.to(() => MoviePage(movie: movie));
                        },
                        child: Stack(
                          children: [
                            // background image
                            movie.posterPath != null
                                ? Image.network(
                                    "https://image.tmdb.org/t/p/w500${movie.posterPath}",
                                    fit: BoxFit.cover,
                                    height: widget.size,
                                  )
                                : Container(
                                    height: widget.size,
                                    color: Colors.grey,
                                  ),
                          ],
                        ),
                      ),
                    ).animate().fadeIn(),
                  );
                })
              ],
            ),
          ),
        ],
      ),
    );
  }
}
