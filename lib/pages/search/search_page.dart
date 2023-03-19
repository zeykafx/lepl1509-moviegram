import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:projet_lepl1509_groupe_17/components/slidable_movie_list/slidable_movie_list.dart';
import 'package:projet_lepl1509_groupe_17/main.dart';
import 'package:projet_lepl1509_groupe_17/models/search_movie.dart';

import '../movie/movie_page.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  SearchPageState createState() => SearchPageState();
}

class SearchPageState extends State<SearchPage> {
  @override
  void initState() {
    super.initState();
    // getPopularMovies();
  }

  List<SearchMovie> movies = [];
  List<SearchMovie> displayList = [];

  // List<SearchMovie> popularMovies = [];
  bool initialOpen = true;

  // Future<void> getPopularMovies() async {
  //   var response = await http
  //       .get(Uri.parse("https://api.themoviedb.org/3/movie/popular?api_key=$themoviedbApi&language=en-US&page=1"));
  //   if (response.statusCode == 200) {
  //     setState(() {
  //       popularMovies = [];
  //     });
  //     Map<String, dynamic> jsonResponse = json.decode(response.body);
  //     var results = jsonResponse['results'];
  //     for (var result in results) {
  //       SearchMovie movie = SearchMovie.fromJson(result);
  //       movies.add(movie);
  //     }
  //     setState(() {
  //       popularMovies = List.from(movies);
  //     });
  //   } else {
  //     print('Request failed with status: ${response.statusCode}.');
  //   }
  // }

  Future<void> searchMovie(String query) async {
    var response = await http.get(Uri.parse(
        "https://api.themoviedb.org/3/search/movie?api_key=$themoviedbApi&language=en-US&page=1&include_adult=false&query=$query"));
    if (response.statusCode == 200) {
      setState(() {
        // popularMovies = [];
        movies = [];
      });
      Map<String, dynamic> jsonResponse = json.decode(response.body);
      var results = jsonResponse['results'];
      for (var result in results) {
        SearchMovie movie = SearchMovie.fromJson(result);
        movies.add(movie);
      }
      setState(() {
        if (initialOpen) initialOpen = false;
        displayList = List.from(movies);
        displayList.sort((a, b) => b.popularity.compareTo(a.popularity));
      });
    } else {
      print('Request failed with status: ${response.statusCode}.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Search for a movie'),
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(8, 0, 8, 0),
        child: ListView(
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 20.0),
              child: TextField(
                onChanged: (value) {
                  searchMovie(value);
                },
                decoration: InputDecoration(
                  filled: true,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30.0),
                    borderSide: BorderSide.none,
                  ),
                  hintText: "Search",
                  prefixIcon: const Icon(Icons.search),
                ),
              ),
            ),
            const SizedBox(
              height: 20.0,
            ),
            displayList.isNotEmpty
                ? Text(
                    "Search results (${displayList.length})",
                    style: const TextStyle(fontSize: 20),
                  )
                : Container(),
            const SizedBox(
              height: 10.0,
            ),
            displayList.isEmpty && initialOpen
                ? const SlidableMovieList(
                    size: 200,
                    type: SlidableMovieListType.popular,
                    padding: EdgeInsets.symmetric(horizontal: 8.0),
                  )
                : displayList.isEmpty
                    ? const Center(
                        child: Text("No results found",
                            style: TextStyle(fontSize: 20)),
                      )
                    : Column(
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          ...displayList.map(
                            (movie) => Padding(
                              padding: const EdgeInsets.only(bottom: 10.0),
                              child: Card(
                                child: InkWell(
                                  onTap: () {
                                    Get.to(() => MoviePage(movie: movie));
                                  },
                                  child: Row(
                                    children: [
                                      movie.posterPath != null
                                          ? Container(
                                              decoration: const BoxDecoration(
                                                borderRadius: BorderRadius.only(
                                                    topLeft: Radius.circular(8),
                                                    bottomLeft:
                                                        Radius.circular(8)),
                                              ),
                                              clipBehavior: Clip.antiAlias,
                                              child: Image.network(
                                                movie.posterPath!,
                                                fit: BoxFit.contain,
                                                width: 50,
                                              ),
                                            )
                                          : const Padding(
                                              padding: EdgeInsets.fromLTRB(
                                                  15, 20, 10, 20),
                                              child: Icon(Icons.movie),
                                            ),
                                      const SizedBox(
                                        width: 10.0,
                                      ),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              movie.title,
                                              style: const TextStyle(
                                                  fontWeight: FontWeight.bold),
                                            ),
                                            const SizedBox(
                                              height: 5.0,
                                            ),
                                            Text(
                                              movie.overview,
                                              maxLines: 2,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ).animate().fadeIn(),
                            ),
                          ),
                        ],
                      ),
          ],
        ),
      ),
    );
  }
}
