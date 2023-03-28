import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:time_formatter/time_formatter.dart';

import '../../models/user_profile.dart';
import '../profile/pages/profile_page.dart';

class CommentsList extends StatefulWidget {
  final String postId;
  const CommentsList({super.key, required this.postId});

  @override
  _CommentsListState createState() => _CommentsListState();
}

class _CommentsListState extends State<CommentsList> {

  User? currentUser = FirebaseAuth.instance.currentUser;
  FirebaseFirestore db = FirebaseFirestore.instance;
  List<Map<String, dynamic>> comments = [];
  UserProfile? userProfile;
  bool loading = false;

  @override
  void initState() {
    super.initState();
    readUserData();
  }


  Future<void> readUserData() async {
    setState(() {
      loading = true;
    });
    var value = await db.collection('users').doc(currentUser?.uid).get();
    setState(() {
      userProfile = UserProfile.fromMap(value.data() as Map<String, dynamic>);
    });
    var followingVal = await db
        .collection('comments')
        .doc(widget.postId)
        .collection('comments')
        .get();
    for (var element in followingVal.docs) {
      comments.add({
        "commId": element.id,
        "comment": element.data()["comment"],
        "uid": element.data()["uid"],
        "timestamp": element.data()["timestamp"],
        "user": await db.collection('users').doc(element.data()["uid"]).get(),
      });
    }
    setState(() {
      comments.sort((a, b) => b["timestamp"].compareTo(a["timestamp"]));
      loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if(comments.isEmpty) {
      return const Center(child: Text("No comments"));
    } else {
      return ListView(
        children: comments.map((e) => CommentResult(
          UserProfile.fromMap(e["user"].data() as Map<String, dynamic>),
          e["comment"],
          e["timestamp"],
        )).toList(),
      );
    }

  }
}

class CommentResult extends StatelessWidget {
  final UserProfile user;
  final String? comment;
  final int timestamp;

  CommentResult(
      this.user,
      this.comment,
      this.timestamp,
      {super.key}
      );

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: CircleAvatar(
        backgroundImage: NetworkImage(user.photoURL),
      ),
      title: Row(
        children: [
          Text(user.name),
          const SizedBox(width: 5),
          Text(
              formatTime(DateTime.fromMillisecondsSinceEpoch(timestamp).millisecondsSinceEpoch),
            style: const TextStyle(fontSize: 12),
          ),
        ],
      ),
      subtitle: Text(comment ?? ''),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ProfilePage(
              accessToFeed: true,
              uid: user.uid ?? '',
            ),
          ),
        );
      },
    );
  }
}

void removeFriend({String? to, String? from}) {
  FirebaseFirestore.instance.collection('following').doc(to).collection('userFollowing').doc(from).delete();
}
