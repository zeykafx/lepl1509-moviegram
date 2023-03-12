import 'package:cloud_firestore/cloud_firestore.dart';

class Movie {
  final List<dynamic> actors;
  final String category;
  final String duration;
  final Timestamp release_date;
  final String summary;
  final String title;
  final String url;

  Movie(this.actors, this.category, this.duration, this.release_date,
      this.summary, this.title, this.url);

  static Movie fromMap(Map<String, dynamic> map) {
    return Movie(
      map['actors'],
      map['category'],
      map['duration'],
      map['release_date'],
      map['summary'],
      map['title'],
      map['url'],
    );
  }
}
