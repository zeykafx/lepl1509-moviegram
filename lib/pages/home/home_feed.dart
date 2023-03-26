import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:projet_lepl1509_groupe_17/components/review_card/review_card.dart';
import 'package:projet_lepl1509_groupe_17/components/slidable_movie_list/slidable_movie_list.dart';
import 'package:projet_lepl1509_groupe_17/models/user_profile.dart';

class HomeFeed extends StatefulWidget {
  const HomeFeed({super.key});

  @override
  _HomeFeedState createState() => _HomeFeedState();
}

class _HomeFeedState extends State<HomeFeed> {
  User? currentUser = FirebaseAuth.instance.currentUser;
  FirebaseFirestore db = FirebaseFirestore.instance;
  List<Map<String, dynamic>> following = [];
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
    var value = await db.collection('users').doc(currentUser?.uid).get();
    setState(() {
      userProfile = UserProfile.fromMap(value.data() as Map<String, dynamic>);
    });
    var followingVal = await db
        .collection('following')
        .doc(currentUser?.uid)
        .collection('userFollowing')
        .get();
    for (var element in followingVal.docs) {
      following.add({"uid": element.id, "lastDoc": null});
    }
    setState(() {
      following.shuffle();
      loading = false;
    });
  }

  Future<List<Map<String, dynamic>>> getReviews() async {
    setState(() {
      loading = true;
    });
    List<Map<String, dynamic>> followingReviews = [];

    for (Map<String, dynamic> followingUserMap in following) {
      // get followers reviews
      QuerySnapshot<Map<String, dynamic>> value = await db
          .collection("posts")
          .doc(followingUserMap["uid"])
          .collection("userPosts")
          .orderBy('timestamp', descending: true)
          .limit(10)
          .get();

      // add random recommendations
      List<bool> randomList =
          List.generate(value.docs.length, (_) => random.nextBool());

      // add reviews
      for (int i = 0; i < value.docs.length; i++) {
        QueryDocumentSnapshot<Map<String, dynamic>> element = value.docs[i];
        followingReviews.add({"id": element.id, "data": element.data()});

        if (randomList[i]) {
          var values = SlidableMovieListType.values;
          int randomIndex = random.nextInt(values.length);
          SlidableMovieListType randomType = values[randomIndex];
          if (randomType == SlidableMovieListType.recommendations) {
            randomType = SlidableMovieListType.top_rated;
          }
          followingReviews.add({
            "isRecommendation": true,
            "type": randomType,
          });
        }
      }
      if (value.docs.isNotEmpty) {
        followingUserMap["lastDoc"] = value.docs.last;
      }
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

    for (Map<String, dynamic> followingUserMap in following) {
      QuerySnapshot<Map<String, dynamic>> value;
      if (followingUserMap["lastDoc"] == null) {
        value = await db
            .collection("posts")
            .doc(followingUserMap["uid"])
            .collection("userPosts")
            .orderBy('timestamp', descending: true)
            .limit(10)
            .get();
      } else {
        value = await db
            .collection("posts")
            .doc(followingUserMap["uid"])
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
          child: ListView.builder(
              key: const Key('homeFeedList'),
              addRepaintBoundaries: true,
              controller: scrollController,
              itemCount: feedContent.length,
              itemBuilder: (BuildContext context, int index) {
                if (feedContent[index].containsKey("isRecommendation")) {
                  return Padding(
                    padding: const EdgeInsets.fromLTRB(0, 15, 0, 0),
                    child: SlidableMovieList(
                      key: Key(feedContent[index]["type"].toString()),
                      padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
                      type: feedContent[index]["type"],
                      size: 250,
                    ),
                  );
                }
                return Padding(
                  padding: const EdgeInsets.fromLTRB(10, 10, 10, 0),
                  child: ReviewCard(
                    key: Key(feedContent[index]["id"]),
                    id: feedContent[index]["id"],
                    data: feedContent[index]["data"],
                    user: userProfile,
                  ),
                );
              }),
        ),
        if (loading)
          const Align(
            alignment: Alignment.center,
            child: CircularProgressIndicator(),
          ),
      ],
    ).animate().fadeIn();
  }
}
