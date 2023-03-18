import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:projet_lepl1509_groupe_17/main.dart';
import 'package:projet_lepl1509_groupe_17/models/user_profile.dart';

import 'movies.dart';

class Review {
  final String reviewID;
  final String comment;
  final double rating;
  final double actingRating;
  final double storyRating;
  final double lengthRating;
  final int movieID;
  final String username;
  final String userID;
  final DateTime postedTime;
  final List<ReviewComment> comments;
  final List<UserProfile> likes;

  Review(this.comment, this.rating, this.actingRating, this.storyRating, this.lengthRating, this.movieID, this.username,
      this.userID, this.postedTime, this.reviewID, this.comments, this.likes);

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

  static Future<Review> fromJson(String id, Map<String, dynamic> json) async {
    List<ReviewComment> comments = [];
    List<UserProfile> likes = [];
    if (json['comments'] != null) {
      for (var i = 0; i < json['comments'].length; i++) {
        DocumentSnapshot<Map<String, dynamic>> value =
            await FirebaseFirestore.instance.collection('comments').doc(json["comments"][i]).get();
        comments.add(ReviewComment.fromJson(json['comments'][i], value.data()!));
      }
    }
    if (json['likes'] != null) {
      for (var i = 0; i < json['likes'].length; i++) {
        DocumentSnapshot<Map<String, dynamic>> value =
            await FirebaseFirestore.instance.collection('users').doc(json["likes"][i]).get();
        likes.add(UserProfile.fromMap(value.data()!));
      }
    }

    return Review(
      json['comment'],
      json['rating'],
      json['actingRating'],
      json['storyRating'],
      json['lengthRating'],
      json['movieID'],
      json['username'],
      json['userID'],
      DateTime.fromMillisecondsSinceEpoch(json['timestamp']),
      id,
      json['comments'] != null ? comments : [],
      json['likes'] != null ? likes : [],
    );
  }
}

class ReviewComment {
  final String commentID;
  final String content;
  final String reviewID;
  final String userID;
  final DateTime postedTime;

  ReviewComment(this.commentID, this.content, this.reviewID, this.userID, this.postedTime);

  static ReviewComment fromJson(String id, Map<String, dynamic> json) {
    return ReviewComment(
      id,
      json['content'],
      json['reviewID'],
      json['userID'],
      DateTime.fromMillisecondsSinceEpoch(json['timestamp']),
    );
  }
}
