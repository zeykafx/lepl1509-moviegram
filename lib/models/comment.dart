import 'package:projet_lepl1509_groupe_17/models/user_profile.dart';

class Comment {
  final String commId;
  final String comment;
  final String uid;
  final int timestamp;
  late DateTime date;
  final UserProfile user;

  Comment(
      {required this.commId, required this.comment, required this.uid, required this.timestamp, required this.user}) {
    date = DateTime.fromMillisecondsSinceEpoch(timestamp);
  }

  factory Comment.fromJson(Map<String, dynamic> json) {
    return Comment(
      commId: json['commId'],
      comment: json['comment'],
      uid: json['uid'],
      timestamp: json['timestamp'],
      user: UserProfile.fromMap(json['user']),
    );
  }
}
