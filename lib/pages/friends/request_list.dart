import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:optimized_cached_image/optimized_cached_image.dart';

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

  bool loading = false;

  List<UserProfile> requestsProfiles = [];

  @override
  void initState() {
    super.initState();
    readUserData().then((List<Map<String, dynamic>> requests) {
      if (requests.isNotEmpty) {
        getProfiles(requests).then((value) {
          setState(() {
            requestsProfiles = value;
          });
        });
      }
    });
  }

  Future<List<Map<String, dynamic>>> readUserData() async {
    List<Map<String, dynamic>> requests = [];
    setState(() {
      loading = true;
    });

    var followingVal = await db
        .collection('following')
        .doc(currentUser?.uid)
        .collection('friendRequests')
        .get();
    for (var element in followingVal.docs) {
      requests.add({"uid": element.id});
    }
    setState(() {
      loading = false;
    });
    return requests;
  }

  Future<List<UserProfile>> getProfiles(
      List<Map<String, dynamic>> requests) async {
    setState(() {
      loading = true;
    });
    List<UserProfile> results = [];

    var snapshot = await db
        .collection('users')
        .where('uid', whereIn: requests.map((e) => e["uid"]))
        .get();
    snapshot.docs.forEach((doc) async {
      UserProfile user = UserProfile.fromMap(doc.data());
      results.add(user);
    });
    setState(() {
      loading = false;
    });
    return results;
  }

  void follow({String? to, String? from}) {
    FirebaseFirestore.instance
        .collection('following')
        .doc(to)
        .collection('userFollowing')
        .doc(from)
        .set({});
    setState(() {
      db.collection('users').doc(from).update({"following": FieldValue.increment(1), "followers": FieldValue.increment(1)});
      requestsProfiles.removeWhere((element) => element.uid == from);
    });
  }

  void removeRequest({String? to, String? from}) {
    FirebaseFirestore.instance
        .collection('following')
        .doc(to)
        .collection('friendRequests')
        .doc(from)
        .delete();
    setState(() {
      requestsProfiles.removeWhere((element) => element.uid == from);
    });
  }

  @override
  Widget build(BuildContext context) {
    if (requestsProfiles.isEmpty) {
      return const Center(
        child: Text("No requests"),
      );
    } else {
      if (loading) const Center(child: CircularProgressIndicator());
      return ListView(
        children: requestsProfiles.map((UserProfile user) {
          return ListTile(
            leading: CircleAvatar(
              backgroundImage: OptimizedCacheImageProvider(user.photoURL),
            ),
            title: Text(user.name),
            subtitle: Text(user.bio ?? " "),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) =>
                      ProfilePage(accessToFeed: false, uid: user.uid ?? ''),
                ),
              );
            },
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.check),
                  onPressed: () {
                    follow(to: user.uid, from: currentUser?.uid);
                    follow(to: currentUser?.uid, from: user.uid);
                    removeRequest(to: currentUser?.uid, from: user.uid);
                    // show a success snackbar
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Request accepted, you are now friends!"),
                      ),
                    );
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () {
                    removeRequest(to: currentUser?.uid, from: user.uid);
                    // show a success snackbar
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Request removed"),
                      ),
                    );
                  },
                ),
              ],
            ),
          );
        }).toList(),
      );
    }
  }
}
