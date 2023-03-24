import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:projet_lepl1509_groupe_17/components/review_card/review_card_pp.dart';
import 'package:projet_lepl1509_groupe_17/models/user_profile.dart';
import 'package:projet_lepl1509_groupe_17/pages/profile/utils/about_preferences.dart';
import 'package:projet_lepl1509_groupe_17/pages/profile/widgets/profile_widget.dart';

import '../../../components/review_card/review_card.dart';
import '../widgets/numbers_widget.dart';
import 'edit_profile_page.dart';


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
      body: Column(
        children: [
          ProfileWidget(
            imagePath: currentUser?.photoURL ?? 'http://www.gravatar.com/avatar/?d=mp',
            inDrawer: false,
            onClicked: () {Navigator.of(context).push(MaterialPageRoute(
              builder:
                  (context) => EditProfilePage(),
            ),
            ).then((_) {
              setState(() {
                readUserData();
              });
            });
            },
          ),
          const SizedBox(height: 10),

          // name and email
          Column(
            children: [
              Text(
                currentUser?.displayName ?? "No name",
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
              ),
              const SizedBox(height: 4),
              Text(
                currentUser?.email ?? "No email",
                style: const TextStyle(color: Colors.grey),
              ),
            ],
          ),

          const SizedBox(height: 15),

          // followers, ranking, ...
          NumbersWidget(
            userProfile: userProfile,
          ),
          const SizedBox(height: 15),


          const Padding(
            padding: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
            child: Text("Watched", style: TextStyle(fontSize: 20)),
          ),
          FutureBuilder(
            future: db.collection('reviews').where('reviewID', whereIn: userProfile?.watched.isEmpty ?? true ? [''] : userProfile?.watched).get(),
            builder: (context, AsyncSnapshot snapshot) {
              if (snapshot.hasData) {
                print("length : ");
                print(snapshot.data.docs.length);
                print(userProfile?.watched.isEmpty ?? true ? ['a'] : userProfile?.watched);
                return Expanded(
                  child: ListView.builder(
                      shrinkWrap: true,
                      cacheExtent: 20,
                      addAutomaticKeepAlives: true,
                      itemCount: snapshot.data.docs.length,
                      itemBuilder: (context, index) {
                        return ReviewCard(
                          id: snapshot.data.docs[index].id,
                          data: snapshot.data.docs[index].data(),
                          user: userProfile,
                        );
                      }),
                );
              } else {
                print("no data");
                return const Center(child: CircularProgressIndicator());
              }
            },
          ),
                  ],
      ),
    );
  }

  Future<List<DocumentSnapshot>> getDocuments(List<String> ids) async {
    List<Future<DocumentSnapshot>> futures = [];

    // create a future for each document
    for (String id in ids) {
      futures.add(db.doc(id).get());
    }

    // wait for all futures to complete
    List<DocumentSnapshot> documents = await Future.wait(futures);

    return documents;
  }
}