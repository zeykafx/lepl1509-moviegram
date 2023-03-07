import 'package:card_swiper/card_swiper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

class MoviePage extends StatefulWidget {
  const MoviePage({super.key});

  @override
  _MoviePageState createState() => _MoviePageState();
}

class _MoviePageState extends State<MoviePage> {
  bool isFocused = false;

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
        appBar: AppBar(title: const Text('Movie')),
        body: Column(
          children: [
            ElevatedButton(
                onPressed: () {
                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    isDismissible: false,
                    builder: (context) {
                      return GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
                        child: Padding(
                          padding: EdgeInsets.only(
                              bottom: MediaQuery.of(context).viewInsets.bottom),
                          child: SizedBox(
                              width: size.width,
                              height: size.height < 800
                                  ? size.height * 0.60
                                  : size.height * 0.40,
                              child: BsbForm()),
                        ),
                      );
                    },
                  );
                },
                child: const Text("Show modal sheet"))
          ],
        ));
  }
}

class BsbForm extends StatefulWidget {
  BsbForm({Key? key}) : super(key: key);

  @override
  State<BsbForm> createState() => _BsbFormState();
}

class _BsbFormState extends State<BsbForm> {
  final commentKey = GlobalKey<FormState>();

  String comment = "";
  double rating = 0;
  double storyRating = 0;
  double lengthRating = 0;
  double actingRating = 0;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        mainAxisSize: MainAxisSize.max,
        children: [
          Align(
            alignment: Alignment.topRight,
            child: TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
          ),
          Expanded(
            child: Form(
              key: commentKey,
              child: Scaffold(
                backgroundColor: Colors.transparent,
                body: Swiper(
                  itemCount: 4,
                  pagination: SwiperPagination(
                    builder: DotSwiperPaginationBuilder(
                        space: 4,
                        size: 5,
                        activeSize: 6,
                        activeColor:
                            Theme.of(context).colorScheme.primary.withOpacity(0.5),
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
                      disableColor:
                          Theme.of(context).colorScheme.onSurface.withOpacity(0.1),
                      color: Theme.of(context).colorScheme.onSurface.withOpacity(0.8)),
                  loop: false,
                  itemBuilder: (BuildContext context, int index) {
                    switch (index) {
                      case 0:
                        return buildOverallRating();
                      case 1:
                        return buildCommentRating();
                      case 2:
                        return buildLengthAndActorRating();
                      case 3:
                        return buildSubmitPage();
                      default:
                        return buildOverallRating();
                    }
                  },
                ),
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
            RatingBar(
                initialRating: 0,
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
                    rating = value;
                  });
                }),
            const SizedBox(height: 20),
            const Text("How engaging was the story?"),
            RatingBar(
                initialRating: 0,
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
                    actingRating = value;
                  });
                }),
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
            TextFormField(
              keyboardType: TextInputType.multiline,
              maxLines: null,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Comment',
                hintText: 'Enter your comment',
              ),
              minLines: 3,
              validator: (value) {
                print(value);
                print(value!.isEmpty);
                return value!.isEmpty ? 'Comment can\'t be empty' : null;
              },
              onSaved: (value) => comment = value!.trim(),
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
            const Text("How satisfied were you with the film’s duration and cast?"),
            const SizedBox(height: 10),
            const Text("Cast and characters"),
            RatingBar(
                initialRating: 0,
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
                    actingRating = value;
                  });
                }),
            const SizedBox(height: 10),
            const Text("Duration and pace"),
            RatingBar(
                initialRating: 0,
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
                    lengthRating = value;
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
            const Text("You can edit or delete it later if you change your mind."),
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
                onPressed: () {
                  final form = commentKey.currentState;
                  if (form!.validate() && comment != "") {
                    form.save();
                    print("Comment: $comment");
                    print("Rating: $rating");
                    print("Acting Rating: $actingRating");
                    print("Length Rating: $lengthRating");
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
