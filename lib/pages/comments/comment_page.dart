import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:optimized_cached_image/optimized_cached_image.dart';
import 'package:projet_lepl1509_groupe_17/models/comment.dart';
import 'package:projet_lepl1509_groupe_17/models/review.dart';
import 'package:projet_lepl1509_groupe_17/models/user_profile.dart';
import 'package:projet_lepl1509_groupe_17/pages/comments/comment_widget.dart';

class CommentPage extends StatefulWidget {
  final Review review;
  final Function setStateCallback;
  final Function refreshData;

  CommentPage({
    Key? key,
    required this.review,
    required this.setStateCallback,
    required this.refreshData,
  }) : super(key: key);

  @override
  _CommentPageState createState() => _CommentPageState();
}

class _CommentPageState extends State<CommentPage> {
  final TextEditingController commentController = TextEditingController();
  FirebaseFirestore db = FirebaseFirestore.instance;
  User? currentUser = FirebaseAuth.instance.currentUser;
  UserProfile? currentUserProfile;
  ScrollController scrollController = ScrollController();

  bool isReplying = false;
  Comment? replyComment;
  FocusNode focusNode = FocusNode();

  late Timer timer;

  @override
  initState() {
    super.initState();
    getCurrentUser();
    timer = Timer.periodic(const Duration(seconds: 10), (Timer t) {
      widget.refreshData();
    });
  }

  @override
  void dispose() {
    timer.cancel();
    super.dispose();
  }

  void getCurrentUser() {
    db
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .get()
        .then((value) {
      setState(() {
        currentUserProfile =
            UserProfile.fromMap(value.data() as Map<String, dynamic>);
      });
    });
  }

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
      likes: [],
    );

    if (!isReplying) {
      var ret = await db
          .collection('comments')
          .doc(widget.review.reviewID)
          .collection('comments')
          .add({
        'comment': newComment.comment,
        'uid': newComment.uid,
        'timestamp': newComment.timestamp,
        'likes': [],
      });

      newComment.commId = ret.id;

      setState(() {
        widget.review.comments.insert(0, newComment);
      });
    } else {
      var ret = await db
          .collection('comments')
          .doc(widget.review.reviewID)
          .collection('comments')
          .doc(replyComment!.commId)
          .collection("subcomments")
          .add({
        'comment': newComment.comment,
        'uid': newComment.uid,
        'timestamp': newComment.timestamp,
        'likes': [],
      });

      newComment.commId = ret.id;

      setState(() {
        widget.review.comments[widget.review.comments.indexOf(replyComment!)]
            .replies
            .add(newComment);
      });
    }

    widget.setStateCallback();
    commentController.clear();
  }

  void stopReply() {
    setState(() {
      isReplying = false;
      commentController.text = '';
    });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (isReplying) {
          stopReply();
          return false;
        }
        return true;
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Comments'),
        ),
        body: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Expanded(
              child: RefreshIndicator(
                onRefresh: () async {
                  widget.refreshData();
                },
                child: ListView.builder(
                  itemCount: widget.review.comments.length,
                  controller: scrollController,
                  itemBuilder: (context, index) {
                    // GlobalKey key = GlobalKey();
                    return CommentWidget(
                      // key: key,
                      comment: widget.review.comments[index],
                      review: widget.review,
                      currentUser: currentUserProfile,
                      callback: (Comment com) {
                        setState(() {
                          isReplying = true;
                          replyComment = widget.review.comments[index];
                          commentController.text =
                              '@${com.user.name.replaceAll(" ", "")} ';
                          // final RenderBox box =
                          //     key.currentContext?.findRenderObject() as RenderBox;
                          // final height = box.size.height;
                          // print(height);
                          // scrollController.animateTo(
                          //   (height * index),
                          //   duration: const Duration(milliseconds: 300),
                          //   curve: Curves.easeOut,
                          // );

                          FocusScope.of(context).requestFocus(focusNode);
                        });
                      },
                    );
                  },
                ),
              ),
            ),
            if (isReplying) ...[
              Container(
                height: 40,
                width: double.infinity,
                color: Theme.of(context).dividerColor.withOpacity(0.4),
                child: Row(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: Text("Replying to ${replyComment?.user.name}"),
                    ),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: stopReply,
                    ),
                  ],
                ),
              ),
            ],
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Row(
                children: [
                  ClipOval(
                    child: SizedBox(
                      width: 35,
                      height: 35,
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
                      focusNode: focusNode,
                      controller: commentController,
                      decoration: InputDecoration(
                        hintText: "Add a comment...",
                        hintStyle:
                            TextStyle(color: Theme.of(context).dividerColor),
                        border: InputBorder.none,
                      ),
                      onFieldSubmitted: (value) async {
                        if (value.isNotEmpty) {
                          await addComment(value);
                          if (isReplying) {
                            stopReply();
                          }
                          FocusScope.of(context).unfocus();
                        }
                      },
                      autofocus: false,
                      onTapOutside: (ev) => FocusScope.of(context).unfocus(),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.send),
                    onPressed: () async {
                      if (commentController.text.isNotEmpty) {
                        await addComment(commentController.text);
                        if (isReplying) {
                          stopReply();
                        }
                      }
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
