import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:projet_lepl1509_groupe_17/components/drawer/drawer.dart';
import 'package:projet_lepl1509_groupe_17/pages/home/explore_feed.dart';
import 'package:projet_lepl1509_groupe_17/pages/home/home_feed.dart';
import 'package:projet_lepl1509_groupe_17/pages/search/search_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  User? currentUser = FirebaseAuth.instance.currentUser;
  FirebaseFirestore db = FirebaseFirestore.instance;
  bool? hasAtLeastOneFriend;

  @override
  void initState() {
    getCurrentUserFriends().then((bool value) {
      setState(() {
        hasAtLeastOneFriend = value;
      });
    });
    super.initState();
  }

  Future<bool> getCurrentUserFriends() async {
    var snapshot = await db
        .collection('following')
        .doc(currentUser?.uid)
        .collection('userFollowing')
        .get();
    return snapshot.docs.isNotEmpty;
  }

  @override
  Widget build(BuildContext context) {
    return hasAtLeastOneFriend == null
        ? const Center(child: CircularProgressIndicator())
        : DefaultTabController(
            initialIndex: hasAtLeastOneFriend! ? 0 : 1,
            length: 2,
            child: Scaffold(
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
                bottom: const TabBar(
                  tabs: [
                    Tab(
                      text: "Following",
                    ),
                    Tab(
                      text: "Explore",
                    ),
                  ],
                ),
              ),
              body: Center(
                child: Container(
                  constraints: const BoxConstraints(maxWidth: 700),
                  child: const TabBarView(
                    children: [
                      HomeFeed(),
                      ExploreFeed(),
                    ],
                  ),
                ),
              ),
            ),
          );
  }
}
