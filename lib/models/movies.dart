import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:projet_lepl1509_groupe_17/main.dart';

class Movie {
  final int id;
  final String title;
  final String? posterPath;
  final String? backdropPath;
  final String overview;
  final double voteAverage;
  final String releaseDate;
  final int budget;
  final int revenue;
  final int runtime;
  final double popularity;
  List<Actor> actors = [];

  Movie({
    required this.id,
    required this.title,
    required this.posterPath,
    required this.backdropPath,
    required this.overview,
    required this.voteAverage,
    required this.releaseDate,
    required this.budget,
    required this.revenue,
    required this.runtime,
    required this.popularity,
  });

  static Future<List<Actor>> getActors(int id) async {
    List<Actor> actors = [];
    var response = await http.get(Uri.parse(
        "https://api.themoviedb.org/3/movie/$id/credits?api_key=$themoviedbApi&language=en-US&page=1&include_adult=false"));
    if (response.statusCode == 200) {
      Map<String, dynamic> jsonResponse = json.decode(response.body);
      var cast = jsonResponse['cast'];
      for (var castMember in cast) {
        Actor actor = Actor.fromJson(castMember);
        actors.add(actor);
      }
    } else {
      if (kDebugMode) {
        print('Request failed with status: ${response.statusCode}.');
      }
    }
    return actors;
  }

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

  factory Movie.fromJson(Map<String, dynamic> json) {
    return Movie(
      id: json['id'],
      title: json['title'],
      posterPath: json['poster_path'] != null
          ? "https://image.tmdb.org/t/p/w500${json['poster_path']}"
          : null,
      backdropPath: json['backdrop_path'] != null
          ? "https://image.tmdb.org/t/p/w500${json['backdrop_path']}"
          : null,
      overview: json['overview'],
      voteAverage: json['vote_average'].toDouble(),
      releaseDate: json['release_date'],
      budget: json['budget'],
      revenue: json['revenue'],
      runtime: json['runtime'],
      popularity: json['popularity'],
    );
  }
}

class Actor {
  final int id;
  final String name;
  final String? profilePath;
  final String character;
  final String knownForDepartment;

  Actor({
    required this.id,
    required this.name,
    required this.profilePath,
    required this.character,
    required this.knownForDepartment,
  });

  factory Actor.fromJson(Map<String, dynamic> json) {
    return Actor(
      id: json['id'],
      name: json['name'],
      profilePath: json['profile_path'] != null
          ? "https://image.tmdb.org/t/p/w500${json['profile_path']}"
          : null,
      character: json['character'],
      knownForDepartment: json['known_for_department'],
    );
  }
}
