import 'package:projet_lepl1509_groupe_17/models/user_profile.dart';

class Comment {
  final String commId;
  final String comment;
  final String uid;
  final int timestamp;
  late DateTime date;
  final UserProfile user;
  List<Comment> replies = [];

  Comment(
      {required this.commId,
      required this.comment,
      required this.uid,
      required this.timestamp,
      required this.user}) {
    date = DateTime.fromMillisecondsSinceEpoch(timestamp);
  }
}
