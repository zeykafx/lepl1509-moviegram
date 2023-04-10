import 'package:flutter/material.dart';
import 'package:projet_lepl1509_groupe_17/components/slidable_movie_list/slidable_movie_list.dart';

class ExploreFeed extends StatefulWidget {
  const ExploreFeed({super.key});

  @override
  _ExploreFeedState createState() => _ExploreFeedState();
}

class _ExploreFeedState extends State<ExploreFeed> {
  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        // title
        Padding(
          padding: const EdgeInsets.only(left: 15, top: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Explore Movies',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                'Discover new and popular movies',
                style: TextStyle(
                  fontSize: 14,
                  color: Theme.of(context).dividerColor,
                ),
              )
            ],
          ),
        ),
        const SlidableMovieList(
          size: 250,
          type: SlidableMovieListType.popular,
          padding: EdgeInsets.only(left: 20, right: 20, top: 20),
        ),
        const SlidableMovieList(
          size: 250,
          type: SlidableMovieListType.top_rated,
          padding: EdgeInsets.only(left: 20, right: 20, top: 20),
        ),
        const SlidableMovieList(
          size: 250,
          type: SlidableMovieListType.now_playing,
          padding: EdgeInsets.only(left: 20, right: 20, top: 20),
        ),
        const SlidableMovieList(
          size: 250,
          type: SlidableMovieListType.upcoming,
          padding: EdgeInsets.only(left: 20, right: 20, top: 20),
        ),
      ],
    );
  }
}
