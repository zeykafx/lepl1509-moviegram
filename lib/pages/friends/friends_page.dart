import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:projet_lepl1509_groupe_17/components/drawer/drawer.dart';
import 'package:projet_lepl1509_groupe_17/pages/friends/friends_list.dart';
import 'package:projet_lepl1509_groupe_17/pages/friends/request_list.dart';

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
  CollectionReference<Map<String, dynamic>> userRef = FirebaseFirestore.instance.collection('users');

  Future<QuerySnapshot>? searchResultsFuture;

  TextEditingController searchController = TextEditingController();

  handleSearch(String query) {
    print(query);
    Future<QuerySnapshot> users =
        userRef.where('name', isGreaterThanOrEqualTo: query).where('name', isLessThanOrEqualTo: query + '\uf8ff').get();
    setState(() {
      searchResultsFuture = users;
    });
  }

  clearSearch() {
    searchController.clear();
  }

  AppBar buildSearchField() {
    return AppBar(
      title: TextFormField(
        controller: searchController,
        decoration: InputDecoration(
            hintText: "Search for friends",
            filled: true,
            prefixIcon: const Icon(Icons.person_add),
            suffixIcon: IconButton(onPressed: clearSearch, icon: const Icon(Icons.clear))),
        onFieldSubmitted: handleSearch,
      ),
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
        final DrawerPageController drawerPageController = Get.put(DrawerPageController());
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
              child: TabBarView(
                children: [
                  searchResultsFuture == null ? const FriendsList() : buildSearchResults(),
                  const RequestList()
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  buildSearchResults() {
    return FutureBuilder(
        future: searchResultsFuture,
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (!snapshot.hasData) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
          print(snapshot.data?.docs);
          List<UserResult> searchResults = [];
          snapshot.data?.docs.forEach((doc) async {
            UserProfile user = UserProfile.fromMap(doc.data() as Map<String, dynamic>);
            bool isFriendvar = await isFriend(user.uid);
            searchResults.add(UserResult(user, isFriendvar));
          });
          return ListView(
            children: searchResults,
          );
        });
  }

  Future<bool> isFriend(String? uid) async {
    bool toReturn = false;
    CollectionReference<Map<String, dynamic>> friends =
        FirebaseFirestore.instance.collection('following').doc(currentUser?.uid).collection('userFollowing');
    await friends.get().then((value) {
      for (var element in value.docs) {
        if (element.id == uid) {
          toReturn = true;
        }
      }
    });
    return toReturn;
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
          icon: widget.isFriend ? const Icon(Icons.person_remove) : const Icon(Icons.person_add),
          onPressed: () {
            if (widget.isFriend) {
              print("remove friend");
            } else {
              sendRequest(to: widget.user.uid, from: currentUser?.uid);
            }
          },
        ));
  }
}

void sendRequest({String? to, String? from}) {
  FirebaseFirestore.instance.collection('following').doc(to).collection('friendRequests').doc(from).set({});
}
