import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

class CreateReviewPage extends StatefulWidget {
  const CreateReviewPage({super.key});

  @override
  _CreateReviewPageState createState() => _CreateReviewPageState();
}

class _CreateReviewPageState extends State<CreateReviewPage> {
  final _formKey = GlobalKey<FormState>();

  String title = "", comment = "", posterUrl = "";
  int dateTimestamp = DateTime.now().millisecondsSinceEpoch;
  List<String> actors = [];
  int lengthMin = 0;
  double rating = 0;
  TextEditingController dateCtl = TextEditingController();

  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Create a Review'),
        ),
        body: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Center(
              child: Column(
            children: [
              const Text("Create a Review & Share your opinion!",
                  style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold)),
              const Text("Enter the movie/series information below, and rate it!",
                  style: TextStyle(fontSize: 18)),
              const Padding(padding: EdgeInsets.all(10.0)),
              Expanded(
                child: Form(
                    key: _formKey,
                    child: Container(
                      constraints: const BoxConstraints(maxWidth: 550),
                      child: ListView(
                        children: [
                          // movie title
                          const Padding(
                            padding: EdgeInsets.fromLTRB(0, 0, 0, 5),
                            child: Text("Enter the title"),
                          ),
                          TextFormField(
                            keyboardType: TextInputType.text,
                            decoration: const InputDecoration(
                              border: OutlineInputBorder(),
                              labelText: "Title",
                              hintText: "Enter the title",
                            ),
                            validator: (value) {
                              return value!.isEmpty ? 'Please enter the title' : null;
                            },
                            onSaved: (value) {
                              title = value!.trim();
                            },
                          ),
                          const Padding(padding: EdgeInsets.all(10.0)),

                          const Padding(
                            padding: EdgeInsets.fromLTRB(0, 0, 0, 5),
                            child: Text("Enter your rating out of 5 stars"),
                          ),
                          RatingBar(
                              initialRating: 0,
                              direction: Axis.horizontal,
                              allowHalfRating: true,
                              itemCount: 5,
                              ratingWidget: RatingWidget(
                                  full:
                                      const Icon(Icons.star, color: Colors.orangeAccent),
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
                          const Padding(padding: EdgeInsets.all(10.0)),

                          const Padding(
                            padding: EdgeInsets.fromLTRB(0, 0, 0, 5),
                            child: Text("Enter your comment/review of the movie/series"),
                          ),
                          TextFormField(
                            keyboardType: TextInputType.multiline,
                            maxLines: null,
                            decoration: const InputDecoration(
                              border: OutlineInputBorder(),
                              labelText: 'Comment',
                              hintText: 'Enter your comment',
                            ),
                            validator: (value) =>
                                value!.isEmpty ? 'Comment can\'t be empty' : null,
                            onSaved: (value) => comment = value!.trim(),
                          ),
                          const Padding(padding: EdgeInsets.all(10.0)),

                          const Padding(
                            padding: EdgeInsets.fromLTRB(0, 0, 0, 5),
                            child: Text("Enter the actors that played"),
                          ),
                          TextFormField(
                            keyboardType: TextInputType.text,
                            decoration: const InputDecoration(
                              border: OutlineInputBorder(),
                              labelText: "Actors",
                              hintText:
                                  "Separate actors with a comma, e.g.: John Doe, Jane Doe",
                            ),
                            validator: (value) {
                              return value!.isEmpty
                                  ? 'Actors Title can\'t be empty'
                                  : null;
                            },
                            onSaved: (value) {
                              actors = value!.split(',').map((e) => e.trim()).toList();
                            },
                          ),
                          const Padding(padding: EdgeInsets.all(10.0)),

                          // TextFormField(
                          //   keyboardType: TextInputType.url,
                          //   decoration: const InputDecoration(
                          //     border: OutlineInputBorder(),
                          //     labelText: "Movie Poster URL",
                          //   ),
                          //   validator: (value) {
                          //     return value!.isEmpty ? 'Movie Poster URL can\'t be empty' : null;
                          //   },
                          //   onSaved: (value) {
                          //     moviePosterUrl = value!.trim();
                          //   },
                          // ),
                          // const Padding(padding: EdgeInsets.all(10.0)),

                          const Padding(
                            padding: EdgeInsets.fromLTRB(0, 0, 0, 5),
                            child: Text("Enter length in minutes"),
                          ),
                          TextFormField(
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              border: OutlineInputBorder(),
                              labelText: "Length in minutes",
                              hintText: "Enter the length in minutes",
                            ),
                            validator: (value) {
                              return value!.isEmpty
                                  ? 'Length in minutes can\'t be empty'
                                  : null;
                            },
                            onSaved: (value) {
                              lengthMin = int.parse(value!);
                            },
                          ),
                          const Padding(padding: EdgeInsets.all(10.0)),

                          const Padding(
                            padding: EdgeInsets.fromLTRB(0, 0, 0, 5),
                            child: Text("Enter the release date"),
                          ),
                          TextFormField(
                            controller: dateCtl,
                            keyboardType: TextInputType.none,
                            onTap: () {
                              showDatePicker(
                                context: context,
                                initialDate: DateTime.now(),
                                firstDate: DateTime(1900),
                                lastDate: DateTime.now(),
                              ).then((value) {
                                if (value != null) {
                                  setState(() {
                                    dateTimestamp = value.millisecondsSinceEpoch;
                                    // extract the date part only
                                    dateCtl.text =
                                        value.toIso8601String().substring(0, 10);
                                  });
                                }
                              });
                            },
                            decoration: const InputDecoration(
                                prefixIcon: Icon(Icons.calendar_month),
                                border: OutlineInputBorder(),
                                labelText: 'Release Date'),
                            validator: (value) =>
                                value!.isEmpty ? 'Please enter the release date' : null,
                            onSaved: (value) => dateTimestamp =
                                DateTime.parse(value!).millisecondsSinceEpoch,
                          ),
                          const Padding(padding: EdgeInsets.all(10.0)),

                          buildSubmitButtons(),
                        ],
                      ),
                    )),
              ),
            ],
          )),
        ));
  }

  Widget buildSubmitButtons() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    } else {
      return SizedBox(
        width: double.infinity,
        child: FilledButton.tonal(
          onPressed: validateAndSubmit,
          child: const Text(
            'Submit',
            style: TextStyle(fontSize: 16),
          ),
        ),
      );
    }
  }

  void validateAndSubmit() async {
    final form = _formKey.currentState;
    if (form!.validate()) {
      form.save();
      setState(() {
        _isLoading = true;
      });

      try {
        await FirebaseFirestore.instance.collection('reviews').add({
          'title': title,
          'comment': comment,
          'dateTimestamp': dateTimestamp,
          'posterUrl': posterUrl,
          'actors': actors,
          'lengthMin': lengthMin,
          'rating': rating,
          "userID": FirebaseAuth.instance.currentUser!.uid,
        });

        setState(() {
          _isLoading = false;
        });
      } catch (e) {
        if (e is FirebaseAuthException) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text("Error: Couldn't submit review"),
          ));
        } else {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content:
                Text('Error: Couldn\'t submit review, check your internet connection'),
          ));
        }

        setState(() {
          _isLoading = false;
        });
      }
    }
  }
}
