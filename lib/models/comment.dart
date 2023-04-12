import 'package:projet_lepl1509_groupe_17/models/user_profile.dart';

class Comment {
  String commId;
  final String comment;
  final String uid;
  final int timestamp;
  late DateTime date;
  final UserProfile user;
  List<Comment> replies = [];
  List<UserProfile> likes = [];

  Comment(
      {required this.commId,
      required this.comment,
      required this.uid,
      required this.timestamp,
      required this.user,
      required this.likes}) {
    date = DateTime.fromMillisecondsSinceEpoch(timestamp);
  }
}
