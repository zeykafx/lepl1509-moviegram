import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import 'package:optimized_cached_image/optimized_cached_image.dart';
import 'package:projet_lepl1509_groupe_17/models/movies.dart';
import 'package:projet_lepl1509_groupe_17/models/review.dart';
import 'package:projet_lepl1509_groupe_17/models/search_movie.dart';
import 'package:projet_lepl1509_groupe_17/models/user_profile.dart';
import 'package:projet_lepl1509_groupe_17/pages/comments/comment_page.dart';
import 'package:projet_lepl1509_groupe_17/pages/movie/movie_page.dart';
import 'package:projet_lepl1509_groupe_17/pages/profile/pages/profile_page.dart';
import 'package:skeletons/skeletons.dart';
import 'package:time_formatter/time_formatter.dart';

class ReviewCard extends StatefulWidget {
  final String id;
  final Map<String, dynamic> data;
  final UserProfile? user;
  final bool showRatingPill;

  ReviewCard({super.key, required this.id, required this.data, required this.user, this.showRatingPill = false});

  @override
  _ReviewCardState createState() => _ReviewCardState();
}

class _ReviewCardState extends State<ReviewCard> with AutomaticKeepAliveClientMixin {
  FirebaseFirestore db = FirebaseFirestore.instance;
  Review? review;
  UserProfile? author;
  User? currentUser = FirebaseAuth.instance.currentUser;
  int nbComments = 0;

  TextEditingController commentController = TextEditingController();

  bool showRatingPill = false;
  Function(void Function())? setStateDialogCallback;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    showRatingPill = widget.showRatingPill;
    Review.fromJson(widget.id, widget.data).then((value) {
      if (mounted) {
        setState(() {
          review = value;
        });
        getAuthorAndComments();
      }
    });
  }

  Future<void> refreshData() async {
    if (kDebugMode) {
      print("refreshing review card");
    }
    await db.collection("posts").doc(review!.userID).collection("userPosts").doc(review!.reviewID).get().then((value) {
      Review.fromJson(review!.reviewID, value.data()!).then((value) {
        if (mounted) {
          setState(() {
            review = value;
          });
          if (setStateDialogCallback != null && mounted) {
            setStateDialogCallback!(() {});
          }
          getAuthorAndComments();
        }
      });
    });
  }

  Future<void> getAuthorAndComments() async {
    DocumentSnapshot<Map<String, dynamic>> value = await db.collection('users').doc(review?.userID).get();
    if (value != null && mounted) {
      setState(() {
        author = UserProfile.fromMap(value.data()!);
      });
    } else {
      print("failed to get user profile in review card, maybe the card was disposed before the future finished");
    }
    var commentsVal = await db.collection('comments').doc(widget.id).collection('comments').get();
    setState(() {
      nbComments = commentsVal.docs.length;
    });
  }

  Future<bool> addLike() async {
    try {
      await FirebaseFirestore.instance
          .collection("posts")
          .doc(review!.userID)
          .collection('userPosts')
          .doc(review!.reviewID)
          .update({
        "likes": FieldValue.arrayUnion([widget.user!.uid])
      });
      return true;
    } catch (e) {
      print(e);
      return false;
    }
  }

  Future<bool> removeLike() async {
    try {
      await FirebaseFirestore.instance
          .collection("posts")
          .doc(review!.userID)
          .collection('userPosts')
          .doc(review!.reviewID)
          .update({
        "likes": FieldValue.arrayRemove([widget.user!.uid])
      });
      return true;
    } catch (e) {
      print(e);
      return false;
    }
  }

  Future<void> addComment(String query) async {
    await db.collection('comments').doc(widget.id).collection('comments').add({
      'comment': query,
      'uid': FirebaseAuth.instance.currentUser!.uid,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
    });
    commentController.clear();
  }

  Future<void> deleteReview(String reviewID) async {
    await db.collection('posts').doc(review!.userID).collection('userPosts').doc(reviewID).delete();
    setState(() {
      review = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    super.build(context);
    return review != null
        ? FutureBuilder(
            future: Movie.getMovieDetails(review!.movieID),
            builder: (context, snapshot) {
              Movie? movie = snapshot.data;
              return snapshot.hasData && author != null
                  ? AnimatedSize(
                      duration: const Duration(milliseconds: 500),
                      curve: Curves.easeOut,
                      child: Card(
                        key: Key(review!.reviewID),
                        elevation: 0.5,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                          side: BorderSide(
                            color: Colors.grey.withOpacity(0.2),
                            width: 1,
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            vertical: 10,
                            horizontal: 15,
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.max,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 8),

                              // header
                              buildHeader(),

                              const SizedBox(height: 10),

                              Text(
                                review!.comment,
                                style: const TextStyle(fontSize: 18),
                              ),
                              const SizedBox(height: 10),

                              // movie card, on which you can click
                              Card(
                                elevation: 0.5,
                                shadowColor: Colors.transparent,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(15),
                                  side: BorderSide(
                                    color: Colors.grey.withOpacity(0.2),
                                    width: 0.8,
                                  ),
                                ),
                                child: Stack(
                                  children: [
                                    // blurred out movie poster
                                    if (movie?.backdropPath != null)
                                      Positioned.fill(
                                        child: ClipRRect(
                                          borderRadius: BorderRadius.circular(15),
                                          clipBehavior: Clip.antiAlias,
                                          child: Opacity(
                                            opacity: Get.isDarkMode ? 0.1 : 0.1,
                                            child: ImageFiltered(
                                              imageFilter: ImageFilter.blur(
                                                sigmaX: 3,
                                                sigmaY: 3,
                                              ),
                                              child: OptimizedCacheImage(
                                                fit: BoxFit.cover,
                                                imageUrl: "https://image.tmdb.org/t/p/w500/${movie?.backdropPath}",
                                                width: size.width,
                                                errorWidget: (context, url, error) => const Icon(Icons.error),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    Padding(
                                      padding: const EdgeInsets.all(12.0),
                                      child: buildMovieInfo(movie!),
                                    ),
                                  ],
                                ),
                              ),

                              if (showRatingPill) ...[
                                const SizedBox(height: 10),

                                // ratings bar
                                buildRatings(),
                              ],

                              if (!showRatingPill) ...[
                                const SizedBox(height: 5),
                                Padding(
                                  padding: const EdgeInsets.only(left: 8.0),
                                  child: GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        showRatingPill = true;
                                      });
                                    },
                                    child: Text(
                                      "Show more...",
                                      style: TextStyle(
                                        color: Theme.of(context).dividerColor,
                                        fontSize: 15,
                                      ),
                                    ),
                                  ),
                                ),
                              ],

                              buildLikesAndComments(size),
                            ],
                          ),
                        ),
                      ),
                    )
                  : buildSkeletonCard().animate().fadeIn();
            }).animate().fadeIn()
        : buildSkeletonCard().animate().fadeIn();
  }

  Widget buildHeader() {
    return Row(
      children: [
        GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ProfilePage(
                  accessToFeed: true,
                  uid: author!.uid ?? '',
                ),
              ),
            );
          },
          child: Row(
            children: [
              // avatar picture
              ClipOval(
                child: SizedBox(
                  width: 35,
                  height: 35,
                  child: Image(
                    image: OptimizedCacheImageProvider(
                      author?.photoURL ?? 'http://www.gravatar.com/avatar/?d=mp',
                    ),
                    width: 70,
                    height: 70,
                    fit: BoxFit.cover,
                  ),
                ),
              ),

              const SizedBox(width: 8),

              // author name and time since
              Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // author name
                  Text(
                    author!.name,
                    style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 18),
                  ),
                  // time since
                  Text(
                    formatTime(review!.postedTime.millisecondsSinceEpoch),
                    style: TextStyle(
                      color: Theme.of(context).dividerColor,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const Spacer(),
        Row(
          children: [
            Container(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary.withOpacity(0.15),
                borderRadius: BorderRadius.circular(15),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.star, color: Colors.amber, size: 15),
                    const SizedBox(width: 5),
                    Text(review!.rating.toString()),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 5),
            // show menu with delete and edit option if user is the author
            if (currentUser?.uid == author?.uid)
              PopupMenuButton(
                icon: const Icon(Icons.more_vert),
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: "delete",
                    child: Text("Delete"),
                  ),
                ],
                onSelected: (value) async {
                  if (value == "delete") {
                    await showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text("Delete review"),
                        content: const Text("Are you sure you want to delete this review?"),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text("Cancel"),
                          ),
                          TextButton(
                            onPressed: () async {
                              await deleteReview(review!.reviewID);

                              Navigator.pop(context);
                            },
                            child: const Text("Delete"),
                          ),
                        ],
                      ),
                    );
                  }
                },
              ),
          ],
        )
      ],
    );
  }

  Widget buildMovieInfo(Movie movie) {
    return InkWell(
      onTap: () {
        Get.to(
          () => MoviePage(
            movie: SearchMovie(
              id: review!.movieID,
              title: movie.title,
              posterPath: movie.posterPath,
              releaseDate: movie.releaseDate,
              voteAverage: movie.voteAverage,
              overview: movie.overview,
              backdropPath: movie.backdropPath,
              popularity: movie.popularity,
            ),
          ),
        );
      },
      child: Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // movie poster
          movie.posterPath != null
              ? ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  clipBehavior: Clip.antiAlias,
                  child: SizedBox(
                    width: 80,
                    child: OptimizedCacheImage(
                      fit: BoxFit.contain,
                      imageUrl: "https://image.tmdb.org/t/p/w500/${movie.posterPath}",
                      width: 160,
                      errorWidget: (context, url, error) => const Icon(Icons.error),
                    ),
                  ),
                )
              : const SizedBox(
                  width: 80,
                  child: Icon(Icons.movie, size: 35),
                ),

          const SizedBox(width: 15),

          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // movie title
                Text(
                  movie.title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 18,
                  ),
                ),

                const SizedBox(height: 3),
                // movie rating
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.reviews, size: 13),
                    const SizedBox(width: 5),
                    Text(
                      "${movie.voteAverage.toStringAsPrecision(2)}/10",
                      style: const TextStyle(fontSize: 13),
                    ),
                  ],
                ),

                const SizedBox(height: 3),

                // description
                Text(
                  movie.overview,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 12, color: Theme.of(context).dividerColor),
                ),

                const SizedBox(height: 3),

                // year, length
                Text(
                  "${DateTime.parse(movie.releaseDate).year} | ${movie.runtime} min",
                  style: const TextStyle(fontSize: 12),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget buildRatings() {
    return Column(
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox.fromSize(
          size: const Size.fromHeight(50),
          child: Center(
            child: ListView(
              physics: const BouncingScrollPhysics(decelerationRate: ScrollDecelerationRate.fast),
              scrollDirection: Axis.horizontal,
              shrinkWrap: true,
              children: [
                buildRatingPill(review!.rating.toString(), "Rating", Icons.movie_creation_outlined),
                const SizedBox(width: 6),
                buildRatingPill(review!.actingRating.toString(), "Actors", Icons.person),
                const SizedBox(width: 6),
                buildRatingPill(review!.storyRating.toString(), "Story", Icons.menu_book_outlined),
                const SizedBox(width: 6),
                buildRatingPill(review!.lengthRating.toString(), "Length", Icons.timelapse_outlined),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget buildRatingPill(String rating, String title, IconData icon) {
    return Container(
      key: ValueKey(title),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary.withOpacity(0.10),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.max,
          children: [
            Icon(icon, color: Theme.of(context).dividerColor, size: 18),
            const SizedBox(width: 5),
            Column(
              key: ValueKey("column $title"),
              children: [
                Flexible(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.star, color: Colors.amber, size: 13),
                    const SizedBox(width: 2),
                    Text(
                      rating,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget buildLikesAndComments(Size size) {
    return Column(
      mainAxisSize: MainAxisSize.max,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // likes
            Tooltip(
              message: review!.likes.map((e) => e.name).join(", "),
              triggerMode: TooltipTriggerMode.tap,
              showDuration: const Duration(seconds: 5),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    onPressed: () {
                      if (review!.likes.any((element) => element.uid == widget.user!.uid)) {
                        // optimistically remove the like from the ui
                        setState(() {
                          review!.likes.removeWhere((element) => element.uid == widget.user!.uid);
                        });

                        // remove the like in the DB, if there is any error, we want to update the ui to show that it didn't work
                        removeLike().then((value) {
                          if (!value) {
                            setState(() {
                              review!.likes.add(widget.user!);
                            });
                          }
                        });
                      } else {
                        // add the like
                        // optimistically add the like to the ui
                        setState(() {
                          review!.likes.add(widget.user!);
                        });

                        // add the like in the DB, if there is any error, we want to update the ui to show that it didn't work
                        addLike().then((bool addedLike) {
                          if (!addedLike) {
                            setState(() {
                              review!.likes.removeWhere((element) => element.uid == widget.user!.uid);
                            });
                          }
                        });
                      }
                    },
                    style: IconButton.styleFrom(
                      visualDensity: VisualDensity.compact,
                      padding: const EdgeInsets.all(0),
                    ),
                    icon: Icon(
                      review!.likes.any((element) => element.uid == widget.user!.uid)
                          ? Icons.favorite
                          : Icons.favorite_border,
                      color: review!.likes.any((element) => element.uid == widget.user!.uid)
                          ? Colors.red
                          : Theme.of(context).dividerColor,
                    ),
                  ),
                  if (review!.likes.isEmpty)
                    Text(
                      "0",
                      style: TextStyle(
                        color: Theme.of(context).dividerColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  if (review!.likes.isNotEmpty && size.width > 360)
                    RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: "Liked by ",
                            style: TextStyle(
                              color: Theme.of(context).dividerColor,
                              fontSize: 12,
                            ),
                          ),
                          TextSpan(
                            text: review!.likes.first.name,
                            style: TextStyle(
                              color: Theme.of(context).dividerColor,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          if (review!.likes.length > 1) ...[
                            TextSpan(
                              text: " and ",
                              style: TextStyle(
                                color: Theme.of(context).dividerColor,
                                fontSize: 12,
                              ),
                            ),
                            TextSpan(
                              text: "${review!.likes.length - 1}",
                              style: TextStyle(
                                color: Theme.of(context).dividerColor,
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            TextSpan(
                              text: review!.likes.length > 2 ? " others" : " other",
                              style: TextStyle(
                                color: Theme.of(context).dividerColor,
                                fontSize: 12,
                              ),
                            ),
                          ]
                        ],
                      ),
                    ),
                  if (review!.likes.isNotEmpty && size.width <= 360)
                    Text(
                      "${review!.likes.length} likes",
                      style: TextStyle(
                        color: review!.likes.any((element) => element.uid == widget.user!.uid)
                            ? Colors.red
                            : Theme.of(context).dividerColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                ],
              ),
            ),
            const Spacer(),
            TextButton.icon(
              label: Text(
                (review!.comments.length +
                        review!.comments.fold(0, (previousValue, element) => previousValue + element.replies.length))
                    .toString(),
                style: TextStyle(
                  color: Theme.of(context).dividerColor,
                  fontSize: 12,
                ),
              ),
              onPressed: () {
                showDialog(
                    context: context,
                    builder: (context) {
                      return StatefulBuilder(builder: (context, setStateDialog) {
                        setStateDialogCallback = setStateDialog;
                        return Dialog(
                          insetPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 30),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(15),
                            child: CommentPage(
                              review: review!,
                              setStateCallback: () {
                                setState(() {});
                                setStateDialog(() {});
                              },
                              refreshData: refreshData,
                            ),
                          ),
                        );
                      });
                    });
              },
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 0),
                visualDensity: VisualDensity.compact,
              ),
              icon: Icon(Icons.mode_comment_outlined, color: Theme.of(context).dividerColor),
            ),
          ],
        ),
        if (review!.likes.isNotEmpty && size.width <= 360) ...[
          Padding(
            padding: const EdgeInsets.only(left: 8),
            child: Row(
              children: [
                // circle avatar of the last user who liked the review
                CircleAvatar(
                  radius: 9.7,
                  backgroundColor: Theme.of(context).colorScheme.onSurface.withOpacity(0.3),
                  child: CircleAvatar(
                    radius: 9,
                    backgroundImage: OptimizedCacheImageProvider(review!.likes.last.photoURL),
                  ),
                ),
                const SizedBox(width: 5),
                RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: "Liked by ",
                        style: TextStyle(
                          color: Theme.of(context).dividerColor,
                          fontSize: 12,
                        ),
                      ),
                      TextSpan(
                        text: review!.likes.first.name,
                        style: TextStyle(
                          color: Theme.of(context).dividerColor,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      if (review!.likes.length > 1) ...[
                        TextSpan(
                          text: " and ",
                          style: TextStyle(
                            color: Theme.of(context).dividerColor,
                            fontSize: 12,
                          ),
                        ),
                        TextSpan(
                          text: "${review!.likes.length - 1}",
                          style: TextStyle(
                            color: Theme.of(context).dividerColor,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        TextSpan(
                          text: review!.likes.length > 2 ? " others" : " other",
                          style: TextStyle(
                            color: Theme.of(context).dividerColor,
                            fontSize: 12,
                          ),
                        ),
                      ]
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 5),
        ],

        // comments details
        if (review!.comments.isNotEmpty)
          GestureDetector(
            onTap: () {
              showDialog(
                  context: context,
                  builder: (context) {
                    return StatefulBuilder(builder: (context, setStateDialog) {
                      setStateDialogCallback = setStateDialog;
                      return Dialog(
                        insetPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 30),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(15),
                          child: CommentPage(
                            review: review!,
                            setStateCallback: () {
                              setState(() {});
                              setStateDialog(() {});
                            },
                            refreshData: refreshData,
                          ),
                        ),
                      );
                    });
                  });
            },
            child: Padding(
              padding: const EdgeInsets.only(left: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // view all ... comments
                  Text(
                    "View all ${review!.comments.length + review!.comments.fold(0, (prev, next) => prev + next.replies.length)} comments",
                    style: TextStyle(
                      color: Theme.of(context).dividerColor,
                      fontSize: 14,
                    ),
                  ),
                  // show the last 2 comments
                  ...review!.comments
                      .take(2)
                      .map((e) => Padding(
                            padding: const EdgeInsets.fromLTRB(0, 5, 0, 0),
                            child: Row(
                              children: [
                                Text(
                                  e.user.name,
                                  style: TextStyle(
                                    color: Theme.of(context).dividerColor,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(width: 5),
                                Text(
                                  e.comment,
                                  style: TextStyle(
                                    color: Theme.of(context).dividerColor,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ))
                      .toList(),
                ],
              ),
            ),
          ),
      ],
    );
  }

  Widget buildSkeletonCard() {
    return Card(
      elevation: 0.5,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
        side: BorderSide(
          color: Colors.grey.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
        child: SkeletonItem(
            child: Column(
          children: [
            const SizedBox(height: 8),

            // header
            Row(
              children: [
                const SkeletonAvatar(
                  style: SkeletonAvatarStyle(
                    shape: BoxShape.circle,
                    width: 35,
                    height: 35,
                  ),
                ),
                const SizedBox(width: 8),
                SkeletonParagraph(
                  style: SkeletonParagraphStyle(
                      lines: 2,
                      spacing: 6,
                      lineStyle: SkeletonLineStyle(
                        randomLength: true,
                        height: 10,
                        width: 100,
                        borderRadius: BorderRadius.circular(8),
                        minLength: MediaQuery.of(context).size.width / 6,
                        maxLength: MediaQuery.of(context).size.width / 3,
                      )),
                ),
                const Spacer(),
                SkeletonLine(
                  style: SkeletonLineStyle(height: 30, width: 64, borderRadius: BorderRadius.circular(15)),
                )
              ],
            ),

            const SizedBox(height: 10),

            // review text
            SkeletonParagraph(
              style: SkeletonParagraphStyle(
                  lines: 3,
                  spacing: 6,
                  lineStyle: SkeletonLineStyle(
                    // randomLength: true,
                    height: 13,
                    borderRadius: BorderRadius.circular(8),
                    minLength: MediaQuery.of(context).size.width / 2,
                  )),
            ),

            const SizedBox(height: 10),

            // movie info
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  // movie poster
                  SkeletonAvatar(
                    style: SkeletonAvatarStyle(
                      width: 80,
                      height: 120,
                      borderRadius: BorderRadius.circular(8),
                      minHeight: MediaQuery.of(context).size.height / 8,
                    ),
                  ),

                  const SizedBox(width: 15),

                  Expanded(
                    child: Column(
                      children: [
                        // movie title
                        SkeletonParagraph(
                          style: SkeletonParagraphStyle(
                              lines: 1,
                              spacing: 6,
                              lineStyle: SkeletonLineStyle(
                                randomLength: true,
                                height: 18,
                                borderRadius: BorderRadius.circular(8),
                                minLength: MediaQuery.of(context).size.width / 2,
                              )),
                        ),

                        const SizedBox(height: 5),

                        // movie description
                        SkeletonParagraph(
                          style: SkeletonParagraphStyle(
                              lines: 4,
                              spacing: 6,
                              lineStyle: SkeletonLineStyle(
                                randomLength: true,
                                height: 10,
                                borderRadius: BorderRadius.circular(8),
                                minLength: MediaQuery.of(context).size.width / 2,
                              )),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 10),

            // review content
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // rating
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SkeletonLine(
                      style: SkeletonLineStyle(height: 40, width: 64, borderRadius: BorderRadius.circular(15)),
                    ),
                    const SizedBox(width: 6),
                    SkeletonLine(
                      style: SkeletonLineStyle(height: 40, width: 64, borderRadius: BorderRadius.circular(15)),
                    ),
                    const SizedBox(width: 6),
                    SkeletonLine(
                      style: SkeletonLineStyle(height: 40, width: 64, borderRadius: BorderRadius.circular(15)),
                    ),
                    const SizedBox(width: 6),
                    SkeletonLine(
                      style: SkeletonLineStyle(height: 40, width: 64, borderRadius: BorderRadius.circular(15)),
                    ),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 10),
            Row(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                SkeletonAvatar(
                    style: SkeletonAvatarStyle(width: 40, height: 40, borderRadius: BorderRadius.circular(20))),
                SkeletonAvatar(
                    style: SkeletonAvatarStyle(width: 40, height: 40, borderRadius: BorderRadius.circular(20))),
              ],
            ),
            SkeletonParagraph(
              style: SkeletonParagraphStyle(
                  lines: 1,
                  spacing: 6,
                  lineStyle: SkeletonLineStyle(
                    randomLength: true,
                    height: 13,
                    borderRadius: BorderRadius.circular(8),
                    minLength: MediaQuery.of(context).size.width / 2,
                    // maxLength: MediaQuery.of(context).size.width / 3,
                  )),
            ),
          ],
        )),
      ),
    );
  }
}
