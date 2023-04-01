import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:optimized_cached_image/optimized_cached_image.dart';
import 'package:projet_lepl1509_groupe_17/models/comment.dart';
import 'package:projet_lepl1509_groupe_17/models/review.dart';
import 'package:projet_lepl1509_groupe_17/models/user_profile.dart';
import 'package:projet_lepl1509_groupe_17/pages/profile/pages/profile_page.dart';
import 'package:time_formatter/time_formatter.dart';

class CommentPage extends StatefulWidget {
  final Review review;
  final Function setStateCallback;

  CommentPage({
    Key? key,
    required this.review,
    required this.setStateCallback,
  }) : super(key: key);

  @override
  _CommentPageState createState() => _CommentPageState();
}

class _CommentPageState extends State<CommentPage> {
  final TextEditingController commentController = TextEditingController();
  FirebaseFirestore db = FirebaseFirestore.instance;
  User? currentUser = FirebaseAuth.instance.currentUser;
  ScrollController scrollController = ScrollController();

  Future<void> addComment(String query) async {
    Comment newComment = Comment(
      commId: '',
      comment: query,
      uid: FirebaseAuth.instance.currentUser!.uid,
      timestamp: DateTime.now().millisecondsSinceEpoch,
      user: UserProfile.fromMap((await db
              .collection('users')
              .doc(FirebaseAuth.instance.currentUser!.uid)
              .get())
          .data() as Map<String, dynamic>),
    );
    try {
      await db
          .collection('comments')
          .doc(widget.review.reviewID)
          .collection('comments')
          .add({
        'comment': newComment.comment,
        'uid': newComment.uid,
        'timestamp': newComment.timestamp,
      });
    } catch (e) {
      print(e);
      return;
    }
    commentController.clear();

    setState(() {
      widget.review.comments.add(newComment);
      scrollController.animateTo(
        scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    });
    widget.setStateCallback();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Comments'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Expanded(
              child: ListView(
                controller: scrollController,
                children: widget.review.comments.map((Comment comment) {
                  return ListTile(
                    leading: CircleAvatar(
                      backgroundImage: OptimizedCacheImageProvider(
                        comment.user.photoURL,
                      ),
                    ),
                    title: Row(
                      children: [
                        Text(comment.user.name),
                        const SizedBox(width: 5),
                        Text(
                          formatTime(DateTime.fromMillisecondsSinceEpoch(
                                  comment.timestamp)
                              .millisecondsSinceEpoch),
                          style: const TextStyle(fontSize: 12),
                        ),
                      ],
                    ),
                    subtitle: Text(comment.comment),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ProfilePage(
                            accessToFeed: true,
                            uid: comment.user.uid ?? '',
                          ),
                        ),
                      );
                    },
                  );
                }).toList(),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Row(
                children: [
                  ClipOval(
                    child: SizedBox(
                      width: 35,
                      height: 35,
                      // child: Image(
                      //   image: ResizeImage(
                      //     NetworkImage(currentUser?.photoURL != null
                      //         ? currentUser!.photoURL!
                      //         : 'http://www.gravatar.com/avatar/?d=mp'),
                      //     width: 70,
                      //     height: 70,
                      //   ),
                      //   fit: BoxFit.cover,
                      // ),
                      child: OptimizedCacheImage(
                        imageUrl: currentUser?.photoURL != null
                            ? currentUser!.photoURL!
                            : 'http://www.gravatar.com/avatar/?d=mp',
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextFormField(
                      controller: commentController,
                      decoration: InputDecoration(
                        hintText: "Add a comment...",
                        hintStyle:
                            TextStyle(color: Theme.of(context).dividerColor),
                        border: InputBorder.none,
                      ),
                      onFieldSubmitted: (value) {
                        if (value.isNotEmpty) {
                          addComment(value);
                          FocusScope.of(context).unfocus();
                        }
                      },
                      autofocus: false,
                      onTapOutside: (ev) => FocusScope.of(context).unfocus(),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.send),
                    onPressed: () {
                      addComment(commentController.text);
                      commentController.clear();
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }
}
