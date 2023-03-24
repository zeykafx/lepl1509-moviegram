import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import 'package:projet_lepl1509_groupe_17/models/movies.dart';
import 'package:projet_lepl1509_groupe_17/models/review.dart';
import 'package:projet_lepl1509_groupe_17/models/search_movie.dart';
import 'package:projet_lepl1509_groupe_17/models/user_profile.dart';
import 'package:projet_lepl1509_groupe_17/pages/movie/movie_page.dart';
import 'package:skeletons/skeletons.dart';
import 'package:time_formatter/time_formatter.dart';

class ReviewCardPP extends StatefulWidget {
  final String id;
  final Map<String, dynamic> data;
  final UserProfile? user;

  const ReviewCardPP(
      {super.key, required this.id, required this.data, required this.user});

  @override
  _ReviewCardPPState createState() => _ReviewCardPPState();
}

class _ReviewCardPPState extends State<ReviewCardPP>
    with AutomaticKeepAliveClientMixin {
  FirebaseFirestore db = FirebaseFirestore.instance;
  Review? review;
  UserProfile? author;
  User? currentUser = FirebaseAuth.instance.currentUser;

  TextEditingController commentController = TextEditingController();

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    Review.fromJson(widget.id, widget.data).then((value) {
      setState(() {
        review = value;
      });
      getAuthor();
    });
    super.initState();
  }

  Future<void> getAuthor() async {
    DocumentSnapshot<Map<String, dynamic>> value =
    await db.collection('users').doc(review?.userID).get();
    if (value != null) {
      setState(() {
        author = UserProfile.fromMap(value.data()!);
      });
    } else {
      print("failed to get user profile");
    }
  }

  Future<bool> addLike() async {
    try {
      await FirebaseFirestore.instance
          .collection("reviews")
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
          .collection("reviews")
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

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return review != null
        ? FutureBuilder(
        future: Movie.getMovieDetails(review!.movieID),
        builder: (context, snapshot) {
          Movie? movie = snapshot.data;
          return snapshot.hasData && author != null
              ? Card(
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
                  vertical: 10, horizontal: 15),
              child: Column(
                mainAxisSize: MainAxisSize.max,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 8),

                  // header
                  buildHeader(),

                  const SizedBox(height: 13),

                  // movie card, on which you can click
                  buildMovieInfo(movie!),

                  const SizedBox(height: 10),

                  Divider(
                    indent: 20,
                    endIndent: 20,
                    thickness: 0.8,
                    color: Theme.of(context)
                        .dividerColor
                        .withOpacity(0.3),
                  ),

                  const SizedBox(height: 10),

                  // review content
                  buildComment(),

                  const SizedBox(height: 10),

                  buildLikesAndComments(),
                ],
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
        // avatar picture
        ClipOval(
          child: Image.network(
            author?.photoURL ?? 'http://www.gravatar.com/avatar/?d=mp',
            width: 35,
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
            child: Image.network(
              "https://image.tmdb.org/t/p/w500${movie.posterPath}",
              width: 80,
              fit: BoxFit.contain,
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

  Widget buildComment() {
    return Column(
      mainAxisSize: MainAxisSize.min,
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
        const SizedBox(height: 15),
        Text(
          review!.comment,
          style: TextStyle(fontSize: 18, color: Theme.of(context).dividerColor),
        ),
      ],
    );
  }

  Widget buildRatingPill(String rating, String title, IconData icon) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary.withOpacity(0.10),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        child: Row(
          children: [
            Icon(icon, color: Theme.of(context).dividerColor, size: 20),
            const SizedBox(width: 7),
            Column(
              children: [
                Text(title,
                    style: const TextStyle(
                        fontSize: 13, fontWeight: FontWeight.w500)),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.star, color: Colors.amber, size: 15),
                    const SizedBox(width: 2),
                    Text(rating),
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
              onPressed: () {},
              icon: Icon(Icons.mode_comment_outlined,
                  color: Theme.of(context).dividerColor),
            ),
          ],
        ),
        SizedBox(height: review!.likes.isNotEmpty ? 5 : 0),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Row(
            children: [
              ClipOval(
                child: Image.network(
                  currentUser?.photoURL != null
                      ? currentUser!.photoURL!
                      : 'http://www.gravatar.com/avatar/?d=mp',
                  width: 35,
                  height: 35,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: TextField(
                  controller: commentController,
                  decoration: InputDecoration(
                    hintText: "Add a comment...",
                    hintStyle: TextStyle(color: Theme.of(context).dividerColor),
                    border: InputBorder.none,
                  ),
                ),
              ),
            ],
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
                      style: SkeletonLineStyle(
                          height: 30,
                          width: 64,
                          borderRadius: BorderRadius.circular(15)),
                    )
                  ],
                ),

                const SizedBox(height: 13),

                // movie info
                Row(
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

                const SizedBox(height: 10),

                Divider(
                  indent: 20,
                  endIndent: 20,
                  thickness: 0.8,
                  color: Theme.of(context).dividerColor.withOpacity(0.3),
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
                  ],
                ),

                const SizedBox(height: 10),
                Row(
                  mainAxisSize: MainAxisSize.min,
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
                const SizedBox(height: 10),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const SkeletonAvatar(
                      style: SkeletonAvatarStyle(
                        shape: BoxShape.circle,
                        width: 35,
                        height: 35,
                      ),
                    ),
                    const SizedBox(width: 8),
                    SkeletonAvatar(
                        style: SkeletonAvatarStyle(
                            width: MediaQuery.of(context).size.width / 3,
                            height: 30)),
                  ],
                ),
              ],
            )),
      ),
    );
  }
}
