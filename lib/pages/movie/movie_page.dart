import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:get/get.dart';
import 'package:optimized_cached_image/optimized_cached_image.dart';
import 'package:projet_lepl1509_groupe_17/components/slidable_movie_list/slidable_movie_list.dart';
import 'package:projet_lepl1509_groupe_17/models/movies.dart';
import 'package:projet_lepl1509_groupe_17/models/providers.dart';
import 'package:projet_lepl1509_groupe_17/models/search_movie.dart';
import 'package:projet_lepl1509_groupe_17/pages/movie/bsb_review_form.dart';
import 'package:projet_lepl1509_groupe_17/pages/watchlist/watchlist_page.dart';
import 'package:url_launcher/url_launcher.dart';

class MoviePage extends StatefulWidget {
  final SearchMovie? movie;

  const MoviePage({Key? key, required this.movie}) : super(key: key);

  @override
  State<MoviePage> createState() => _MoviePageState();
}

class _MoviePageState extends State<MoviePage> {
  Movie? movie;
  List<ProviderCountry> providers = [];
  bool gotMovieDetails = false;
  User? currentUser = FirebaseAuth.instance.currentUser;
  var db = FirebaseFirestore.instance;
  bool isInWatchList = false;
  bool isWatched = false;

  @override
  void initState() {
    super.initState();
    getMovie();
    getProvider();
  }

  Future<void> getMovie() async {
    movie = await Movie.getMovieDetails(widget.movie!.id);
    movie!.actors = await Movie.getActors(movie!.id);
    movie!.trailerURL = await Movie.getTrailerURL(movie!.id);
    setState(() {
      gotMovieDetails = true;
    });

    if (currentUser != null) {
      DocumentSnapshot userDoc = await db.collection('users').doc(currentUser!.uid).get();
      if (userDoc.exists && userDoc['watchlist'] != null) {
        List<dynamic> watchlist = userDoc['watchlist'];
        if (watchlist.contains(movie!.id)) {
          setState(() {
            isInWatchList = true;
          });
        }
      }
    }
  }

  Future<void> getProvider() async {
    Provider? allProviders = await Provider.getProvider(widget.movie!.id);
    if (allProviders == null ||
        allProviders.countryProviders.isEmpty ||
        allProviders.countryProviders.entries.isEmpty) {
      return;
    }
    Map<String, dynamic> providersCountry;
    List<dynamic> providersBE;
    try {
      // hack: use orElse instead
      providersCountry = allProviders.countryProviders.entries.singleWhere((element) => element.key == 'BE').value;

      if (providersCountry.isEmpty) {
        return;
      }
      providersBE = providersCountry.entries.singleWhere((element) => element.key == 'flatrate').value;
      for (var result in providersBE) {
        ProviderCountry providerCountry = ProviderCountry.getProviderCountry(result);
        providers.add(providerCountry);
      }
    } catch (e) {
      return;
    }
  }

  Future<void> addToWatchList() async {
    await db.collection('users').doc(currentUser!.uid).update({
      'watchlist': FieldValue.arrayUnion([movie!.id])
    });
    setState(() {
      isInWatchList = true;
    });

    // show a success snackbar
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
          content: const Text("Successfully added to watchlist"),
          action: SnackBarAction(
            label: "View",
            onPressed: () {
              Get.to(() => const WatchlistPage(), transition: Transition.fadeIn);
            },
          )),
    );
  }

  Future<void> removeFromWatchList() async {
    await db.collection('users').doc(currentUser!.uid).update({
      'watchlist': FieldValue.arrayRemove([movie!.id])
    });
    setState(() {
      isInWatchList = false;
    });

    // show a success snackbar
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Successfully removed from watchlist"),
      ),
    );
  }

  // add to watched movies
  Future<void> addToWatched(Movie movie) async {
    await db.collection('users').doc(currentUser!.uid).update({
      'watched': FieldValue.arrayUnion([movie.id])
    });
    setState(() {
      isWatched = true;
    });

    // show a success snackbar
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text("Successfully added to watched"),
        action: SnackBarAction(
          label: "View",
          onPressed: () {
            Get.to(() => const WatchlistPage(), transition: Transition.fadeIn);
          },
        ),
      ),
    );
  }

  // remove from watched movies
  Future<void> removeFromWatched(Movie movie) async {
    await db.collection('users').doc(currentUser!.uid).update({
      'watched': FieldValue.arrayRemove([movie.id])
    });
    setState(() {
      isWatched = false;
    });

    // show a success snackbar
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
          content: const Text("Successfully removed from watched"),
          action: SnackBarAction(
            label: "Undo",
            onPressed: () => addToWatched(movie),
          )),
    );
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        // title: Text(!gotMovieDetails && movie == null ? "Details" : movie!.title),
        scrolledUnderElevation: 0,
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Container(
          margin: const EdgeInsets.only(left: 10),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Theme.of(context).colorScheme.surface,
          ),
          child: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Get.back(),
          ),
        ),
      ),
      body: !gotMovieDetails && movie == null
          ? const Center(child: CircularProgressIndicator())
          : Stack(
              children: [
                ShaderMask(
                  blendMode: BlendMode.dstIn,
                  shaderCallback: (rect) {
                    return const LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Colors.black, Colors.black, Colors.transparent],
                      stops: [0.1, 0.5, 1],
                    ).createShader(
                      Rect.fromLTRB(0, 0, rect.width, rect.height),
                    );
                  },
                  child: SizedBox(
                    height: size.height * 0.7,
                    width: double.infinity,
                    child: movie!.posterPath != null
                        ? Opacity(
                            opacity: 0.5,
                            child: OptimizedCacheImage(
                              fit: BoxFit.cover,
                              imageUrl: "https://image.tmdb.org/t/p/w500/${movie!.posterPath}",
                              errorWidget: (context, url, error) => const Icon(Icons.error),
                            ),
                          )
                        : const Center(
                            child: Text(
                              "No image available",
                            ),
                          ),
                  ),
                ),
                BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                  // top padding to avoid the appbar
                  child: Align(
                    alignment: Alignment.bottomCenter,
                    child: buildMovieDetails(context, size),
                  ),
                )
              ],
            ),
    );
  }

  Widget buildMovieDetails(context, Size size) {
    return movie == null
        ? const Center(child: CircularProgressIndicator())
        : SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Sized box to shift down the content to be able to see the poster behind
                SizedBox.fromSize(size: Size.fromHeight(size.height * 0.3)),

                // MOVIE INFO
                _buildMovieInformation(context, size),

                // ACTORS
                const SizedBox(height: 15),
                movie!.actors.isNotEmpty
                    ? Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal: 12,
                            ),
                            child: Text(
                              'Actors',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          SizedBox.fromSize(
                            size: const Size.fromHeight(140),
                            child: ListView.builder(
                              itemCount: movie!.actors.length,
                              scrollDirection: Axis.horizontal,
                              padding: const EdgeInsets.only(top: 12.0, left: 12),
                              itemBuilder: _buildActor,
                            ),
                          ),
                        ],
                      )
                    : Container(),

                if (providers.isNotEmpty) ...[
                  // Watch now
                  const SizedBox(height: 15),
                  _buildProviders(),
                ],

                SlidableMovieList(
                  size: 150,
                  type: SlidableMovieListType.recommendations,
                  id: movie!.id,
                  padding: const EdgeInsets.symmetric(horizontal: 12.0),
                ),
                const SizedBox(height: 40),
              ],
            ),
          );
  }

  Widget _buildMovieInformation(BuildContext context, Size size) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                ),
                clipBehavior: Clip.antiAlias,
                child: SizedBox(
                  height: 100,
                  child: movie!.posterPath != null
                      ? OptimizedCacheImage(
                          fit: BoxFit.fitHeight,
                          imageUrl: "https://image.tmdb.org/t/p/w500/${movie!.posterPath}",
                          errorWidget: (context, url, error) => const Icon(Icons.error),
                        )
                      : const Center(
                          child: Text(
                            "No image",
                          ),
                        ),
                ),
              ),
              const SizedBox(
                width: 15,
              ),
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      movie!.title,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 5),
                    if (movie!.releaseDate != "")
                      Text(
                        "${DateTime.parse(movie!.releaseDate).day}/${DateTime.parse(movie!.releaseDate).month}/${DateTime.parse(movie!.releaseDate).year} - ${Duration(minutes: movie!.runtime).inHours}h ${Duration(minutes: movie!.runtime).inMinutes % 60}m",
                        style: const TextStyle(
                          fontSize: 18,
                        ),
                      ),
                    const SizedBox(height: 5.0),
                    RatingBar.builder(
                      initialRating: movie!.voteAverage / 2,
                      minRating: 1,
                      maxRating: 5,
                      direction: Axis.horizontal,
                      allowHalfRating: true,
                      ignoreGestures: true,
                      itemCount: 5,
                      itemSize: 20,
                      itemPadding: const EdgeInsets.symmetric(
                        horizontal: 4.0,
                      ),
                      itemBuilder: (context, index) {
                        return const Icon(
                          Icons.star,
                          color: Colors.amber,
                        );
                      },
                      onRatingUpdate: (rating) {},
                    ),
                  ],
                ),
              ),
              if (movie!.trailerURL != null) ...[
                InkWell(
                  onTap: () async {
                    final url = Uri.parse(movie!.trailerURL!);
                    if (await canLaunchUrl(url)) {
                      await launchUrl(url, mode: LaunchMode.externalApplication);
                    }
                  },
                  child: Container(
                    height: 50,
                    width: 50,
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.onSecondary,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.play_arrow_rounded,
                    ),
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.max,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // review button
              Expanded(
                child: FilledButton.tonal(
                    style: ButtonStyle(
                      shape: MaterialStateProperty.all(
                        RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                    child: const Padding(
                      padding: EdgeInsets.symmetric(vertical: 15, horizontal: 5),
                      child: Text("Add a review", style: TextStyle(fontSize: 13)),
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
                              padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
                              child: SizedBox(
                                  width: size.width,
                                  height: size.height < 800 ? size.height * 0.50 : size.height * 0.40,
                                  child: BsbForm(
                                    movie: movie!,
                                  )),
                            ),
                          );
                        },
                      );
                    }),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: FilledButton.tonalIcon(
                  style: ButtonStyle(
                    shape: MaterialStateProperty.all(
                      RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    backgroundColor: MaterialStateProperty.all(
                      isInWatchList ? Theme.of(context).colorScheme.onPrimary : null,
                    ),
                  ),
                  icon: Icon(isInWatchList ? Icons.bookmark_added_rounded : Icons.bookmark_add_rounded),
                  label: Padding(
                    padding: EdgeInsets.symmetric(vertical: isInWatchList ? 15 : 17, horizontal: 5),
                    child: Text(isInWatchList ? "In Watchlist" : "Add to watchlist",
                        style: TextStyle(fontSize: isInWatchList ? 13 : 10)),
                  ),
                  onPressed: () {
                    isInWatchList ? removeFromWatchList() : addToWatchList();
                  },
                ),
              ),

              // add to watched button in a 3 dots menu
              const SizedBox(width: 2),
              PopupMenuButton(
                icon: const Icon(Icons.more_vert_rounded),
                itemBuilder: (context) => [
                  PopupMenuItem(
                    value: 1,
                    child: Text(
                      isWatched ? "Marked as Watched" : "Add to watched",
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ),
                  // if (providers.isNotEmpty)
                  //   PopupMenuItem(
                  //     value: 2,
                  //     child: Text(
                  //       "Show Streaming Providers",
                  //       style: Theme.of(context).textTheme.bodySmall,
                  //     ),
                  //   ),
                ],
                onSelected: (value) {
                  if (value == 1) {
                    isWatched ? removeFromWatched(movie!) : addToWatched(movie!);
                  }
                  // else if (value == 2) {
                  //   showModalBottomSheet(
                  //     context: context,
                  //     isScrollControlled: true,
                  //     isDismissible: true,
                  //     builder: (context) {
                  //       return GestureDetector(
                  //         behavior: HitTestBehavior.opaque,
                  //         onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
                  //         child: Padding(
                  //           padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
                  //           child: SizedBox(
                  //             width: size.width,
                  //             height: size.height * 0.20,
                  //             child: Center(
                  //               child: Column(
                  //                 mainAxisAlignment: MainAxisAlignment.center,
                  //                 crossAxisAlignment: CrossAxisAlignment.center,
                  //                 children: [
                  //                   _buildProviders(),
                  //                 ],
                  //               ),
                  //             ),
                  //           ),
                  //         ),
                  //       );
                  //     },
                  //   );
                  // }
                },
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            movie!.overview,
            // maxLines: 8,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(height: 1.5),
          ),
        ],
      ),
    );
  }

  Widget _buildActor(BuildContext context, int index) {
    return Padding(
      padding: const EdgeInsets.only(right: 16.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircleAvatar(
            backgroundImage: movie!.actors[index].profilePath != null
                ? Image(
                    image: OptimizedCacheImageProvider(
                      "https://image.tmdb.org/t/p/w500/${movie!.actors[index].profilePath}",
                    ),
                  ).image
                : const Image(
                    image: OptimizedCacheImageProvider(
                      "http://www.gravatar.com/avatar/?d=mp",
                    ),
                  ).image,
            radius: 35,
          ),
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Text(
              movie!.actors[index].name,
            ),
          ),
          Flexible(
            child: SizedBox(
              width: 90,
              child: Text(
                movie!.actors[index].character,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Theme.of(context).dividerColor),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProviders() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Watch now",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
          ),
          const SizedBox(height: 0),
          SizedBox.fromSize(
            size: const Size.fromHeight(90),
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: providers.map((provider) {
                return Padding(
                  padding: const EdgeInsets.fromLTRB(9, 0, 9, 0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ClipOval(
                        child: provider.logoPath != ""
                            ? Image.network(
                                "https://image.tmdb.org/t/p/w500/${provider.logoPath}",
                                width: 70,
                                fit: BoxFit.contain,
                              )
                            : const SizedBox(
                                width: 70,
                                height: 70,
                              ),
                      ),
                      SizedBox(
                        child: Text(
                          provider.name,
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.bodySmall,
                          overflow: TextOverflow.clip,
                        ),
                      )
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}
