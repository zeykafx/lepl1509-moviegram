import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:projet_lepl1509_groupe_17/components/drawer/drawer.dart';
import 'package:projet_lepl1509_groupe_17/components/review_card/review_card.dart';
import 'package:projet_lepl1509_groupe_17/models/user_profile.dart';
import 'package:projet_lepl1509_groupe_17/pages/search/search_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  FirebaseFirestore db = FirebaseFirestore.instance;
  UserProfile? userProfile;
  User? currentUser = FirebaseAuth.instance.currentUser;

  @override
  void initState() {
    super.initState();
    readUserData();
  }

  Future<void> readUserData() async {
    await db.collection('users').doc(currentUser?.uid).get().then((value) {
      setState(() {
        userProfile = UserProfile.fromMap(value.data() as Map<String, dynamic>);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const DrawerComponent(),
      appBar: AppBar(
        title: const Text('MovieGram'),
        actions: [
          IconButton(
            onPressed: () {
              Get.to(() => const SearchPage());
            },
            icon: const Icon(Icons.search),
          ),
        ],
      ),
      body: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 700),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.max,
              children: [
                // const SlidableMovieList(
                //   size: 250,
                //   type: SlidableMovieListType.now_playing,
                //   padding: EdgeInsets.symmetric(horizontal: 8.0),
                // ),
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                  child: Text("Most recent reviews", style: TextStyle(fontSize: 20)),
                ),
                FutureBuilder(
                    future: FirebaseFirestore.instance.collection('reviews').orderBy('timestamp', descending: false).get(),
                    builder: (context, AsyncSnapshot snapshot) {
                      if (snapshot.hasData) {
                        return Expanded(
                          child: ListView.builder(
                              shrinkWrap: true,
                              cacheExtent: 20,
                              addAutomaticKeepAlives: true,
                              itemCount: snapshot.data.docs.length,
                              itemBuilder: (context, index) {
                                return ReviewCard(
                                  id: snapshot.data.docs[index].id,
                                  data: snapshot.data.docs[index].data(),
                                  user: userProfile,
                                );
                              }),
                        );
                      } else {
                        return const Center(child: CircularProgressIndicator());
                      }
                    }),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
