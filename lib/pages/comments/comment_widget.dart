import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:optimized_cached_image/optimized_cached_image.dart';
import 'package:projet_lepl1509_groupe_17/models/comment.dart';
import 'package:time_formatter/time_formatter.dart';

class CommentWidget extends StatefulWidget {
  final Comment comment;
  final Function callback;
  const CommentWidget(
      {super.key, required this.comment, required this.callback});

  @override
  _CommentWidgetState createState() => _CommentWidgetState();
}

class _CommentWidgetState extends State<CommentWidget> {
  late Comment comment;
  bool seeReplies = false;

  @override
  void initState() {
    super.initState();
    comment = widget.comment;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Row(
        mainAxisSize: MainAxisSize.max,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 5.0),
            child: CircleAvatar(
              backgroundImage: OptimizedCacheImageProvider(
                comment.user.photoURL,
              ),
              radius: 22,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.max,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  // crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      comment.user.name,
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.w600),
                    ),
                    Text(
                      formatTime(
                        DateTime.fromMillisecondsSinceEpoch(comment.timestamp)
                            .millisecondsSinceEpoch,
                      ),
                      style: const TextStyle(fontSize: 12),
                    ),
                  ],
                ),
                Text(comment.comment),
                GestureDetector(
                  child: Text("Reply",
                      style: TextStyle(
                          color: Theme.of(context).dividerColor, fontSize: 13)),
                  onTap: () {
                    widget.callback(comment);
                  },
                ),
                if (comment.replies.isNotEmpty) ...[
                  if (!seeReplies) ...[
                    ReplyComment(
                      comment: comment.replies[0],
                      callback: widget.callback,
                    ).animate().fade(),
                  ],

                  // replies
                  for (var reply in comment.replies)
                    if (seeReplies) ...[
                      ReplyComment(comment: reply, callback: widget.callback)
                          .animate()
                          .fade(),
                    ],

                  if (comment.replies.length > 1)
                    GestureDetector(
                      child: Text(
                        seeReplies ? "Hide replies" : "See replies",
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
  final Comment comment;
  final Function callback;
  const ReplyComment(
      {super.key, required this.comment, required this.callback});

  @override
  State<ReplyComment> createState() => _ReplyCommentState();
}

class _ReplyCommentState extends State<ReplyComment> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 7.0),
      child: Row(
        mainAxisSize: MainAxisSize.max,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 5.0),
            child: CircleAvatar(
              backgroundImage: OptimizedCacheImageProvider(
                widget.comment.user.photoURL,
              ),
              radius: 15,
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
                  // crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      widget.comment.user.name,
                      style: const TextStyle(
                          fontSize: 14, fontWeight: FontWeight.w500),
                    ),
                    Text(
                      formatTime(
                        DateTime.fromMillisecondsSinceEpoch(
                                widget.comment.timestamp)
                            .millisecondsSinceEpoch,
                      ),
                      style: const TextStyle(fontSize: 11),
                    ),
                  ],
                ),
                Text(widget.comment.comment,
                    style: const TextStyle(fontSize: 13)),
                GestureDetector(
                  child: Text("Reply",
                      style: TextStyle(
                          color: Theme.of(context).dividerColor, fontSize: 13)),
                  onTap: () {
                    widget.callback(widget.comment);
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
