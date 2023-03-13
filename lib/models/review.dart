import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:projet_lepl1509_groupe_17/main.dart';

import 'movies.dart';

class Review {
  final String comment;
  final double rating;
  final double actingRating;
  final double storyRating;
  final double lengthRating;
  final int movieID;
  final String username;
  final String userID;

  Review(this.comment, this.rating, this.actingRating, this.storyRating,
      this.lengthRating, this.movieID, this.username, this.userID);

  static Future<Movie?> getMovieDetails(int movieID) async {
    Movie? movie;
    var response = await http.get(Uri.parse(
        "https://api.themoviedb.org/3/movie/$movieID?api_key=$themoviedbApi&language=en-US&page=1&include_adult=false"));
    if (response.statusCode == 200) {
      Map<String, dynamic> jsonResponse = json.decode(response.body);
      movie = Movie.fromJson(jsonResponse);
    } else {
      if (kDebugMode) {
        print('Request failed with status: ${response.statusCode}.');
      }
    }
    return movie;
  }

  static Review fromJson(Map<String, dynamic> json) {
    return Review(
      json['comment'],
      json['rating'],
      json['actingRating'],
      json['storyRating'],
      json['lengthRating'],
      json['movieID'],
      json['username'],
      json['userID'],
    );
  }
}
