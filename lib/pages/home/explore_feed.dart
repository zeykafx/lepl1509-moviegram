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
    return const Column(
      children: [
        SlidableMovieList(
          size: 250,
          type: SlidableMovieListType.popular,
          padding: EdgeInsets.only(left: 20, right: 20, top: 20),
        )
      ],
    );
  }
}
