import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:projet_lepl1509_groupe_17/components/review_card/review_card.dart';
import 'package:projet_lepl1509_groupe_17/models/user_profile.dart';

class HomeFeed extends StatefulWidget {
  const HomeFeed({super.key});

  @override
  _HomeFeedState createState() => _HomeFeedState();
}

class _HomeFeedState extends State<HomeFeed> {
  int page = 5;
  bool loadingMore = false;
  ScrollController scrollController = ScrollController();

  User? currentUser = FirebaseAuth.instance.currentUser;
  FirebaseFirestore db = FirebaseFirestore.instance;
  List<String> following = [];
  UserProfile? userProfile;
  int batchSize = 5;

  @override
  void initState() {
    super.initState();
    readUserData();

    scrollController.addListener(() async {
      if (scrollController.position.pixels == scrollController.position.maxScrollExtent) {
        setState(() {
          page = page + 5;
          loadingMore = true;
        });
      }
    });

    if (currentUser != null) {
      db.collection('following').doc(currentUser?.uid).collection('userFollowing').get().then((value) {
        for (var element in value.docs) {
          following.add(element.id);
        }
      });
    }
  }

  Future<void> readUserData() async {
    await db.collection('users').doc(currentUser?.uid).get().then((value) {
      setState(() {
        userProfile = UserProfile.fromMap(value.data() as Map<String, dynamic>);
      });
    });
  }

  Future<List<Map<String, dynamic>>> getReviews() async {
    List<Map<String, dynamic>> followingReviews = [];

    for (String followingUserID in following) {
      var value = await db
          .collection("posts")
          .doc(followingUserID)
          .collection("userPosts")
          .orderBy('timestamp', descending: true)
          .limit(page) // trying to show recent posts by each of the following users
          .get();
      for (var element in value.docs) {
        followingReviews.add({"id": element.id, "data": element.data()});
      }
    }

    return followingReviews;
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async {},
      child: SingleChildScrollView(
        physics: const NeverScrollableScrollPhysics(),
        child: Column(
          mainAxisSize: MainAxisSize.max,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Following", style: TextStyle(fontSize: 20)),
            // put anything that will always be above the feed here
            SizedBox(
                height: MediaQuery.of(context).size.height,
                child: FutureBuilder(
                  future: getReviews(),
                  builder: (BuildContext context, snapshot) {
                    if (snapshot.hasData && snapshot.data != null) {
                      return ListView.builder(
                        controller: scrollController,
                        itemCount: snapshot.data!.length,
                        addAutomaticKeepAlives: true,
                        cacheExtent: 20,
                        itemBuilder: (BuildContext context, int index) {
                          return ReviewCard(
                            id: snapshot.data![index]["id"],
                            data: snapshot.data![index]["data"],
                            user: userProfile,
                          );
                        },
                      );
                    } else if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(
                        child: CircularProgressIndicator(),
                      );
                    } else {
                      return const Center(
                        child: Text("No reviews posted by your friends",
                            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                      );
                    }
                  },
                )),
          ],
        ),
      ),
    );
  }
}
