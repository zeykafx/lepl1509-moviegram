import 'package:card_swiper/card_swiper.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:get/get.dart';
import 'package:projet_lepl1509_groupe_17/models/movies.dart';

class BsbForm extends StatefulWidget {
  final Movie movie;
  BsbForm({Key? key, required this.movie}) : super(key: key);

  @override
  State<BsbForm> createState() => _BsbFormState();
}

class _BsbFormState extends State<BsbForm> {
  final ReviewPagesController reviewPagesController =
      Get.put(ReviewPagesController());

  String comment = "";

  TextEditingController commentController = TextEditingController();
  bool _validate = false;

  @override
  void dispose() {
    commentController.dispose();
    // reset the controller's values
    reviewPagesController.actingRating.value = 0;
    reviewPagesController.lengthRating.value = 0;
    reviewPagesController.storyRating.value = 0;
    reviewPagesController.rating.value = 0;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        children: [
          Align(
            alignment: Alignment.topRight,
            child: TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
          ),
          Expanded(
            child: Scaffold(
              resizeToAvoidBottomInset: false,
              backgroundColor: Colors.transparent,
              body: Swiper(
                itemCount: 4,
                pagination: SwiperPagination(
                  builder: DotSwiperPaginationBuilder(
                      space: 4,
                      size: 5,
                      activeSize: 6,
                      activeColor: Theme.of(context)
                          .colorScheme
                          .primary
                          .withOpacity(0.5),
                      color: Theme.of(context)
                          .colorScheme
                          .surfaceVariant
                          .withOpacity(0.5)),
                ),
                control: SwiperControl(
                    size: 15,
                    padding: const EdgeInsets.all(5),
                    iconNext: Icons.arrow_forward_ios,
                    iconPrevious: Icons.arrow_back_ios,
                    disableColor: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withOpacity(0.1),
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withOpacity(0.8)),
                loop: false,
                itemBuilder: (BuildContext context, int index) {
                  switch (index) {
                    case 0:
                      return buildOverallRating();
                    case 1:
                      return buildLengthAndActorRating();
                    case 2:
                      return buildCommentRating();
                    case 3:
                      commentController.text.isEmpty
                          ? _validate = true
                          : _validate = false;
                      if (comment == "") {
                        // show error snackbar after 100 milliseconds
                        Future.delayed(const Duration(milliseconds: 100), () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text("Please enter a comment"),
                            ),
                          );
                        });
                      }
                      return buildSubmitPage();
                    default:
                      return buildOverallRating();
                  }
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildOverallRating() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 30.0, vertical: 8.0),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Rate this movie",
                style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold)),
            const Text("How would you rate this movie?"),
            const SizedBox(height: 10),
            Obx(() => RatingBar(
                initialRating: reviewPagesController.rating.value,
                direction: Axis.horizontal,
                allowHalfRating: true,
                itemCount: 5,
                ratingWidget: RatingWidget(
                    full: const Icon(Icons.star, color: Colors.orangeAccent),
                    half: const Icon(
                      Icons.star_half,
                      color: Colors.orangeAccent,
                    ),
                    empty: const Icon(
                      Icons.star_outline,
                      color: Colors.orangeAccent,
                    )),
                onRatingUpdate: (value) {
                  setState(() {
                    reviewPagesController.rating.value = value;
                  });
                })),
            const SizedBox(height: 20),
            const Text("How engaging was the story?"),
            Obx(
              () => RatingBar(
                  initialRating: reviewPagesController.storyRating.value,
                  direction: Axis.horizontal,
                  allowHalfRating: true,
                  itemCount: 5,
                  ratingWidget: RatingWidget(
                      full: const Icon(Icons.star, color: Colors.orangeAccent),
                      half: const Icon(
                        Icons.star_half,
                        color: Colors.orangeAccent,
                      ),
                      empty: const Icon(
                        Icons.star_outline,
                        color: Colors.orangeAccent,
                      )),
                  onRatingUpdate: (value) {
                    setState(() {
                      reviewPagesController.storyRating.value = value;
                    });
                  }),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildCommentRating() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 30.0, vertical: 8.0),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Share your opinion",
                style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold)),
            const Text("Write a review for this movie"),
            const SizedBox(height: 15),
            TextField(
              controller: commentController,
              keyboardType: TextInputType.multiline,
              maxLines: null,
              decoration: InputDecoration(
                border: const OutlineInputBorder(),
                labelText: 'Comment',
                hintText: 'Enter your comment',
                errorText: _validate ? 'Comment Can\'t Be Empty' : null,
              ),
              minLines: 3,
              onChanged: (value) {
                setState(() {
                  comment = value;
                });
              },
              autofocus: false,
              onTapOutside: (ev) => FocusScope.of(context).unfocus(),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildLengthAndActorRating() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 30.0, vertical: 8.0),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Share your feedback (optional)",
                style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold)),
            const Text(
                "How satisfied were you with the film’s duration and cast?"),
            const SizedBox(height: 10),
            const Text("Cast and characters"),
            Obx(
              () => RatingBar(
                  initialRating: reviewPagesController.actingRating.value,
                  direction: Axis.horizontal,
                  allowHalfRating: true,
                  itemCount: 5,
                  ratingWidget: RatingWidget(
                      full: const Icon(Icons.star, color: Colors.orangeAccent),
                      half: const Icon(
                        Icons.star_half,
                        color: Colors.orangeAccent,
                      ),
                      empty: const Icon(
                        Icons.star_outline,
                        color: Colors.orangeAccent,
                      )),
                  onRatingUpdate: (value) {
                    setState(() {
                      reviewPagesController.actingRating.value = value;
                    });
                  }),
            ),
            const SizedBox(height: 10),
            const Text("Duration and pace"),
            RatingBar(
                initialRating: reviewPagesController.lengthRating.value,
                direction: Axis.horizontal,
                allowHalfRating: true,
                itemCount: 5,
                ratingWidget: RatingWidget(
                    full: const Icon(Icons.star, color: Colors.orangeAccent),
                    half: const Icon(
                      Icons.star_half,
                      color: Colors.orangeAccent,
                    ),
                    empty: const Icon(
                      Icons.star_outline,
                      color: Colors.orangeAccent,
                    )),
                onRatingUpdate: (value) {
                  setState(() {
                    reviewPagesController.lengthRating.value = value;
                  });
                }),
          ],
        ),
      ),
    );
  }

  Widget buildSubmitPage() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 30.0, vertical: 8.0),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Ready to publish your review?",
                style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold)),
            const Text(
                "You can edit or delete it later if you change your mind."),
            const SizedBox(height: 50),
            SizedBox(
              width: double.infinity,
              child: TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text("Cancel"),
              ),
            ),
            SizedBox(
              width: double.infinity,
              child: FilledButton.tonal(
                onPressed: () async {
                  setState(() {
                    commentController.text.isEmpty
                        ? _validate = true
                        : _validate = false;
                  });
                  if (comment != "") {
                    // first create the document in firestore/posts/uid/
                    await FirebaseFirestore.instance
                        .collection("posts")
                        .doc(FirebaseAuth.instance.currentUser?.uid)
                        .set({
                      '_': '_'
                    }); // dummy value, will not be read or written to

                    // then add a subcollection at firestore/posts/uid/userPosts
                    var val = await FirebaseFirestore.instance
                        .collection('posts')
                        .doc(FirebaseAuth.instance.currentUser?.uid)
                        .collection("userPosts")
                        .add({
                      'username':
                          FirebaseAuth.instance.currentUser?.displayName ??
                              "Anonymous",
                      'comment': comment,
                      'rating': reviewPagesController.rating.value,
                      'actingRating': reviewPagesController.actingRating.value,
                      'lengthRating': reviewPagesController.lengthRating.value,
                      'storyRating': reviewPagesController.storyRating.value,
                      "userID": FirebaseAuth.instance.currentUser!.uid,
                      "movieID": widget.movie.id,
                      "timestamp": DateTime.now().millisecondsSinceEpoch,
                      "likes": [],
                      "comments": []
                    });

                    // then create the comments subcollection for this post
                    await FirebaseFirestore.instance
                        .collection("comments")
                        .doc(val.id)
                        .set({
                      '_': '_'
                    }); // dummy value, will not be read or written to

                    Get.back();

                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                      behavior: SnackBarBehavior.floating,
                      margin: EdgeInsets.all(10),
                      content: Text("Submitted successfully!"),
                    ));
                  } else {
                    // show an error message
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                      behavior: SnackBarBehavior.floating,
                      margin: EdgeInsets.all(10),
                      content: Text("Fill in all the required fields"),
                    ));
                  }
                },
                child: const Text("Submit"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Controller used to store the rating values in a more persistent way
class ReviewPagesController extends GetxController {
  RxDouble rating = 0.0.obs;
  RxDouble storyRating = 0.0.obs;
  RxDouble lengthRating = 0.0.obs;
  RxDouble actingRating = 0.0.obs;
}
