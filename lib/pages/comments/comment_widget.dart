import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_rich_text/easy_rich_text.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:optimized_cached_image/optimized_cached_image.dart';
import 'package:projet_lepl1509_groupe_17/models/comment.dart';
import 'package:projet_lepl1509_groupe_17/models/user_profile.dart';
import 'package:time_formatter/time_formatter.dart';

import '../../models/review.dart';
import '../profile/pages/profile_page.dart';

class CommentWidget extends StatefulWidget {
  final Comment comment;
  final Review review;
  final UserProfile? currentUser;
  final Function callback;
  final Function refreshData;
  const CommentWidget(
      {super.key,
      required this.comment,
      required this.review,
      required this.currentUser,
      required this.callback,
      required this.refreshData});

  @override
  _CommentWidgetState createState() => _CommentWidgetState();
}

class _CommentWidgetState extends State<CommentWidget> {
  bool seeReplies = false;
  bool isReviewAuthor = false;

  @override
  void initState() {
    super.initState();
    if (widget.review.userID == widget.comment.user.uid) {
      isReviewAuthor = true;
    }
  }

  Future<void> likeComment() async {
    if (widget.currentUser == null) {
      return;
    }
    if (widget.comment.likes.where((element) => element.uid == widget.currentUser!.uid).isNotEmpty) {
      widget.comment.likes.removeWhere((element) => element.uid == widget.currentUser!.uid);

      // remove the like in firebase
      await FirebaseFirestore.instance
          .collection('comments')
          .doc(widget.review.reviewID)
          .collection('comments')
          .doc(widget.comment.commId)
          .update({
        'likes': FieldValue.arrayRemove([widget.currentUser!.uid])
      });
      setState(() {});
    } else {
      widget.comment.likes.add(widget.currentUser!);
      // add the like in firebase
      await FirebaseFirestore.instance
          .collection('comments')
          .doc(widget.review.reviewID)
          .collection('comments')
          .doc(widget.comment.commId)
          .update({
        'likes': FieldValue.arrayUnion([widget.currentUser!.uid])
      });
      setState(() {});
    }
  }

  void deleteComment() async {
    await FirebaseFirestore.instance
        .collection('comments')
        .doc(widget.review.reviewID)
        .collection('comments')
        .doc(widget.comment.commId)
        .delete();
    widget.refreshData();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return widget.currentUser == null
        ? const Center(child: CircularProgressIndicator())
        : Padding(
            padding: const EdgeInsets.all(10.0),
            child: Row(
              mainAxisSize: MainAxisSize.max,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ProfilePage(
                          accessToFeed: widget.comment.user.uid == widget.currentUser!.uid,
                          uid: widget.comment.user.uid ?? "",
                        ),
                      ),
                    );
                  },
                  child: Padding(
                    padding: const EdgeInsets.only(top: 7.0),
                    child: CircleAvatar(
                      backgroundImage: OptimizedCacheImageProvider(
                        widget.comment.user.photoURL,
                      ),
                      radius: 20,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.max,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // top row with author name, badge, and time posted
                      Row(
                        mainAxisSize: MainAxisSize.max,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // author name and badge
                          Row(
                            children: [
                              GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => ProfilePage(
                                        accessToFeed: widget.comment.user.uid == widget.currentUser!.uid,
                                        uid: widget.comment.user.uid ?? "",
                                      ),
                                    ),
                                  );
                                },
                                child: Text(
                                  widget.comment.user.name,
                                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                                ),
                              ),
                              const SizedBox(width: 5),
                              // author badge
                              // if (isReviewAuthor)
                              //   Container(
                              //     padding: const EdgeInsets.symmetric(
                              //         horizontal: 5, vertical: 2),
                              //     decoration: BoxDecoration(
                              //       color:
                              //           Theme.of(context).colorScheme.primary,
                              //       borderRadius: BorderRadius.circular(10),
                              //     ),
                              //     child: Text(
                              //       'Author',
                              //       style: TextStyle(
                              //         color: Theme.of(context)
                              //             .colorScheme
                              //             .onPrimary,
                              //         fontSize: 10,
                              //       ),
                              //     ),
                              //   ),
                            ],
                          ),
                          // time posted
                          Text(
                            formatTime(
                              DateTime.fromMillisecondsSinceEpoch(widget.comment.timestamp).millisecondsSinceEpoch,
                            ),
                            style: const TextStyle(fontSize: 12),
                          ),
                        ],
                      ),

                      // row with comment text with @mentions in color, and like button
                      Row(
                        mainAxisSize: MainAxisSize.max,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Flexible(
                            child: Padding(
                              padding: const EdgeInsets.only(top: 3),
                              child: EasyRichText(
                                widget.comment.comment,
                                patternList: [
                                  EasyRichTextPattern(
                                    targetString: '@[a-zA-Z0-9]*',
                                    style: const TextStyle(color: Colors.blueAccent),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Tooltip(
                            message: widget.comment.likes.map((e) => e.name).join(", "),
                            waitDuration: const Duration(milliseconds: 10),

                            // like button
                            child: TextButton.icon(
                              onPressed: likeComment,
                              style: ButtonStyle(
                                visualDensity: VisualDensity.compact,
                                padding: MaterialStateProperty.all(
                                  EdgeInsets.zero,
                                ),
                              ),
                              label: Text(
                                widget.comment.likes.length.toString(),
                                style: TextStyle(
                                    fontSize: 13,
                                    color: widget.comment.likes
                                            .where((element) => element.uid == widget.currentUser!.uid)
                                            .isNotEmpty
                                        ? Colors.red
                                        : Theme.of(context).dividerColor),
                              ),
                              icon: Icon(
                                widget.comment.likes
                                        .where((element) => element.uid == widget.currentUser!.uid)
                                        .isNotEmpty
                                    ? CupertinoIcons.heart_fill
                                    : CupertinoIcons.heart,
                                color: widget.comment.likes
                                        .where((element) => element.uid == widget.currentUser!.uid)
                                        .isNotEmpty
                                    ? Colors.red
                                    : Theme.of(context).dividerColor,
                                size: 20,
                              ),
                            ),
                          ),
                        ],
                      ),

                      Row(
                        children: [
                          // reply button
                          GestureDetector(
                            child: Text("Reply", style: TextStyle(color: Theme.of(context).dividerColor, fontSize: 13)),
                            onTap: () {
                              widget.callback(widget.comment);
                            },
                          ),
                          const SizedBox(width: 5),

                          // show delete button for comment author
                          if (widget.currentUser!.uid == widget.comment.uid)
                            GestureDetector(
                              child: const Text("Delete", style: TextStyle(color: Colors.red, fontSize: 13)),
                              onTap: () {
                                // show alert asking to confirm the deletion
                                showDialog(
                                  context: context,
                                  builder: (context) => AlertDialog(
                                    title: const Text("Delete comment"),
                                    content: const Text("Are you sure you want to delete this comment?"),
                                    actions: [
                                      TextButton(
                                        onPressed: () {
                                          Navigator.pop(context);
                                        },
                                        child: const Text("Cancel"),
                                      ),
                                      TextButton(
                                        onPressed: () {
                                          // delete comment
                                          deleteComment();
                                          Navigator.pop(context);
                                        },
                                        child: Text("Ok"),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                        ],
                      ),
                      if (widget.comment.replies.isNotEmpty) ...[
                        if (!seeReplies) ...[
                          ReplyComment(
                            mainComment: widget.comment,
                            comment: widget.comment.replies[0],
                            review: widget.review,
                            currentUser: widget.currentUser,
                            callback: widget.callback,
                            refreshData: widget.refreshData,
                          ).animate().fade(),
                        ],

                        // replies
                        for (var reply in widget.comment.replies)
                          if (seeReplies) ...[
                            ReplyComment(
                              mainComment: widget.comment,
                              comment: reply,
                              review: widget.review,
                              currentUser: widget.currentUser,
                              callback: widget.callback,
                              refreshData: widget.refreshData,
                            ).animate().fade(),
                          ],

                        if (widget.comment.replies.length > 1)
                          GestureDetector(
                            child: Text(
                              seeReplies ? "Hide replies" : "See replies (${widget.comment.replies.length - 1})",
                              style: TextStyle(
                                color: Theme.of(context).dividerColor,
                                fontSize: 13,
                              ),
                            ),
                            onTap: () {
                              setState(() {
                                seeReplies = !seeReplies;
                              });
                            },
                          ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          );
  }
}

class ReplyComment extends StatefulWidget {
  final Comment mainComment;
  final Comment comment;
  final Review review;
  final UserProfile? currentUser;
  final Function callback;
  final Function refreshData;
  const ReplyComment({
    super.key,
    required this.comment,
    required this.review,
    required this.currentUser,
    required this.callback,
    required this.mainComment,
    required this.refreshData,
  });

  @override
  State<ReplyComment> createState() => _ReplyCommentState();
}

class _ReplyCommentState extends State<ReplyComment> {
  bool isReviewAuthor = false;

  @override
  void initState() {
    super.initState();
    isReviewAuthor = widget.review.userID == widget.comment.user.uid;
  }

  Future<void> likeReply() async {
    if (widget.currentUser == null) {
      return;
    }
    if (widget.comment.likes.where((element) => element.uid == widget.currentUser!.uid).isNotEmpty) {
      widget.comment.likes.removeWhere((element) => element.uid == widget.currentUser!.uid);

      // remove the like in firebase
      await FirebaseFirestore.instance
          .collection('comments')
          .doc(widget.review.reviewID)
          .collection('comments')
          .doc(widget.mainComment.commId)
          .collection("subcomments")
          .doc(widget.comment.commId)
          .update({
        'likes': FieldValue.arrayRemove([widget.currentUser!.uid])
      });
      setState(() {});
    } else {
      widget.comment.likes.add(widget.currentUser!);
      // add the like in firebase
      await FirebaseFirestore.instance
          .collection('comments')
          .doc(widget.review.reviewID)
          .collection('comments')
          .doc(widget.mainComment.commId)
          .collection("subcomments")
          .doc(widget.comment.commId)
          .update({
        'likes': FieldValue.arrayUnion([widget.currentUser!.uid])
      });
      setState(() {});
    }
  }

  void deleteReply() async {
    await FirebaseFirestore.instance
        .collection('comments')
        .doc(widget.review.reviewID)
        .collection('comments')
        .doc(widget.mainComment.commId)
        .collection("subcomments")
        .doc(widget.comment.commId)
        .delete();
    widget.refreshData();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return widget.currentUser == null
        ? const Center(child: CircularProgressIndicator())
        : Padding(
            padding: const EdgeInsets.symmetric(vertical: 7.0),
            child: Row(
              mainAxisSize: MainAxisSize.max,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ProfilePage(
                          accessToFeed: widget.comment.user.uid == widget.currentUser!.uid,
                          uid: widget.comment.user.uid ?? "",
                        ),
                      ),
                    );
                  },
                  child: Padding(
                    padding: const EdgeInsets.only(top: 5.0),
                    child: CircleAvatar(
                      backgroundImage: OptimizedCacheImageProvider(
                        widget.comment.user.photoURL,
                      ),
                      radius: 15,
                    ),
                  ),
                ),
                const SizedBox(width: 5),
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.max,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.max,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => ProfilePage(
                                        accessToFeed: widget.comment.user.uid == widget.currentUser!.uid,
                                        uid: widget.comment.user.uid ?? "",
                                      ),
                                    ),
                                  );
                                },
                                child: Text(
                                  widget.comment.user.name,
                                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                                ),
                              ),
                              const SizedBox(width: 5),
                              // author badge
                              // if (isReviewAuthor)
                              //   Container(
                              //     padding: const EdgeInsets.symmetric(
                              //         horizontal: 3, vertical: 2),
                              //     decoration: BoxDecoration(
                              //       color:
                              //           Theme.of(context).colorScheme.primary,
                              //       borderRadius: BorderRadius.circular(10),
                              //     ),
                              //     child: Text(
                              //       'Author',
                              //       style: TextStyle(
                              //         color: Theme.of(context)
                              //             .colorScheme
                              //             .onPrimary,
                              //         fontSize: 9,
                              //       ),
                              //     ),
                              //   ),
                            ],
                          ),
                          Text(
                            formatTime(
                              DateTime.fromMillisecondsSinceEpoch(widget.comment.timestamp).millisecondsSinceEpoch,
                            ),
                            style: const TextStyle(fontSize: 11),
                          ),
                        ],
                      ),

                      // row with comment text with @mentions in color, and like button
                      Row(
                        mainAxisSize: MainAxisSize.max,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Flexible(
                            child: Padding(
                              padding: const EdgeInsets.only(top: 3),
                              child: EasyRichText(
                                widget.comment.comment,
                                patternList: [
                                  EasyRichTextPattern(
                                    targetString: '@[a-zA-Z0-9]*',
                                    style: const TextStyle(color: Colors.blueAccent),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Tooltip(
                            message: widget.comment.likes.map((e) => e.name).join(", "),
                            waitDuration: const Duration(milliseconds: 10),
                            // like button
                            child: TextButton.icon(
                              onPressed: likeReply,
                              style: const ButtonStyle(
                                visualDensity: VisualDensity.compact,
                              ),
                              label: Text(
                                widget.comment.likes.length.toString(),
                                style: TextStyle(
                                    fontSize: 13,
                                    color: widget.comment.likes
                                            .where((element) => element.uid == widget.currentUser!.uid)
                                            .isNotEmpty
                                        ? Colors.red
                                        : Theme.of(context).dividerColor),
                              ),
                              icon: Icon(
                                widget.comment.likes
                                        .where((element) => element.uid == widget.currentUser!.uid)
                                        .isNotEmpty
                                    ? CupertinoIcons.heart_fill
                                    : CupertinoIcons.heart,
                                color: widget.comment.likes
                                        .where((element) => element.uid == widget.currentUser!.uid)
                                        .isNotEmpty
                                    ? Colors.red
                                    : Theme.of(context).dividerColor,
                                size: 20,
                              ),
                            ),
                          ),
                        ],
                      ),

                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          GestureDetector(
                            child: Text(
                              "Reply",
                              style: TextStyle(color: Theme.of(context).dividerColor, fontSize: 13),
                            ),
                            onTap: () {
                              widget.callback(widget.comment);
                            },
                          ),

                          const SizedBox(width: 5),

                          // show delete button for comment author
                          if (widget.currentUser!.uid == widget.comment.uid)
                            GestureDetector(
                              child: const Text("Delete", style: TextStyle(color: Colors.red, fontSize: 13)),
                              onTap: () {
                                // show alert asking to confirm the deletion
                                showDialog(
                                  context: context,
                                  builder: (context) => AlertDialog(
                                    title: const Text("Delete reply"),
                                    content: const Text("Are you sure you want to delete this reply?"),
                                    actions: [
                                      TextButton(
                                        onPressed: () {
                                          Navigator.pop(context);
                                        },
                                        child: const Text("Cancel"),
                                      ),
                                      TextButton(
                                        onPressed: () {
                                          // delete reply
                                          deleteReply();
                                          Navigator.pop(context);
                                        },
                                        child: const Text("Ok"),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
  }
}
