import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:projet_lepl1509_groupe_17/models/movies.dart';
import 'package:projet_lepl1509_groupe_17/models/search_movie.dart';
import 'package:projet_lepl1509_groupe_17/pages/movie/bsb_review_form.dart';

User? currentUser = FirebaseAuth.instance.currentUser;

class MoviePage extends StatefulWidget {
  final SearchMovie movie;

  const MoviePage({Key? key, required this.movie}) : super(key: key);

  @override
  State<MoviePage> createState() => _MoviePageState();
}

class _MoviePageState extends State<MoviePage> {
  Movie? movie;
  bool gotMovieDetails = false;

  @override
  void initState() {
    super.initState();
    getMovie();
  }

  Future<void> getMovie() async {
    movie = await Movie.getMovieDetails(widget.movie.id);
    movie!.actors = await Movie.getActors(movie!.id);
    setState(() {
      gotMovieDetails = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(title: Text(!gotMovieDetails && movie == null ? "Details" : movie!.title)),
      body: !gotMovieDetails && movie == null
          ? const Center(child: CircularProgressIndicator())
          : Stack(
              children: [
                ..._buildBackground(context, movie),
                // movie information
                Positioned(
                  top: MediaQuery.of(context).size.height * 0.3,
                  width: MediaQuery.of(context).size.width,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    child: Column(
                      children: [
                        _buildMovieInformation(context),
                        Text(
                          'Actors',
                          style: Theme.of(context).textTheme.labelMedium?.copyWith(fontSize: 18.0),
                        ),
                        SizedBox.fromSize(
                          size: const Size.fromHeight(150),
                          child: ListView.builder(
                            itemCount: movie!.actors.length,
                            scrollDirection: Axis.horizontal,
                            padding: const EdgeInsets.only(top: 12.0, left: 20.0),
                            itemBuilder: _buildActor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // review button
                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Align(
                      alignment: Alignment.bottomCenter,
                      child: FilledButton(
                          style: ButtonStyle(
                            shape: MaterialStateProperty.all(
                              RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          ),
                          child: const Padding(
                            padding: EdgeInsets.symmetric(vertical: 15, horizontal: 5),
                            child: Text("Add a review", style: TextStyle(fontSize: 20)),
                          ),
                          onPressed: () {
                            showModalBottomSheet(
                              context: context,
                              isScrollControlled: true,
                              isDismissible: false,
                              builder: (context) {
                                return GestureDetector(
                                  behavior: HitTestBehavior.opaque,
                                  onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
                                  child: Padding(
                                    padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
                                    child: SizedBox(
                                        width: size.width,
                                        height: size.height < 800 ? size.height * 0.60 : size.height * 0.40,
                                        child: BsbForm(
                                          movie: movie!,
                                        )),
                                  ),
                                );
                              },
                            );
                          })),
                )
              ],
            ),
    );
  }

  List<Widget> _buildBackground(context, Movie? movie) {
    return [
      Container(
        height: double.infinity,
        color: const Color(0xFF000B49),
      ),
      Image.network(
        "https://image.tmdb.org/t/p/w500/${movie!.posterPath}",
        width: double.infinity,
        height: MediaQuery.of(context).size.height * 0.5,
        fit: BoxFit.cover,
      ),
      Positioned.fill(
          child: DecoratedBox(
        decoration: BoxDecoration(
            gradient: LinearGradient(
          colors: [Colors.transparent, Theme.of(context).colorScheme.surface],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          stops: const [0.25, 0.35],
        )),
      )),
    ];
  }

  Widget _buildMovieInformation(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.movie.title,
            style: const TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            "${DateTime.parse(movie!.releaseDate).day}/${DateTime.parse(movie!.releaseDate).month}/${DateTime.parse(movie!.releaseDate).year} - ${Duration(minutes: movie!.runtime).inHours}h ${Duration(minutes: movie!.runtime).inMinutes % 60}m",
            style: const TextStyle(
              fontSize: 18,
            ),
          ),
          const SizedBox(height: 10.0),
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
          const SizedBox(height: 20),
          Text(
            movie!.overview,
            maxLines: 8,
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
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          CircleAvatar(
            backgroundImage: movie!.actors[index].profilePath != null
                ? NetworkImage(
                    "https://image.tmdb.org/t/p/w500/${movie!.actors[index].profilePath}",
                  )
                : null,
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
}
