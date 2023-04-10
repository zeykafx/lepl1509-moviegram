import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
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

  const ReviewCard(
      {super.key,
      required this.id,
      required this.data,
      required this.user,
      this.showRatingPill = false});

  @override
  _ReviewCardState createState() => _ReviewCardState();
}

class _ReviewCardState extends State<ReviewCard>
    with AutomaticKeepAliveClientMixin {
  FirebaseFirestore db = FirebaseFirestore.instance;
  Review? review;
  UserProfile? author;
  User? currentUser = FirebaseAuth.instance.currentUser;
  int nbComments = 0;

  TextEditingController commentController = TextEditingController();

  bool showRatingPill = false;

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
        getAuthor();
      }
    });
  }

  Future<void> getAuthor() async {
    DocumentSnapshot<Map<String, dynamic>> value =
        await db.collection('users').doc(review?.userID).get();
    if (value != null && mounted) {
      setState(() {
        author = UserProfile.fromMap(value.data()!);
      });
    } else {
      print(
          "failed to get user profile in review card, maybe the card was disposed before the future finished");
    }
    var commentsVal = await db
        .collection('comments')
        .doc(widget.id)
        .collection('comments')
        .get();
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

  @override
  Widget build(BuildContext context) {
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
                                style: TextStyle(fontSize: 18),
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
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: buildMovieInfo(movie!),
                                ),
                              ),

                              if (showRatingPill) ...[
                                const SizedBox(height: 10),

                                // ratings bar
                                buildRatings(),
                              ],

                              if (!showRatingPill) ...[
                                const SizedBox(height: 5),
                                GestureDetector(
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
                              ],

                              buildLikesAndComments(),
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
                    // child: Image(
                    //   image: ResizeImage(
                    //     NetworkImage(
                    //       author?.photoURL ?? 'http://www.gravatar.com/avatar/?d=mp',
                    //     ),
                    //     width: 70,
                    //     height: 70,
                    //   ),
                    // ),
                    child: Image(
                      image: OptimizedCacheImageProvider(
                        author?.photoURL ??
                            'http://www.gravatar.com/avatar/?d=mp',
                      ),
                    )),
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
                    style: const TextStyle(
                        fontWeight: FontWeight.w600, fontSize: 18),
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
                      imageUrl:
                          "https://image.tmdb.org/t/p/w500/${movie.posterPath}",
                      width: 160,
                      errorWidget: (context, url, error) =>
                          const Icon(Icons.error),
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
                Text(movie.title,
                    style: const TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: 20,
                    )),

                const SizedBox(height: 3),
                // movie rating
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.reviews, size: 15),
                    const SizedBox(width: 5),
                    Text(
                      "${movie.voteAverage.toStringAsPrecision(2)}/10",
                      style: const TextStyle(fontSize: 15),
                    ),
                  ],
                ),

                const SizedBox(height: 3),

                // description
                Text(
                  movie.overview,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                      fontSize: 15, color: Theme.of(context).dividerColor),
                ),

                const SizedBox(height: 3),

                // year, length
                Text(
                  "${DateTime.parse(movie.releaseDate).year} | ${movie.runtime} min",
                  style: const TextStyle(fontSize: 15),
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
          child: ListView(
            physics: const BouncingScrollPhysics(
                decelerationRate: ScrollDecelerationRate.fast),
            scrollDirection: Axis.horizontal,
            shrinkWrap: true,
            children: [
              buildRatingPill(review!.rating.toString(), "Rating",
                  Icons.movie_creation_outlined),
              const SizedBox(width: 6),
              buildRatingPill(
                  review!.actingRating.toString(), "Actors", Icons.person),
              const SizedBox(width: 6),
              buildRatingPill(review!.storyRating.toString(), "Story",
                  Icons.menu_book_outlined),
              const SizedBox(width: 6),
              buildRatingPill(review!.lengthRating.toString(), "Length",
                  Icons.timelapse_outlined),
            ],
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

  Widget buildLikesAndComments() {
    return Column(
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // likes
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    TextButton.icon(
                      onPressed: () {
                        if (review!.likes.any(
                            (element) => element.uid == widget.user!.uid)) {
                          // optimistically remove the like from the ui
                          setState(() {
                            review!.likes.removeWhere(
                                (element) => element.uid == widget.user!.uid);
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
                                review!.likes.removeWhere((element) =>
                                    element.uid == widget.user!.uid);
                              });
                            }
                          });
                        }
                      },
                      icon: Icon(
                        review!.likes.any(
                                (element) => element.uid == widget.user!.uid)
                            ? Icons.favorite
                            : Icons.favorite_border,
                        color: review!.likes.any(
                                (element) => element.uid == widget.user!.uid)
                            ? Colors.red
                            : Theme.of(context).dividerColor,
                      ),
                      label: Text(
                        review!.likes.length.toString(),
                        style: TextStyle(
                          color: review!.likes.any(
                                  (element) => element.uid == widget.user!.uid)
                              ? Colors.red
                              : Theme.of(context).dividerColor,
                          fontSize: 15,
                        ),
                      ),
                    ),
                    if (review!.likes.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.fromLTRB(10, 0, 0, 0),
                        child: Tooltip(
                          message: review!.likes.map((e) => e.name).join(", "),
                          triggerMode: TooltipTriggerMode.tap,
                          showDuration: const Duration(seconds: 5),
                          child: RichText(
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
                                    text: review!.likes.length > 2
                                        ? " others"
                                        : " other",
                                    style: TextStyle(
                                      color: Theme.of(context).dividerColor,
                                      fontSize: 12,
                                    ),
                                  ),
                                ]
                              ],
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ),
            const Spacer(),
            TextButton.icon(
              label: Text(review!.comments.length.toString(),
                  style: TextStyle(color: Theme.of(context).dividerColor)),
              onPressed: () {
                showDialog(
                    context: context,
                    builder: (context) {
                      return Dialog(
                        insetPadding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 30),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(15),
                          child: CommentPage(
                            review: review!,
                            setStateCallback: () => setState(() {}),
                          ),
                        ),
                      );
                    });
              },
              icon: Icon(Icons.mode_comment_outlined,
                  color: Theme.of(context).dividerColor),
            ),
          ],
        ),
        SizedBox(height: review!.likes.isNotEmpty ? 5 : 0),
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
                  style: SkeletonLineStyle(
                      height: 30,
                      width: 64,
                      borderRadius: BorderRadius.circular(15)),
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
                                minLength:
                                    MediaQuery.of(context).size.width / 2,
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
                                minLength:
                                    MediaQuery.of(context).size.width / 2,
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
                      style: SkeletonLineStyle(
                          height: 40,
                          width: 64,
                          borderRadius: BorderRadius.circular(15)),
                    ),
                    const SizedBox(width: 6),
                    SkeletonLine(
                      style: SkeletonLineStyle(
                          height: 40,
                          width: 64,
                          borderRadius: BorderRadius.circular(15)),
                    ),
                    const SizedBox(width: 6),
                    SkeletonLine(
                      style: SkeletonLineStyle(
                          height: 40,
                          width: 64,
                          borderRadius: BorderRadius.circular(15)),
                    ),
                    const SizedBox(width: 6),
                    SkeletonLine(
                      style: SkeletonLineStyle(
                          height: 40,
                          width: 64,
                          borderRadius: BorderRadius.circular(15)),
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
                    style: SkeletonAvatarStyle(
                        width: 40,
                        height: 40,
                        borderRadius: BorderRadius.circular(20))),
                SkeletonAvatar(
                    style: SkeletonAvatarStyle(
                        width: 40,
                        height: 40,
                        borderRadius: BorderRadius.circular(20))),
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
