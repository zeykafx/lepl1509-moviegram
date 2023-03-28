import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../models/user_profile.dart';
import '../profile/pages/profile_page.dart';

class RequestList extends StatefulWidget {
  const RequestList({super.key});

  @override
  _RequestListState createState() => _RequestListState();
}

class _RequestListState extends State<RequestList> {
  User? currentUser = FirebaseAuth.instance.currentUser;
  FirebaseFirestore db = FirebaseFirestore.instance;
  List<Map<String, dynamic>> requests = [];
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
    var followingVal = await db.collection('following').doc(currentUser?.uid).collection('friendRequests').get();
    for (var element in followingVal.docs) {
      requests.add({"uid": element.id, "lastDoc": null});
    }
    setState(() {
      loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (requests.isEmpty) {
      return const Center(child: Text("No requests"));
    } else {
      return FutureBuilder(
          future: db.collection('users').where('uid', whereIn: requests.map((e) => e["uid"])).get(),
          builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
            if (!snapshot.hasData) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }
            List<UserResult> searchResults = [];
            snapshot.data?.docs.forEach((doc) async {
              UserProfile user = UserProfile.fromMap(doc.data() as Map<String, dynamic>);
              searchResults.add(UserResult(user, true));
            });
            return ListView(
              children: searchResults,
            );
          });
    }
  }
}

class UserResult extends StatefulWidget {
  final UserProfile user;
  final bool isFriend;

  UserResult(this.user, this.isFriend);

  @override
  State<UserResult> createState() => _UserResultState();
}

class _UserResultState extends State<UserResult> {
  User? currentUser = FirebaseAuth.instance.currentUser;
  void follow({String? to, String? from}) {
    FirebaseFirestore.instance.collection('following').doc(to).collection('userFollowing').doc(from).set({});
    setState(() {});
  }

  void removeRequest({String? to, String? from}) {
    FirebaseFirestore.instance.collection('following').doc(to).collection('friendRequests').doc(from).delete();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
        leading: CircleAvatar(
          backgroundImage: NetworkImage(widget.user.photoURL),
        ),
        title: Text(widget.user.name),
        subtitle: Text(widget.user.bio ?? " "),
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => ProfilePage(accessToFeed: widget.isFriend, uid: widget.user.uid ?? ''),
            ),
          );
        },
        trailing: IconButton(
          icon: const Icon(Icons.person_add),
          onPressed: () {
            follow(to: widget.user.uid, from: currentUser?.uid);
            follow(to: currentUser?.uid, from: widget.user.uid);
            removeRequest(to: currentUser?.uid, from: widget.user.uid);
          },
        ));
  }
}
