import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:projet_lepl1509_groupe_17/components/drawer/drawer.dart';
import 'package:projet_lepl1509_groupe_17/pages/friends/friends_list.dart';
import 'package:projet_lepl1509_groupe_17/pages/friends/request_list.dart';

import '../../models/user_profile.dart';
import '../profile/pages/profile_page.dart';

User? currentUser = FirebaseAuth.instance.currentUser;

class FriendsPage extends StatefulWidget {
  const FriendsPage({super.key});

  @override
  _FriendsPageState createState() => _FriendsPageState();
}

class _FriendsPageState extends State<FriendsPage> {
  FirebaseFirestore db = FirebaseFirestore.instance;
  CollectionReference<Map<String, dynamic>> userRef = FirebaseFirestore.instance.collection('users');

  Future<QuerySnapshot>? searchResultsFuture;

  TextEditingController searchController = TextEditingController();

  handleSearch(String query) {
    Future<QuerySnapshot> users = userRef.where('name', isGreaterThanOrEqualTo: query).get();
    setState(() {
      searchResultsFuture = users;
    });
  }

  clearSearch() {
    searchController.clear();
  }

  AppBar buildSearchField(){
    return AppBar(
      title: TextFormField(
        controller: searchController,
        decoration: InputDecoration(
          hintText: "Search for friends",
          filled: true,
          prefixIcon: Icon(Icons.person_add),
          suffixIcon: IconButton(
              onPressed: clearSearch,
              icon: Icon(Icons.clear)
          )
        ),
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
    return DefaultTabController(
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
                searchResultsFuture == null ? FriendsList() : buildSearchResults(),
                RequestList()
              ],
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
          List<UserResult> searchResults = [];
          snapshot.data?.docs.forEach((doc) async {
            UserProfile user = UserProfile.fromMap(doc.data() as Map<String, dynamic>);
            bool isFriendvar = await isFriend(user.uid);
            searchResults.add(UserResult(user,isFriendvar));
          });
          return ListView(
            children: searchResults,
          );
        }
    );
  }

  Future<bool> isFriend(String? uid) async {
    bool toReturn = false;
    CollectionReference<Map<String, dynamic>> friends = FirebaseFirestore.instance.collection('following').doc(currentUser?.uid).collection('userFollowing');
    await friends.get().then((value) {
      value.docs.forEach((element) {
        if (element.id == uid) {
          toReturn = true;
        }
      });
    });
    return toReturn;
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
        icon: isFriend ? Icon(Icons.person_remove) : const Icon(Icons.person_add),
        onPressed: () {
          if (isFriend) {
            print("remove friend");
          } else {
            sendRequest(to : user.uid, from : currentUser?.uid);
          }
        },
      )
    );
  }
}

void sendRequest({String? to, String? from}) {
  FirebaseFirestore.instance.collection('following').doc(to).collection('friendRequests').doc(from).set({});
}
