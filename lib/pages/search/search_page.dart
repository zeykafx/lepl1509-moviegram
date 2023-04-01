import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:optimized_cached_image/optimized_cached_image.dart';
import 'package:projet_lepl1509_groupe_17/models/search_movie.dart';
import 'package:projet_lepl1509_groupe_17/pages/movie/movie_page.dart';

import '../../main.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  SearchPageState createState() => SearchPageState();
}

class SearchPageState extends State<SearchPage> {
  String textFieldContent = "";
  List<SearchMovie> movies = [];
  List<SearchMovie> displayList = [];

  bool initialOpen = true;

  Future<void> searchMovie(String query) async {
    var response = await http.get(Uri.parse(
        "https://api.themoviedb.org/3/search/movie?api_key=$themoviedbApi&language=en-US&page=1&include_adult=false&query=$query"));
    if (response.statusCode == 200) {
      setState(() {
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
        title: Text(textFieldContent == ""
            ? "Search for a movie"
            : "Results for $textFieldContent"),
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(8, 0, 8, 0),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 20.0),
              child: TextField(
                onChanged: (value) {
                  setState(() {
                    textFieldContent = value;
                  });
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
                // ? const SlidableMovieList(
                //     size: 200,
                //     type: SlidableMovieListType.popular,
                //     padding: EdgeInsets.symmetric(horizontal: 8.0),
                //   )
                ? const Center(
                    child: Text("Search for a movie",
                        style: TextStyle(fontSize: 20)),
                  )
                : displayList.isEmpty
                    ? const Center(
                        child: Text("No results found",
                            style: TextStyle(fontSize: 20)),
                      )
                    : Expanded(
                        child: GridView(
                          // mainAxisSize: MainAxisSize.max,
                          gridDelegate:
                              const SliverGridDelegateWithMaxCrossAxisExtent(
                                  maxCrossAxisExtent: 150,
                                  childAspectRatio: 0.7),
                          children: [
                            ...displayList.map(
                              (movie) => Padding(
                                padding: const EdgeInsets.only(bottom: 10.0),
                                child: SizedBox.fromSize(
                                  size: const Size.fromHeight(200),
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
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                            ),
                                            clipBehavior: Clip.antiAlias,
                                            child: movie.posterPath != null
                                                // ? Image(
                                                //     image: ResizeImage(
                                                //       NetworkImage(
                                                //         "https://image.tmdb.org/t/p/w500${movie.posterPath}",
                                                //       ),
                                                //       height: (200 * 1.5).toInt(),
                                                //     ),
                                                //     fit: BoxFit.cover,
                                                //   )
                                                ? OptimizedCacheImage(
                                                    imageUrl:
                                                        "https://image.tmdb.org/t/p/w500${movie.posterPath}",
                                                    fit: BoxFit.cover,
                                                    height: 200,
                                                  )
                                                : const Center(
                                                    child: Text(
                                                      "No image available",
                                                    ),
                                                  ),
                                          ),
                                        ),

                                        // show title and formatted release date only if the widget is big enough

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
                                              color: Theme.of(context)
                                                  .dividerColor,
                                            ),
                                          ),
                                      ],
                                    ),
                                  ).animate().fadeIn(),
                                ),
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
}
