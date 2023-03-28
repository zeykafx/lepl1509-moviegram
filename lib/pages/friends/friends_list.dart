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

  List<UserProfile> friends = [];

  @override
  void initState() {
    super.initState();
    readUserData().then((_) {
      if (following.isNotEmpty) {
        getFriends().then((value) {
          setState(() {
            friends = value;
          });
        });
      }
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
    var followingVal = await db.collection('following').doc(currentUser?.uid).collection('userFollowing').get();
    for (var element in followingVal.docs) {
      following.add({"uid": element.id, "lastDoc": null});
    }
    setState(() {
      loading = false;
    });
  }

  Future<List<UserProfile>> getFriends() async {
    setState(() {
      loading = true;
    });

    List<UserProfile> results = [];

    var snapshot = await db.collection('users').where('uid', whereIn: following.map((e) => e["uid"])).get();
    snapshot.docs.forEach((doc) async {
      UserProfile user = UserProfile.fromMap(doc.data());
      results.add(user);
    });
    setState(() {
      loading = false;
    });

    return results;
  }

  void removeFriend({String? to, String? from}) {
    FirebaseFirestore.instance.collection('following').doc(to).collection('userFollowing').doc(from).delete();
    setState(() {
      friends.removeWhere((element) => element.uid == to);
    });
  }

  @override
  Widget build(BuildContext context) {
    if (following.isEmpty) {
      return const Center(child: Text("It's empty here, add some friends!"));
    } else {
      if (loading) return const Center(child: CircularProgressIndicator());
      return ListView(
        children: friends.map((UserProfile user) {
          return ListTile(
            leading: CircleAvatar(
              backgroundImage: NetworkImage(user.photoURL),
            ),
            title: Text(user.name),
            subtitle: Text(user.bio ?? " "),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => ProfilePage(accessToFeed: true, uid: user.uid ?? ''),
                ),
              );
            },
            trailing: IconButton(
              icon: const Icon(Icons.person_remove),
              onPressed: () {
                // show dialog asking to confirm
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text("Remove friend"),
                    content: const Text("Are you sure you want to remove this friend?"),
                    actions: [
                      TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text("Cancel")),
                      TextButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                            removeFriend(to: user.uid, from: FirebaseAuth.instance.currentUser?.uid);
                            removeFriend(to: FirebaseAuth.instance.currentUser?.uid, from: user.uid);
                          },
                          child: const Text("Remove")),
                    ],
                  ),
                );
              },
            ),
          );
        }).toList(),
      );
    }
  }
}
