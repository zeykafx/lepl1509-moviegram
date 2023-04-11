import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:optimized_cached_image/optimized_cached_image.dart';
import 'package:projet_lepl1509_groupe_17/components/slidable_movie_list/slidable_movie_list.dart';
import 'package:projet_lepl1509_groupe_17/main.dart';
import 'package:projet_lepl1509_groupe_17/models/search_movie.dart';
import 'package:projet_lepl1509_groupe_17/pages/movie/movie_page.dart';

class ShowMorePage extends StatefulWidget {
  final String category;
  final SlidableMovieListType type;
  final List<SearchMovie> movies;

  const ShowMorePage(
      {super.key,
      required this.category,
      required this.movies,
      required this.type});

  @override
  _ShowMorePageState createState() => _ShowMorePageState();
}

class _ShowMorePageState extends State<ShowMorePage> {
  List<SearchMovie> movies = [];
  int lastPage = 1;
  final ScrollController scrollController = ScrollController();
  bool loading = false;

  @override
  void initState() {
    super.initState();
    movies = widget.movies;
    getMoreMovies();
    scrollController.addListener(() {
      if (scrollController.position.pixels ==
          scrollController.position.maxScrollExtent) {
        getMoreMovies();
      }
    });
  }

  Future<void> getMoreMovies() async {
    if (widget.type == SlidableMovieListType.recommendations) {
      return;
    }
    List<SearchMovie> moreMovies = [];
    String uri =
        "https://api.themoviedb.org/3/movie/${widget.type.toString().split(".").last}?api_key=$themoviedbApi&language=en-US&page=${lastPage + 1}";

    setState(() {
      loading = true;
    });
    var response = await http.get(Uri.parse(uri));
    if (response.statusCode == 200) {
      Map<String, dynamic> jsonResponse = json.decode(response.body);
      var results = jsonResponse['results'];
      for (var result in results) {
        SearchMovie movie = SearchMovie.fromJson(result);
        moreMovies.add(movie);
      }
      if (mounted) {
        setState(() {
          movies.addAll(moreMovies);
          lastPage++;
          loading = false;
        });
      }
    } else {
      print('Request failed with status: ${response.statusCode}.');
      setState(() {
        loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.category),
      ),
      body: Stack(
        children: [
          RefreshIndicator(
            onRefresh: () async {
              setState(() {
                movies = [];
                lastPage = 0;
              });
              await getMoreMovies();
            },
            child: Center(
              child: Container(
                constraints: const BoxConstraints(maxWidth: 700),
                child: GridView(
                  // mainAxisSize: MainAxisSize.max,
                  controller: scrollController,
                  gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                      maxCrossAxisExtent: 160, childAspectRatio: 0.7),
                  children: [
                    ...widget.movies.map(
                      (movie) => Padding(
                        padding: const EdgeInsets.only(bottom: 10.0),
                        child: InkWell(
                          onTap: () {
                            Get.to(() => MoviePage(movie: movie));
                          },
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Expanded(
                                child: Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  clipBehavior: Clip.antiAlias,
                                  child: movie.posterPath != null
                                      ? OptimizedCacheImage(
                                          imageUrl:
                                              "https://image.tmdb.org/t/p/w500${movie.posterPath}",
                                          fit: BoxFit.cover,
                                          height: 300,
                                        )
                                      : const Center(
                                          child: Text(
                                            "No image available",
                                          ),
                                        ),
                                ),
                              ),
                              const SizedBox(
                                height: 5.0,
                              ),
                              SizedBox(
                                width: 100,
                                child: Text(
                                  movie.title,
                                  maxLines: 1,
                                  textAlign: TextAlign.center,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              const SizedBox(
                                height: 5.0,
                              ),
                              if (movie.releaseDate != "")
                                Text(
                                  DateFormat('MMM. dd, yyyy').format(
                                    DateTime.parse(movie.releaseDate),
                                  ),
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Theme.of(context).dividerColor,
                                  ),
                                ),
                            ],
                          ),
                        ).animate().fadeIn(),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          if (loading)
            const Center(
              child: CircularProgressIndicator(),
            ),
        ],
      ),
    );
  }
}
