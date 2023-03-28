
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:projet_lepl1509_groupe_17/pages/comments/comment_list.dart';

class CommentPage extends StatefulWidget {

  final String postId;
  CommentPage({
    Key? key,
    required this.postId,
  }) : super(key: key);

  @override
  _CommentPageState createState() => _CommentPageState();
}

class _CommentPageState extends State<CommentPage> {

  final TextEditingController commentController = TextEditingController();
  var db = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Comments'),
      ),
      body: Column(
        children: [
          Expanded(
            child: CommentsList(postId: widget.postId),
          ),
          Divider(),
          ListTile(
            title: TextFormField(
              controller: commentController,
              decoration: const InputDecoration(
                hintText: 'Write a comment...',
              ),
            ),
            trailing: IconButton(
              icon: const Icon(Icons.send),
              onPressed: () {
                addComment(commentController.text);
                commentController.clear();
              },
            ),
          )
        ],
      ),
    );
  }

  Future<void> addComment(String query) async {
    await db.collection('comments').doc(widget.postId).collection('comments').add({
      'comment': query,
      'uid': FirebaseAuth.instance.currentUser!.uid,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
    });
    commentController.clear();
  }
}
