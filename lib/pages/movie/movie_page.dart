import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:projet_lepl1509_groupe_17/components/drawer/drawer.dart';
import 'package:projet_lepl1509_groupe_17/models/movies.dart';
import 'package:projet_lepl1509_groupe_17/models/review.dart';
import 'package:projet_lepl1509_groupe_17/pages/home/create_review_page.dart';
import 'package:projet_lepl1509_groupe_17/pages/home/home_page.dart';
import 'package:projet_lepl1509_groupe_17/pages/movie/movie_page.dart';
import 'package:projet_lepl1509_groupe_17/pages/search/search_page.dart';

User? currentUser = FirebaseAuth.instance.currentUser;

class MoviePage extends StatelessWidget {
  final Movie movie;

  const MoviePage({Key? key, required this.movie}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF000B49),
        actions: [
          IconButton(
              color: Colors.white,
              onPressed: () {
                Get.to(() => const SearchPage());
              },
              icon: const Icon(Icons.arrow_back))
        ],
      ),
      body: Stack(
        children: [
          ..._buildBackground(context, movie),
          Positioned(
            bottom: 150,
            width: MediaQuery.of(context).size.width,
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                children: [
                  Text(
                    movie.title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(
                    height: 10.0,
                  ),
                  Text(
                    "${movie.release_date.toDate().day}/${movie.release_date.toDate().month}/${movie.release_date.toDate().year} | ${movie.category} | ${movie.duration}",
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 10.0),
                  RatingBar.builder(
                    initialRating: 3.5,
                    minRating: 1,
                    maxRating: 5,
                    direction: Axis.horizontal,
                    allowHalfRating: true,
                    ignoreGestures: true,
                    itemCount: 5,
                    itemSize: 20,
                    unratedColor: Colors.white,
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
                    movie.summary,
                    maxLines: 10,
                    style: Theme.of(context)
                        .textTheme
                        .bodySmall!
                        .copyWith(height: 1.75, color: Colors.white),
                  ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  List<Widget> _buildBackground(context, movie) {
    return [
      Container(
        height: double.infinity,
        color: const Color(0xFF000B49),
      ),
      Image.network(
        movie.url,
        width: double.infinity,
        height: MediaQuery.of(context).size.height * 0.5,
        fit: BoxFit.cover,
      ),
      const Positioned.fill(
          child: DecoratedBox(
        decoration: BoxDecoration(
            gradient: LinearGradient(
          colors: [
            Colors.transparent,
            Color(0xFF000B49),
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          stops: [0.3, 0.5],
        )),
      )),
    ];
  }
}
