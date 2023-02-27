class Review {
  final String title;
  final String comment;
  final double rating;
  final List<dynamic> actors;
  final String userID;
  final int dateTimestamp;
  final int lengthMin;
  final String posterUrl;

  Review(this.title, this.comment, this.rating, this.actors, this.userID,
      this.dateTimestamp, this.lengthMin, this.posterUrl);

  static Review fromMap(Map<String, dynamic> map) {
    return Review(
      map['title'],
      map['comment'],
      map['rating'],
      map['actors'],
      map['userID'],
      map['dateTimestamp'],
      map['lengthMin'],
      map['posterUrl'],
    );
  }
}
