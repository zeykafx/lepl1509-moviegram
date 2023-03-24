import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:projet_lepl1509_groupe_17/components/review_card/review_card_pp.dart';
import 'package:projet_lepl1509_groupe_17/models/user_profile.dart';
import 'package:projet_lepl1509_groupe_17/pages/profile/widgets/profile_widget.dart';

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
      body: ListView(
        physics: const BouncingScrollPhysics(),
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

      // bio and watched
      Container(
          padding: const EdgeInsets.symmetric(horizontal: 48),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Bio : ',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              Text(
                '    ${userProfile?.bio ?? "No bio"}',
                style: const TextStyle(fontSize: 16, height: 1.4),
              ),
              const SizedBox(height: 10),

              const Divider(),

              const SizedBox(height: 15),

              // watched section
              const Text(
                'Watched : ',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
          FutureBuilder(
            future: db.collection('reviews').where('reviewID', whereIn: userProfile?.watched.isEmpty ?? true ? [''] : userProfile?.watched).get(),
            builder: (context, AsyncSnapshot snapshot) {
              if (snapshot.hasData) {
                return ListView.builder(
                      physics: const BouncingScrollPhysics(),
                      shrinkWrap: true,
                      cacheExtent: 20,
                      addAutomaticKeepAlives: true,
                      itemCount: snapshot.data.docs.length,
                      itemBuilder: (context, index) {
                        return ReviewCardPP(
                          id: snapshot.data.docs[index].id,
                          data: snapshot.data.docs[index].data(),
                          user: userProfile,
                        );
                      }
                );
              } else {
                return const Center(child: CircularProgressIndicator());
              }
            },
          ),
                  ],
      ),
    );
  }
}