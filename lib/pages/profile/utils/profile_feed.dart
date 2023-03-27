import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:projet_lepl1509_groupe_17/models/user_profile.dart';

import '../../../components/review_card/review_card_pp.dart';
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
  Map<String, dynamic> followingUserMap = {
    "lastDoc": null
  };
  UserProfile? userProfile;

  bool loading = false;
  ScrollController scrollController = ScrollController();

  List<Map<String, dynamic>> feedContent = [];

  Random random = Random();

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
            children : [
              ProfileWidget(
                imagePath: userProfile?.photoURL ?? 'http://www.gravatar.com/avatar/?d=mp',
                inDrawer: false,
                self: widget.isCurrentUser,
                access : widget.accessToFeed,
                onClicked: () {widget.isCurrentUser ? Navigator.of(context).push(MaterialPageRoute(
                  builder:
                      (context) => EditProfilePage(),
                ),
                ).then((_) {
                  setState(() {
                    readUserData();
                  });
                }) : (widget.accessToFeed ?
                DoubleRemoveFriend(to: widget.uid, from: FirebaseAuth.instance.currentUser!.uid) :
                sendRequest(to: widget.uid, from: FirebaseAuth.instance.currentUser!.uid)
                );
                },
              ),
              const SizedBox(height: 10),

              // name and email
              Column(
                children: [
                  Text(
                    userProfile?.name ?? "No name",
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    userProfile?.email ?? "No email",
                    style: const TextStyle(color: Colors.grey),
                  ),
                ],
              ),

              const SizedBox(height: 15),

              // followers, ranking, ...
              NumbersWidget(
                userProfile: userProfile,
              ),
              const SizedBox(height: 15),

              Container(
                padding: const EdgeInsets.symmetric(horizontal: 48),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Bio : ',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      '    ${userProfile?.bio ?? "No bio"}',
                      style: const TextStyle(fontSize: 16, height: 1.4),
                    ),
                    const SizedBox(height: 10),

                    const Divider(),

                    const SizedBox(height: 15),

                    // watched section
                    const Text(
                      'Watched : ',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),

              widget.accessToFeed ? ListView.builder(
                key: const Key('profileFeedList'),
                shrinkWrap: true,
                physics: ScrollPhysics(),
                addRepaintBoundaries: true,
                controller: scrollController,
                itemCount: feedContent.length,
                itemBuilder: (BuildContext context, int index) {
                  return Padding(
                    padding: const EdgeInsets.fromLTRB(10, 10, 10, 0),
                    child: ReviewCardPP(
                      key: Key(feedContent[index]["id"]),
                      id: feedContent[index]["id"],
                      data: feedContent[index]["data"],
                      user: userProfile,
                    ),
                  );
                }
              ) : const Center(
                child:  Text(
                  'This user is private',
                  style: TextStyle(fontSize: 20),
                ),
              )
            ],

          )
        ),
        if (loading)
          const Align(
            alignment: Alignment.center,
            child: CircularProgressIndicator(),
          ),
      ],
    ).animate().fadeIn();
  }

  void sendRequest({String? to, String? from}) {
    FirebaseFirestore.instance.collection('following').doc(to).collection('friendRequests').doc(from).set({});
  }
}

void removeFriend({String? to, String? from}) {
  FirebaseFirestore.instance.collection('following').doc(to).collection('userFollowing').doc(from).delete();
}

void DoubleRemoveFriend({String? to, String? from}) {
  removeFriend(to: to, from: from);
  removeFriend(to: from, from: to);
}