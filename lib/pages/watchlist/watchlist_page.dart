import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import 'package:optimized_cached_image/optimized_cached_image.dart';
import 'package:projet_lepl1509_groupe_17/components/drawer/drawer.dart';
import 'package:projet_lepl1509_groupe_17/models/movies.dart';
import 'package:projet_lepl1509_groupe_17/models/user_profile.dart';

import '../../models/search_movie.dart';
import '../movie/bsb_review_form.dart';
import '../movie/movie_page.dart';

class WatchlistPage extends StatefulWidget {
  const WatchlistPage({super.key});

  @override
  State<WatchlistPage> createState() => _WatchlistPageState();
}

class _WatchlistPageState extends State<WatchlistPage> {
  final DrawerPageController drawerPageController = Get.put(DrawerPageController());

  UserProfile? userProfile;
  User? currentUser = FirebaseAuth.instance.currentUser;
  FirebaseFirestore db = FirebaseFirestore.instance;
  List<Movie> watchlistMovies = [];
  List<Movie> watchedMovies = [];
  List<Map<String, double>> ratings = [];
  List<String> reviewsText = [];

  @override
  initState() {
    super.initState();
    readUserData();
  }

  Future<void> readUserData() async {
    await db.collection('users').doc(currentUser?.uid).get().then((value) {
      setState(() {
        userProfile = UserProfile.fromMap(value.data() as Map<String, dynamic>);
      });
    });

    if (userProfile != null) {
      setState(() {
        watchlistMovies = [];
        watchedMovies = [];
        ratings = [];
        reviewsText = [];
      });
      for (var movieID in userProfile!.watchlist) {
        Movie? movie = await Movie.getMovieDetails(movieID);
        if (movie != null) {
          setState(() {
            watchlistMovies.add(movie);
          });
        }
      }

      QuerySnapshot<Map<String, dynamic>> reviews = await db
          .collection("posts")
          .doc(userProfile?.uid)
          .collection("userPosts")
          .orderBy('timestamp', descending: true)
          .get();

      for (var element in reviews.docs) {
        ratings.add({
          "rating": element.data()['rating'].toDouble(),
          "storyRating": element.data()['storyRating'].toDouble(),
          "lengthRating": element.data()['lengthRating'].toDouble(),
          "actingRating": element.data()['actingRating'].toDouble()
        });
        reviewsText.add(element.data()['comment']);
        Movie? movie = await Movie.getMovieDetails(element.data()['movieID']);
        if (movie != null) {
          setState(() {
            watchedMovies.add(movie);
          });
        }
      }
    }
  }

  Future<void> addToWatchList(Movie movie) async {
    await db.collection('users').doc(currentUser!.uid).update({
      'watchlist': FieldValue.arrayUnion([movie.id])
    });
    setState(() {
      userProfile?.watchlist.add(movie.id);
      watchlistMovies.add(movie);
    });

    // show a success snackbar
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Successfully added to watchlist"),
      ),
    );
  }

  Future<void> removeFromWatchList(Movie movie) async {
    print("remove from watchlist");
    await db.collection('users').doc(currentUser!.uid).update({
      'watchlist': FieldValue.arrayRemove([movie.id])
    });
    setState(() {
      userProfile?.watchlist.remove(movie.id);
      watchlistMovies.remove(movie);
    });

    // show a success snackbar
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
          content: const Text("Successfully removed from watchlist"),
          action: SnackBarAction(
            label: "Undo",
            onPressed: () => addToWatchList(movie),
          )),
    );
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    return WillPopScope(
      onWillPop: () async {
        drawerPageController.changeCurrentPage(0);
        return true;
      },
      child: Scaffold(
        drawer: const DrawerComponent(),
        appBar: AppBar(
          title: const Text('Watchlist'),
        ),
        body: userProfile == null
            ? const Center(child: CircularProgressIndicator())
            : Container(
                constraints: const BoxConstraints(maxWidth: 700),
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: RefreshIndicator(
                  onRefresh: () async {
                    setState(() {
                      watchlistMovies = [];
                      watchedMovies = [];
                      ratings = [];
                      reviewsText = [];
                    });
                    await readUserData();
                  },
                  child: ListView(
                    children: [
                      // title
                      Padding(
                        padding: const EdgeInsets.only(left: 10),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Watchlist',
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              'Save movies to watch later',
                              style: TextStyle(
                                fontSize: 14,
                                color: Theme.of(context).dividerColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 10),
                      if (watchlistMovies.isEmpty)
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 10, vertical: 20),
                          child: Center(
                            child: Text(
                              "Add movies to your watchlist to see them here",
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey,
                              ),
                            ),
                          ),
                        ),
                      for (var movie in watchlistMovies) ...[
                        Card(
                          elevation: 0.5,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                            side: BorderSide(
                              color: Colors.grey.withOpacity(0.2),
                              width: 1,
                            ),
                          ),
                          child: Stack(
                            children: [
                              // blurred out movie poster
                              if (movie.backdropPath != null)
                                Positioned.fill(
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(15),
                                    clipBehavior: Clip.antiAlias,
                                    child: Opacity(
                                      opacity: Get.isDarkMode ? 0.1 : 0.05,
                                      child: ImageFiltered(
                                        imageFilter: ImageFilter.blur(
                                          sigmaX: 3,
                                          sigmaY: 3,
                                        ),
                                        child: OptimizedCacheImage(
                                          fit: BoxFit.cover,
                                          imageUrl: "https://image.tmdb.org/t/p/w500/${movie.backdropPath}",
                                          width: size.width,
                                          errorWidget: (context, url, error) => const Icon(Icons.error),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),

                              InkWell(
                                borderRadius: BorderRadius.circular(15),
                                onTap: () {
                                  Get.to(
                                    () => MoviePage(
                                      movie: SearchMovie(
                                        id: movie.id,
                                        title: movie.title,
                                        posterPath: movie.posterPath,
                                        releaseDate: movie.releaseDate,
                                        voteAverage: movie.voteAverage,
                                        overview: movie.overview,
                                        backdropPath: movie.backdropPath,
                                        popularity: movie.popularity,
                                      ),
                                    ),
                                  );
                                },
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 10,
                                    horizontal: 15,
                                  ),
                                  child: Column(
                                    children: [
                                      const SizedBox(height: 5),
                                      Row(
                                        children: [
                                          movie.posterPath != null
                                              ? ClipRRect(
                                                  borderRadius: BorderRadius.circular(8),
                                                  clipBehavior: Clip.antiAlias,
                                                  child: SizedBox(
                                                    width: 80,
                                                    child: OptimizedCacheImage(
                                                      fit: BoxFit.contain,
                                                      imageUrl: "https://image.tmdb.org/t/p/w500/${movie.posterPath}",
                                                      width: 160,
                                                      errorWidget: (context, url, error) => const Icon(Icons.error),
                                                    ),
                                                  ),
                                                )
                                              : const SizedBox(
                                                  width: 80,
                                                  child: Icon(Icons.movie, size: 35),
                                                ),
                                          const SizedBox(width: 10),
                                          Expanded(
                                            child: Column(
                                              mainAxisAlignment: MainAxisAlignment.start,
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                // movie title
                                                Text(movie.title,
                                                    style: const TextStyle(
                                                      fontWeight: FontWeight.w500,
                                                      fontSize: 20,
                                                    )),

                                                const SizedBox(height: 3),
                                                // movie rating
                                                Row(
                                                  mainAxisSize: MainAxisSize.min,
                                                  children: [
                                                    const Icon(Icons.reviews, size: 15),
                                                    const SizedBox(width: 5),
                                                    Text(
                                                      "${movie.voteAverage.toStringAsPrecision(2)}/10",
                                                      style: const TextStyle(fontSize: 15),
                                                    ),
                                                  ],
                                                ),

                                                const SizedBox(height: 3),

                                                // description
                                                Text(
                                                  movie.overview,
                                                  maxLines: 2,
                                                  overflow: TextOverflow.ellipsis,
                                                  style: TextStyle(fontSize: 15, color: Theme.of(context).dividerColor),
                                                ),

                                                const SizedBox(height: 3),

                                                // year, length
                                                Text(
                                                  "${DateTime.parse(movie.releaseDate).year} | ${movie.runtime} min",
                                                  style: const TextStyle(fontSize: 15),
                                                ),
                                              ],
                                            ),
                                          )
                                        ],
                                      ),
                                      const SizedBox(height: 10),
                                      Row(
                                        children: [
                                          Expanded(
                                            child: FilledButton.tonal(
                                              style: FilledButton.styleFrom(
                                                visualDensity: VisualDensity.compact,
                                              ),
                                              onPressed: () {
                                                showModalBottomSheet(
                                                  context: context,
                                                  isScrollControlled: true,
                                                  isDismissible: true,
                                                  builder: (context) {
                                                    return GestureDetector(
                                                      behavior: HitTestBehavior.opaque,
                                                      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
                                                      child: Padding(
                                                        padding: EdgeInsets.only(
                                                            bottom: MediaQuery.of(context).viewInsets.bottom),
                                                        child: SizedBox(
                                                            width: size.width,
                                                            height: size.height < 800
                                                                ? size.height * 0.50
                                                                : size.height * 0.40,
                                                            child: BsbForm(
                                                              movie: movie,
                                                            )),
                                                      ),
                                                    );
                                                  },
                                                );
                                              },
                                              child: const Text('Write a Review'),
                                            ),
                                          ),
                                          const SizedBox(width: 10),
                                          Expanded(
                                            child: FilledButton.tonal(
                                              style: FilledButton.styleFrom(
                                                visualDensity: VisualDensity.compact,
                                              ),
                                              onPressed: () {
                                                // show alert dialog asking to confirm
                                                showDialog(
                                                    context: context,
                                                    builder: (context) {
                                                      return AlertDialog(
                                                        title: const Text('Mark as Watched'),
                                                        content: const Text(
                                                            'Are you sure you want to mark this movie as watched?'),
                                                        actions: [
                                                          TextButton(
                                                            onPressed: () => Get.back(),
                                                            child: const Text('Cancel'),
                                                          ),
                                                          TextButton(
                                                            onPressed: () {
                                                              Get.back();
                                                              // remove from watchlist
                                                              removeFromWatchList(movie);
                                                            },
                                                            child: const Text('Mark as Watched'),
                                                          ),
                                                        ],
                                                      );
                                                    });
                                              },
                                              child: const Text('Marked as Watched'),
                                            ),
                                          ),
                                        ],
                                      )
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ).animate().fade(),
                        const SizedBox(height: 10),
                      ],

                      // Watched movies
                      if (watchedMovies.isNotEmpty) ...[
                        Divider(
                          color: Colors.grey.withOpacity(0.1),
                        ).animate().fade(),
                        const SizedBox(height: 10),
                        Padding(
                          padding: const EdgeInsets.only(left: 10),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Reviewed Movies',
                                style: TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                'Movies you reviewed',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Theme.of(context).dividerColor,
                                ),
                              ),
                            ],
                          ),
                        ),

                        // TODO: yeah there is a lot of duplicate code here, but I'm too lazy to fix it
                        const SizedBox(height: 10),
                        for (Movie movie in watchedMovies) ...[
                          Card(
                            elevation: 0.5,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                              side: BorderSide(
                                color: Colors.grey.withOpacity(0.2),
                                width: 1,
                              ),
                            ),
                            child: Stack(
                              children: [
                                // blurred out movie poster
                                if (movie.backdropPath != null)
                                  Positioned.fill(
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(15),
                                      clipBehavior: Clip.antiAlias,
                                      child: Opacity(
                                        opacity: Get.isDarkMode ? 0.1 : 0.05,
                                        child: ImageFiltered(
                                          imageFilter: ImageFilter.blur(
                                            sigmaX: 3,
                                            sigmaY: 3,
                                          ),
                                          child: OptimizedCacheImage(
                                            fit: BoxFit.cover,
                                            imageUrl: "https://image.tmdb.org/t/p/w500/${movie.backdropPath}",
                                            width: size.width,
                                            errorWidget: (context, url, error) => const Icon(Icons.error),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),

                                InkWell(
                                  borderRadius: BorderRadius.circular(15),
                                  onTap: () {
                                    Get.to(
                                      () => MoviePage(
                                        movie: SearchMovie(
                                          id: movie.id,
                                          title: movie.title,
                                          posterPath: movie.posterPath,
                                          releaseDate: movie.releaseDate,
                                          voteAverage: movie.voteAverage,
                                          overview: movie.overview,
                                          backdropPath: movie.backdropPath,
                                          popularity: movie.popularity,
                                        ),
                                      ),
                                    );
                                  },
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 10,
                                      horizontal: 15,
                                    ),
                                    child: Column(
                                      children: [
                                        const SizedBox(height: 5),
                                        Row(
                                          children: [
                                            movie.posterPath != null
                                                ? ClipRRect(
                                                    borderRadius: BorderRadius.circular(8),
                                                    clipBehavior: Clip.antiAlias,
                                                    child: SizedBox(
                                                      width: 80,
                                                      child: OptimizedCacheImage(
                                                        fit: BoxFit.contain,
                                                        imageUrl: "https://image.tmdb.org/t/p/w500/${movie.posterPath}",
                                                        width: 160,
                                                        errorWidget: (context, url, error) => const Icon(Icons.error),
                                                      ),
                                                    ),
                                                  )
                                                : const SizedBox(
                                                    width: 80,
                                                    child: Icon(Icons.movie, size: 35),
                                                  ),
                                            const SizedBox(width: 10),
                                            Expanded(
                                              child: Column(
                                                mainAxisAlignment: MainAxisAlignment.start,
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  // movie title
                                                  Text(movie.title,
                                                      style: const TextStyle(
                                                        fontWeight: FontWeight.w500,
                                                        fontSize: 20,
                                                      )),

                                                  const SizedBox(height: 3),
                                                  // movie rating
                                                  Row(
                                                    mainAxisSize: MainAxisSize.min,
                                                    children: [
                                                      const Icon(Icons.reviews, size: 15),
                                                      const SizedBox(width: 5),
                                                      Text(
                                                        "${movie.voteAverage.toStringAsPrecision(2)}/10",
                                                        style: const TextStyle(fontSize: 15),
                                                      ),
                                                    ],
                                                  ),

                                                  const SizedBox(height: 3),

                                                  // description
                                                  Text(
                                                    movie.overview,
                                                    maxLines: 2,
                                                    overflow: TextOverflow.ellipsis,
                                                    style:
                                                        TextStyle(fontSize: 15, color: Theme.of(context).dividerColor),
                                                  ),

                                                  const SizedBox(height: 3),

                                                  // year, length
                                                  Text(
                                                    "${DateTime.parse(movie.releaseDate).year} | ${movie.runtime} min",
                                                    style: const TextStyle(fontSize: 15),
                                                  ),
                                                ],
                                              ),
                                            )
                                          ],
                                        ),
                                        const SizedBox(height: 10),

                                        // review
                                        Text(
                                          '"${reviewsText[watchedMovies.indexOf(movie)]}"',
                                          maxLines: 3,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                              fontSize: 15,
                                              color: Theme.of(context).dividerColor,
                                              fontStyle: FontStyle.italic),
                                        ),
                                        const SizedBox(height: 10),

                                        // ratings given in review
                                        Center(child: buildRatings(watchedMovies.indexOf(movie))),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ).animate().fade(),
                          const SizedBox(height: 10),
                        ]
                      ],
                    ],
                  ),
                ),
              ),
      ),
    );
  }

  Widget buildRatings(int idx) {
    return Column(
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox.fromSize(
          size: const Size.fromHeight(45),
          child: Center(
            child: ListView(
              physics: const BouncingScrollPhysics(decelerationRate: ScrollDecelerationRate.fast),
              scrollDirection: Axis.horizontal,
              shrinkWrap: true,
              children: [
                buildRatingPill(ratings[idx]["rating"].toString(), "Rating", Icons.movie_creation_outlined),
                const SizedBox(width: 6),
                buildRatingPill(ratings[idx]["actingRating"].toString(), "Actors", Icons.person),
                const SizedBox(width: 6),
                buildRatingPill(ratings[idx]["storyRating"].toString(), "Story", Icons.menu_book_outlined),
                const SizedBox(width: 6),
                buildRatingPill(ratings[idx]["lengthRating"].toString(), "Length", Icons.timelapse_outlined),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget buildRatingPill(String rating, String title, IconData icon) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary.withOpacity(0.10),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.max,
          children: [
            Icon(icon, color: Theme.of(context).dividerColor, size: 18),
            const SizedBox(width: 5),
            Column(
              key: ValueKey("column $title"),
              children: [
                Flexible(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                Row(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Icon(Icons.star, color: Colors.amber, size: 13),
                    const SizedBox(width: 2),
                    Text(
                      rating,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
