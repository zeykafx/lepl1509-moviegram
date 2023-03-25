import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:projet_lepl1509_groupe_17/models/search_movie.dart';
import 'package:projet_lepl1509_groupe_17/pages/movie/movie_page.dart';

import '../../main.dart';

enum SlidableMovieListType {
  popular,
  now_playing,
  top_rated,
  recommendations,
  upcoming
}

class SlidableMovieList extends StatefulWidget {
  final double size;
  final SlidableMovieListType type;
  final int id;
  final EdgeInsets padding;

  const SlidableMovieList(
      {super.key,
      required this.size,
      required this.type,
      this.id = 0,
      this.padding = EdgeInsets.zero});

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
      if (mounted) {
        setState(() {
          popularMovies = [];
        });
      }
      Map<String, dynamic> jsonResponse = json.decode(response.body);
      var results = jsonResponse['results'];
      for (var result in results) {
        SearchMovie movie = SearchMovie.fromJson(result);
        movies.add(movie);
      }
      if (mounted) {
        setState(() {
          popularMovies = List.from(movies);
        });
      }
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
                          : widget.type == SlidableMovieListType.top_rated
                              ? "Top Rated"
                              : widget.type == SlidableMovieListType.upcoming
                                  ? "Upcoming"
                                  : "Movies you might like", // default
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
                    child: InkWell(
                      onTap: () {
                        Get.back();
                        Get.to(() => MoviePage(movie: movie));
                      },
                      child: movie.posterPath != null
                          ? Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Expanded(
                                  child: Container(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    clipBehavior: Clip.antiAlias,
                                    child: Image(
                                      image: ResizeImage(
                                          NetworkImage(
                                            "https://image.tmdb.org/t/p/w500${movie.posterPath}",
                                          ),
                                          height: widget.size.toInt() * 2,
                                          allowUpscaling: true),
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),

                                // show title and formatted release date only if the widget is big enough
                                if (widget.size > 200) ...[
                                  const SizedBox(
                                    height: 5.0,
                                  ),
                                  Container(
                                    width: 100,
                                    child: Text(
                                      movie.title,
                                      maxLines: 1,
                                      textAlign: TextAlign.center,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                  const SizedBox(
                                    height: 5.0,
                                  ),
                                  Text(
                                    DateFormat('MMM. dd, yyyy').format(
                                        DateTime.parse(movie.releaseDate)),
                                    style: TextStyle(
                                        fontSize: 11,
                                        color: Theme.of(context).dividerColor),
                                  ),
                                ],
                              ],
                            )
                          : Container(
                              height: widget.size,
                              color: Colors.grey,
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
