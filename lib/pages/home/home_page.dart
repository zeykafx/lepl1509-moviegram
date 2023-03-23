import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:projet_lepl1509_groupe_17/components/drawer/drawer.dart';
import 'package:projet_lepl1509_groupe_17/models/user_profile.dart';
import 'package:projet_lepl1509_groupe_17/pages/home/home_feed.dart';
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
          child: const Padding(
            padding: EdgeInsets.all(8.0),
            child: HomeFeed(),
          ),
        ),
      ),
    );
  }
}
