import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:get_storage/get_storage.dart';
import 'package:interactive_bottom_sheet/interactive_bottom_sheet.dart';
import 'package:projet_lepl1509_groupe_17/components/slidable_movie_list/slidable_movie_list.dart';
import 'package:projet_lepl1509_groupe_17/models/movies.dart';
import 'package:projet_lepl1509_groupe_17/models/providers.dart';
import 'package:projet_lepl1509_groupe_17/models/search_movie.dart';
import 'package:projet_lepl1509_groupe_17/pages/movie/bsb_review_form.dart';

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

  @override
  void initState() {
    super.initState();
    getMovie();
    getProvider();
  }

  Future<void> getMovie() async {
    movie = await Movie.getMovieDetails(widget.movie!.id);
    movie!.actors = await Movie.getActors(movie!.id);
    setState(() {
      gotMovieDetails = true;
    });
  }

  Future<void> getProvider() async {
    Provider? allProviders = await Provider.getProvider(widget.movie!.id);
    Map<String, dynamic> providersCountry = allProviders!
        .countryProviders.entries
        .singleWhere((element) => element.key == 'BE')
        .value;
    List<dynamic> providersBE = providersCountry.entries
        .singleWhere((element) => element.key == 'flatrate')
        .value;
    for (var result in providersBE) {
      ProviderCountry providerCountry =
          ProviderCountry.getProviderCountry(result);
      providers.add(providerCountry);
    }
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        // title: Text(!gotMovieDetails && movie == null ? "Details" : movie!.title),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      bottomSheet: InteractiveBottomSheet(
        options: InteractiveBottomSheetOptions(
          maxSize: 0.85,
          initialSize: 0.65,
          snapList: [0.30, 0.65],
          backgroundColor: Theme.of(context).colorScheme.surface,
        ),
        draggableAreaOptions: DraggableAreaOptions(
          topBorderRadius: 10,
          height: 30,
          indicatorColor: Colors.grey,
          indicatorWidth: 20,
          backgroundColor: Theme.of(context).colorScheme.surface,
          shadows: [],
        ),
        child: buildMovieModalSheet(context, size),
      ),
      body: !gotMovieDetails && movie == null
          ? const Center(child: CircularProgressIndicator())
          : Image.network(
              "https://image.tmdb.org/t/p/w500/${movie!.posterPath}",
              width: double.infinity,
              fit: BoxFit.fitHeight,
            ),
    );
  }

  Widget buildMovieModalSheet(context, Size size) {
    return movie == null
        ? const Center(child: CircularProgressIndicator())
        : SingleChildScrollView(
            child: Column(
              children: [
                _buildMovieInformation(context, size),
                movie!.actors.isNotEmpty
                    ? Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            child: Text(
                              'Actors',
                              style: Theme.of(context)
                                  .textTheme
                                  .labelMedium
                                  ?.copyWith(fontSize: 18.0),
                            ),
                          ),
                          SizedBox.fromSize(
                            size: const Size.fromHeight(140),
                            child: ListView.builder(
                              itemCount: movie!.actors.length,
                              scrollDirection: Axis.horizontal,
                              padding:
                                  const EdgeInsets.only(top: 12.0, left: 20.0),
                              itemBuilder: _buildActor,
                            ),
                          ),
                        ],
                      )
                    : Container(),
                SlidableMovieList(
                  size: 150,
                  type: SlidableMovieListType.recommendations,
                  id: movie!.id,
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                ),
                const SizedBox(height: 20),
              ],
            ),
          );
  }

  Widget _buildMovieInformation(BuildContext context, Size size) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                ),
                clipBehavior: Clip.antiAlias,
                child: Image.network(
                    "https://image.tmdb.org/t/p/w500/${movie!.posterPath}",
                    height: 100,
                    fit: BoxFit.contain),
              ),
              const SizedBox(
                width: 20,
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
                        fontSize: 30,
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
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          const Text(
            "Watch now",
            style: TextStyle(
              color: Colors.amber,
              fontSize: 24,
            ),
          ),
          const SizedBox(height: 10),
          Row(children: _buildProviders()),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              // review button
              FilledButton.tonal(
                  style: ButtonStyle(
                    shape: MaterialStateProperty.all(
                      RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  child: const Padding(
                    padding: EdgeInsets.symmetric(vertical: 15, horizontal: 5),
                    child: Text("Add a review", style: TextStyle(fontSize: 15)),
                  ),
                  onPressed: () {
                    showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      isDismissible: false,
                      builder: (context) {
                        return GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onTap: () =>
                              FocusManager.instance.primaryFocus?.unfocus(),
                          child: Padding(
                            padding: EdgeInsets.only(
                                bottom:
                                    MediaQuery.of(context).viewInsets.bottom),
                            child: SizedBox(
                                width: size.width,
                                height: size.height < 800
                                    ? size.height * 0.50
                                    : size.height * 0.40,
                                child: BsbForm(
                                  movie: movie!,
                                )),
                          ),
                        );
                      },
                    );
                  }),
              const SizedBox(width: 20),
              FilledButton.tonal(
                style: ButtonStyle(
                  shape: MaterialStateProperty.all(
                    RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                child: const Padding(
                  padding: EdgeInsets.symmetric(vertical: 15, horizontal: 5),
                  child:
                      Text("Add to watchlist", style: TextStyle(fontSize: 15)),
                ),
                onPressed: () {
                  // show success snackbar
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                    behavior: SnackBarBehavior.floating,
                    margin: EdgeInsets.all(10),
                    content: Text("Added to watch list successfully!"),
                  ));
                },
              ),
            ],
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
        mainAxisAlignment: MainAxisAlignment.center,
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
                style: Theme.of(context)
                    .textTheme
                    .bodySmall
                    ?.copyWith(color: Theme.of(context).dividerColor),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildProviders() {
    return providers.map((provider) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.network(
              "https://image.tmdb.org/t/p/w500/${provider.logoPath}",
              width: 70,
              fit: BoxFit.contain,
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
    }).toList();
  }
}
