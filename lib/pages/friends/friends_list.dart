import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../models/user_profile.dart';
import '../profile/pages/profile_page.dart';

class FriendsList extends StatefulWidget {
  const FriendsList({super.key});

  @override
  _FriendsListState createState() => _FriendsListState();
}

class _FriendsListState extends State<FriendsList> {

  User? currentUser = FirebaseAuth.instance.currentUser;
  FirebaseFirestore db = FirebaseFirestore.instance;
  List<Map<String, dynamic>> following = [];
  UserProfile? userProfile;
  bool loading = false;

  @override
  void initState() {
    super.initState();
    readUserData();
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
      loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if(following.isEmpty) {
      return const Center(child: Text("No friends"));
    } else {
      return FutureBuilder(
          future: db.collection('users').where(
              'uid', whereIn: following.map((e) => e["uid"])).get(),
          builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
            if (!snapshot.hasData) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }
            List<UserResult> searchResults = [];
            snapshot.data?.docs.forEach((doc) async {
              UserProfile user = UserProfile.fromMap(
                  doc.data() as Map<String, dynamic>);
              searchResults.add(UserResult(user, true));
            });
            return ListView(
              children: searchResults,
            );
          }
      );
    }
  }
}

class UserResult extends StatelessWidget {
  final UserProfile user;
  final bool isFriend;

  UserResult(this.user, this.isFriend);


  @override
  Widget build(BuildContext context) {
    return ListTile(
        leading: CircleAvatar(
          backgroundImage: NetworkImage(user.photoURL),
        ),
        title: Text(user.name),
        subtitle: Text(user.bio ?? " "),
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) =>
                  ProfilePage(accessToFeed: isFriend, uid: user.uid ?? ''),
            ),
          );
        },
        trailing: IconButton(
          icon: Icon(Icons.person_remove),
          onPressed: () {
            removeFriend(to: user.uid, from: FirebaseAuth.instance.currentUser?.uid);
            removeFriend(to: FirebaseAuth.instance.currentUser?.uid, from: user.uid);
          },
        ),
    );
  }
}

void removeFriend({String? to, String? from}) {
  FirebaseFirestore.instance.collection('following').doc(to).collection('userFollowing').doc(from).delete();
}
