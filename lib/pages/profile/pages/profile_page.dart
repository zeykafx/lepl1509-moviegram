import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:projet_lepl1509_groupe_17/models/user_profile.dart';

import '../utils/profile_feed.dart';


class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  var db = FirebaseFirestore.instance;

  User? currentUser = FirebaseAuth.instance.currentUser;

  UserProfile? userProfile;

  @override
  void initState() {
    super.initState();
    readUserData();
  }

  // gets the user data from firestore
  Future<void> readUserData() async {
    var value = await db.collection('users').doc(currentUser?.uid).get();
    await currentUser?.reload();
    setState(() {
      userProfile = UserProfile.fromMap(value.data() as Map<String, dynamic>);
    });
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
      ),
      body: Center(
            child: Container(
              constraints: const BoxConstraints(maxWidth: 700),
              child: const ProfileFeed(),
            ),
      ),
    );
  }
}