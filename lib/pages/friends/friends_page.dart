import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:optimized_cached_image/optimized_cached_image.dart';
import 'package:projet_lepl1509_groupe_17/components/drawer/drawer.dart';
import 'package:projet_lepl1509_groupe_17/pages/friends/friends_list.dart';
import 'package:projet_lepl1509_groupe_17/pages/friends/request_list.dart';
import 'package:search_page/search_page.dart';

import '../../models/user_profile.dart';
import '../profile/pages/profile_page.dart';

class FriendsPage extends StatefulWidget {
  const FriendsPage({super.key});

  @override
  _FriendsPageState createState() => _FriendsPageState();
}

class _FriendsPageState extends State<FriendsPage> {
  User? currentUser = FirebaseAuth.instance.currentUser;
  FirebaseFirestore db = FirebaseFirestore.instance;

  bool loading = false;
  List<UserProfile> users = [];
  List<UserProfile> currentUserFriends = [];

  @override
  initState() {
    super.initState();
    setState(() {
      loading = true;
    });
    getUsers().then((List<UserProfile> value) {
      getCurrentUserFriends().then((List<UserProfile> userFriends) {
        setState(() {
          users = value;
          currentUserFriends = userFriends;
          // print(currentUserFriends);
          loading = false;
        });
      });
    });
  }

  Future<List<UserProfile>> getUsers() async {
    List<UserProfile> results = [];
    var snapshot = await db.collection('users').get();
    snapshot.docs.forEach((doc) async {
      UserProfile user = UserProfile.fromMap(doc.data());
      if (user.uid != currentUser?.uid) {
        results.add(user);
      }
    });
    return results;
  }

  Future<List<UserProfile>> getCurrentUserFriends() async {
    List<UserProfile> results = [];
    var snapshot = await db
        .collection('following')
        .doc(currentUser?.uid)
        .collection('userFollowing')
        .get();
    for (var doc in snapshot.docs) {
      var userSnapshot = await db.collection('users').doc(doc.id).get();
      UserProfile user = UserProfile.fromMap(userSnapshot.data()!);
      results.add(user);
    }
    return results;
  }

  void sendRequest({String? to, String? from}) {
    FirebaseFirestore.instance
        .collection('following')
        .doc(to)
        .collection('friendRequests')
        .doc(from)
        .set({});
    setState(() {});
    // show a snackbar
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Request sent!'),
      ),
    );
  }

  void removeFriend({String? to, String? from}) {
    FirebaseFirestore.instance
        .collection('following')
        .doc(to)
        .collection('userFollowing')
        .doc(from)
        .delete();
    setState(() {});
  }

  AppBar buildSearchField() {
    return AppBar(
      title: const Text('Friends'),
      actions: [
        IconButton(
            onPressed: () {
              showSearch(
                  context: context,
                  delegate: SearchPage<UserProfile>(
                    items: users,
                    searchLabel: 'Find users',
                    suggestion: const Center(
                      child: Text('Filter people by name, email,...'),
                    ),
                    failure: const Center(
                      child: Text('No user found :('),
                    ),
                    filter: (person) => [
                      person.name,
                      person.email,
                    ],
                    builder: (UserProfile user) {
                      if (loading) {
                        return const Center(child: CircularProgressIndicator());
                      } else {
                        bool isFriend = currentUserFriends
                            .where((element) => element.uid == user.uid)
                            .isNotEmpty;
                        print("name: ${user.name} isFriend: $isFriend");
                        return ListTile(
                            leading: CircleAvatar(
                              backgroundImage:
                                  OptimizedCacheImageProvider(user.photoURL),
                            ),
                            title: Text(user.name),
                            subtitle: Text(user.bio ?? " "),
                            onTap: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) => ProfilePage(
                                      accessToFeed: isFriend,
                                      uid: user.uid ?? ''),
                                ),
                              );
                            },
                            trailing: IconButton(
                              icon: isFriend
                                  ? const Icon(Icons.person_remove)
                                  : const Icon(Icons.person_add),
                              onPressed: () {
                                if (isFriend) {
                                  print("remove friend");
                                  // remove friend
                                  showDialog(
                                    context: context,
                                    builder: (context) => AlertDialog(
                                      title: const Text("Remove friend"),
                                      content: const Text(
                                          "Are you sure you want to remove this friend?"),
                                      actions: [
                                        TextButton(
                                            onPressed: () =>
                                                Navigator.of(context).pop(),
                                            child: const Text("Cancel")),
                                        TextButton(
                                            onPressed: () {
                                              Navigator.of(context).pop();
                                              removeFriend(
                                                  to: user.uid,
                                                  from: FirebaseAuth.instance
                                                      .currentUser?.uid);
                                              removeFriend(
                                                  to: FirebaseAuth.instance
                                                      .currentUser?.uid,
                                                  from: user.uid);
                                              // show a snackbar
                                              ScaffoldMessenger.of(context)
                                                  .showSnackBar(
                                                const SnackBar(
                                                  content:
                                                      Text('Friend removed!'),
                                                ),
                                              );
                                            },
                                            child: const Text("Remove")),
                                      ],
                                    ),
                                  );
                                } else {
                                  sendRequest(
                                      to: user.uid, from: currentUser?.uid);
                                }
                              },
                            ));
                      }
                    },
                  ));
            },
            icon: const Icon(Icons.search)),
      ],
      bottom: const TabBar(
        tabs: [
          Tab(
            text: "Friends",
          ),
          Tab(
            text: "Requests",
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        final DrawerPageController drawerPageController =
            Get.put(DrawerPageController());
        drawerPageController.changeCurrentPage(0);
        return true;
      },
      child: DefaultTabController(
        initialIndex: 0,
        length: 2,
        child: Scaffold(
          drawer: const DrawerComponent(),
          appBar: buildSearchField(),
          body: Center(
            child: Container(
              constraints: const BoxConstraints(maxWidth: 700),
              child: const TabBarView(
                children: [FriendsList(), RequestList()],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
