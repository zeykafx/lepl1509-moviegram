import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:projet_lepl1509_groupe_17/components/drawer/drawer.dart';
import 'package:projet_lepl1509_groupe_17/components/slidable_movie_list/slidable_movie_list.dart';
import 'package:projet_lepl1509_groupe_17/models/movies.dart';
import 'package:projet_lepl1509_groupe_17/models/review.dart';
import 'package:projet_lepl1509_groupe_17/models/search_movie.dart';
import 'package:projet_lepl1509_groupe_17/pages/movie/movie_page.dart';
import 'package:projet_lepl1509_groupe_17/pages/search/search_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const DrawerComponent(),
      appBar: AppBar(
        title: const Text('MovieGram'),
        actions: [
          IconButton(
            onPressed: () {
              Get.to(() => const SearchPage());
            },
            icon: const Icon(Icons.search),
          ),
        ],
      ),
      body: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 700),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.max,
              children: [
                const SlidableMovieList(
                  size: 250,
                  type: SlidableMovieListType.now_playing,
                  padding: EdgeInsets.symmetric(horizontal: 8.0),
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                  child: Text("Most recent reviews", style: TextStyle(fontSize: 20)),
                ),
                StreamBuilder(
                    stream: FirebaseFirestore.instance.collection('reviews').snapshots(),
                    builder: (context, AsyncSnapshot snapshot) {
                      if (snapshot.hasData) {
                        return ListView.builder(
                            shrinkWrap: true,
                            itemCount: snapshot.data.docs.length,
                            itemBuilder: (context, index) {
                              // get the review from the snapshot
                              Review review = Review.fromJson(snapshot.data.docs[index].data());

                              // return a tile for each review
                              return FutureBuilder(
                                  future: Movie.getMovieDetails(review.movieID),
                                  builder: (context, snapshot) {
                                    return snapshot.hasData
                                        ? ListTile(
                                            onTap: () {
                                              Get.to(() => MoviePage(
                                                  movie: SearchMovie(
                                                      id: review.movieID,
                                                      title: snapshot.data!.title,
                                                      posterPath: snapshot.data!.posterPath,
                                                      releaseDate: snapshot.data!.releaseDate,
                                                      voteAverage: snapshot.data!.voteAverage,
                                                      overview: snapshot.data!.overview,
                                                      backdropPath: snapshot.data!.backdropPath)));
                                            },
                                            leading: snapshot.data!.posterPath != null
                                                ? Image.network(
                                                    "https://image.tmdb.org/t/p/w500${snapshot.data!.posterPath}",
                                                    fit: BoxFit.contain,
                                                  )
                                                : const Icon(Icons.movie, size: 35),
                                            title: RichText(
                                              text: TextSpan(
                                                text: snapshot.data!.title,
                                                style: TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    color: Theme.of(context).textTheme.bodyLarge?.color),
                                                children: <TextSpan>[
                                                  TextSpan(
                                                    text: ' - ${review.username}',
                                                    style: TextStyle(
                                                      fontWeight: FontWeight.normal,
                                                      color: Theme.of(context).textTheme.bodyLarge?.color,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            isThreeLine: true,
                                            subtitle: Row(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              mainAxisSize: MainAxisSize.max,
                                              children: [
                                                Expanded(
                                                    child: Text(
                                                  review.comment ?? "No comment...",
                                                  softWrap: true,
                                                )),
                                                const Icon(
                                                  Icons.star,
                                                  color: Colors.orangeAccent,
                                                  size: 15,
                                                ),
                                                Text(review.rating.toString() ?? "No rating"),
                                              ],
                                            ),
                                          )
                                        : const Text("Loading...");
                                  });
                            });
                      } else {
                        return const Center(child: CircularProgressIndicator());
                      }
                    }),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
