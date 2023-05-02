import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:projet_lepl1509_groupe_17/components/drawer/drawer.dart';
import 'package:projet_lepl1509_groupe_17/pages/friends/friends_page.dart';
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
  final box = GetStorage();

  @override
  void initState() {
    getCurrentUserFriends().then((bool value) {
      setState(() {
        hasAtLeastOneFriend = value;
      });

      getCurrentUserRequests();
    });
    super.initState();
  }

  Future<bool> getCurrentUserFriends() async {
    var snapshot = await db.collection('following').doc(currentUser?.uid).collection('userFollowing').get();
    return snapshot.docs.isNotEmpty;
  }

  Future<void> getCurrentUserRequests() async {
    var snapshot = await db.collection('following').doc(currentUser?.uid).collection('friendRequests').get();
    if (snapshot.docs.isNotEmpty) {
      Future.delayed(const Duration(seconds: 1), () {
        bool showAlert = box.read('showAlert') ?? true;
        showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                title: Text(
                    'You have ${snapshot.docs.length} friend ${snapshot.docs.length > 1 ? 'requests' : 'request'}'),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Flexible(
                      child: Text(
                          'You have ${snapshot.docs.length} friend ${snapshot.docs.length > 1 ? 'requests' : 'request'}, would you like to view them?'),
                    ),
                    const SizedBox(height: 10),
                    // toggle to remember choice whether to show this alert on launch or not
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Checkbox(
                            value: showAlert,
                            onChanged: (value) {
                              setState(() {
                                showAlert = value!;
                                box.write('showAlert', value);
                              });
                            }),
                        Flexible(child: const Text('Keep showing this alert on launch')),
                      ],
                    ),
                  ],
                ),
                actions: [
                  TextButton(
                    onPressed: () {
                      Get.back();
                      Get.to(() => const FriendsPage(initialTab: 1), transition: Transition.fadeIn);
                    },
                    child: const Text('Ok view requests'),
                  ),
                  TextButton(
                    onPressed: () {
                      Get.back();
                    },
                    child: const Text('Cancel'),
                  ),
                ],
              );
            });
      });
    }
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
