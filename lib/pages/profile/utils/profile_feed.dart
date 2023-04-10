import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:projet_lepl1509_groupe_17/models/user_profile.dart';

import '../../../components/review_card/review_card.dart';
import '../pages/edit_profile_page.dart';
import '../widgets/numbers_widget.dart';
import '../widgets/profile_widget.dart';

class ProfileFeed extends StatefulWidget {
  final String uid;
  final bool accessToFeed;
  final bool isCurrentUser;

  const ProfileFeed({
    super.key,
    required this.uid,
    required this.accessToFeed,
    required this.isCurrentUser,
  });

  @override
  _ProfileFeedState createState() => _ProfileFeedState();
}

class _ProfileFeedState extends State<ProfileFeed> {
  //User? currentUser = FirebaseAuth.instance.currentUser;
  FirebaseFirestore db = FirebaseFirestore.instance;
  Map<String, dynamic> followingUserMap = {"lastDoc": null};
  UserProfile? userProfile;

  bool loading = false;
  ScrollController scrollController = ScrollController();

  List<Map<String, dynamic>> feedContent = [];

  Random random = Random();

  bool hasSentRequest = false;

  @override
  void initState() {
    super.initState();
    scrollController.addListener(() async {
      if (scrollController.position.pixels ==
          scrollController.position.maxScrollExtent) {
        getMoreReviews().then((value) {
          setState(() {
            feedContent.addAll(value);
          });
        });
      }
    });
    readUserData().then((_) {
      checkHasSentRequest().then((hasSent) {
        setState(() {
          hasSentRequest = hasSent;
        });
      });
      getReviews().then((value) {
        setState(() {
          feedContent = value;
        });
      });
    });
  }

  Future<void> readUserData() async {
    setState(() {
      loading = true;
    });
    var value = await db.collection('users').doc(widget.uid).get();
    setState(() {
      userProfile = UserProfile.fromMap(value.data() as Map<String, dynamic>);
    });

    setState(() {
      loading = false;
    });
  }

  Future<List<Map<String, dynamic>>> getReviews() async {
    setState(() {
      loading = true;
    });
    List<Map<String, dynamic>> followingReviews = [];
    // get followers reviews
    QuerySnapshot<Map<String, dynamic>> value = await db
        .collection("posts")
        .doc(userProfile?.uid)
        .collection("userPosts")
        .orderBy('timestamp', descending: true)
        .limit(10)
        .get();

    // add reviews
    for (int i = 0; i < value.docs.length; i++) {
      QueryDocumentSnapshot<Map<String, dynamic>> element = value.docs[i];
      followingReviews.add({"id": element.id, "data": element.data()});
    }

    if (value.docs.isNotEmpty) {
      followingUserMap["lastDoc"] = value.docs.last;
    }

    setState(() {
      loading = false;
    });
    return followingReviews;
  }

  Future<List<Map<String, dynamic>>> getMoreReviews() async {
    setState(() {
      loading = true;
    });
    List<Map<String, dynamic>> followingReviews = [];

    QuerySnapshot<Map<String, dynamic>> value;
    if (followingUserMap["lastDoc"] == null) {
      value = await db
          .collection("posts")
          .doc(userProfile?.uid)
          .collection("userPosts")
          .orderBy('timestamp', descending: true)
          .limit(10)
          .get();
    } else {
      value = await db
          .collection("posts")
          .doc(userProfile?.uid)
          .collection("userPosts")
          .orderBy('timestamp', descending: true)
          .startAfterDocument(followingUserMap["lastDoc"]!)
          .limit(10)
          .get();
    }

    for (var element in value.docs) {
      followingReviews.add({"id": element.id, "data": element.data()});

      if (element.id == value.docs.last.id) {
        followingUserMap["lastDoc"] = element;
      }
    }

    setState(() {
      loading = false;
    });
    return followingReviews;
  }

  Future<bool> checkHasSentRequest() async {
    bool value = await db
        .collection("following")
        .doc(userProfile?.uid)
        .collection("friendRequests")
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .get()
        .then((value) => value.exists);
    return value;
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        RefreshIndicator(
            onRefresh: () async {
              getReviews().then((value) {
                setState(() {
                  feedContent = value;
                });
              });
            },
            child: ListView(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      ProfileWidget(
                        imagePath: userProfile?.photoURL ??
                            'http://www.gravatar.com/avatar/?d=mp',
                        inDrawer: false,
                        self: widget.isCurrentUser,
                        access: widget.accessToFeed,
                        onClicked: () {
                          // widget.isCurrentUser
                          Navigator.of(context)
                              .push(
                            MaterialPageRoute(
                              builder: (context) => EditProfilePage(),
                            ),
                          )
                              .then((_) {
                            setState(() {
                              readUserData();
                            });
                          });
                          // : (widget.accessToFeed
                          //     ? DoubleRemoveFriend(
                          //         to: widget.uid,
                          //         from: FirebaseAuth.instance.currentUser!.uid)
                          //     : sendRequest(
                          //         to: widget.uid,
                          //         from: FirebaseAuth.instance.currentUser!.uid));
                        },
                      ),

                      const SizedBox(width: 20),

                      // name and email
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          Text(
                            userProfile?.name ?? "No name",
                            style: const TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 18),
                          ),
                          Text(
                            userProfile?.bio ?? "No bio",
                            style: TextStyle(
                                fontSize: 14,
                                color: Theme.of(context).dividerColor),
                          ),
                          if (!widget.isCurrentUser) ...[
                            const SizedBox(height: 2),
                            FilledButton(
                              style: ButtonStyle(
                                backgroundColor: MaterialStateProperty.all(
                                    widget.accessToFeed
                                        ? Theme.of(context)
                                            .colorScheme
                                            .primary
                                            .withOpacity(0.5)
                                        : hasSentRequest
                                            ? Theme.of(context)
                                                .dividerColor
                                                .withOpacity(0.8)
                                            : Theme.of(context)
                                                .colorScheme
                                                .primary),
                                shape: MaterialStateProperty.all(
                                  RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                                visualDensity: VisualDensity.compact,
                              ),
                              child: Text(widget.accessToFeed
                                  ? 'Unfollow'
                                  : hasSentRequest
                                      ? 'Cancel request'
                                      : 'Follow'),
                              onPressed: () {
                                widget.accessToFeed
                                    ? DoubleRemoveFriend(
                                        to: widget.uid,
                                        from: FirebaseAuth
                                            .instance.currentUser!.uid)
                                    : hasSentRequest
                                        ? removeRequest()
                                        : sendRequest(
                                            to: widget.uid,
                                            from: FirebaseAuth
                                                .instance.currentUser!.uid);
                              },
                            )
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                // followers, ranking, ...
                NumbersWidget(
                  userProfile: userProfile,
                  numberPosts: feedContent.length,
                ),
                const SizedBox(height: 15),

                // const SizedBox(height: 15),

                // watched section
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 18),
                  child: Text(
                    'Watched :',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ),

                widget.accessToFeed
                    ? ListView.builder(
                        key: const Key('profileFeedList'),
                        shrinkWrap: true,
                        physics: ScrollPhysics(),
                        addRepaintBoundaries: true,
                        controller: scrollController,
                        itemCount: feedContent.length,
                        itemBuilder: (BuildContext context, int index) {
                          return Padding(
                            padding: const EdgeInsets.fromLTRB(18, 10, 18, 0),
                            child: ReviewCard(
                              key: Key(feedContent[index]["id"]),
                              id: feedContent[index]["id"],
                              data: feedContent[index]["data"],
                              user: userProfile,
                              showRatingPill: true,
                            ),
                          );
                        })
                    : const Center(
                        child: Text(
                          'This user is private',
                          style: TextStyle(fontSize: 20),
                        ),
                      )
              ],
            )),
        if (loading)
          const Align(
            alignment: Alignment.center,
            child: CircularProgressIndicator(),
          ),
      ],
    ).animate().fadeIn();
  }

  void sendRequest({String? to, String? from}) {
    FirebaseFirestore.instance
        .collection('following')
        .doc(to)
        .collection('friendRequests')
        .doc(from)
        .set({});
    setState(() {
      hasSentRequest = true;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Request sent!'),
      ),
    );
  }

  void removeFriend({String? to, String? from}) {
    FirebaseFirestore.instance
        .collection('following')
        .doc(to)
        .collection('userFollowing')
        .doc(from)
        .delete();
    db.collection('users').doc(from).update({
      "following": FieldValue.increment(-1),
      "followers": FieldValue.increment(-1)
    });
    setState(() {});
  }

  void DoubleRemoveFriend({String? to, String? from}) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Remove friend"),
        content: const Text("Are you sure you want to remove this friend?"),
        actions: [
          TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text("Cancel")),
          TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                removeFriend(to: to, from: from);
                removeFriend(to: from, from: to);
                // show a snackbar
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Friend removed!'),
                  ),
                );
                setState(() {});
              },
              child: const Text("Remove")),
        ],
      ),
    );
  }

  bool removeRequest() {
    FirebaseFirestore.instance
        .collection('following')
        .doc(widget.uid)
        .collection('friendRequests')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .delete();
    setState(() {
      hasSentRequest = false;
    });
    return true;
  }
}
