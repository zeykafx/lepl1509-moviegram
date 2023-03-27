import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:projet_lepl1509_groupe_17/models/user_profile.dart';

import '../utils/profile_feed.dart';


class ProfilePage extends StatefulWidget {
  final bool accessToFeed;
  final String uid;

  const ProfilePage({
    Key? key,
    required this.accessToFeed,
    required this.uid,
  }) : super(key: key);

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  var db = FirebaseFirestore.instance;

  UserProfile? userProfile;

  @override
  void initState() {
    super.initState();
    readUserData();
  }

  // gets the user data from firestore
  Future<void> readUserData() async {
    var value = await db.collection('users').doc(widget.uid).get();
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
              child: ProfileFeed(
                  uid : widget.uid,
                  accessToFeed : widget.accessToFeed,
                  isCurrentUser: widget.uid == FirebaseAuth.instance.currentUser?.uid,
              ),
            ),
      ),
    );
  }
}