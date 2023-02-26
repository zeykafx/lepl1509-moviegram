import 'package:flutter/material.dart';
import 'package:projet_lepl1509_groupe_17/components/drawer/drawer.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:projet_lepl1509_groupe_17/pages/profile/utils/about_preferences.dart';
import 'package:projet_lepl1509_groupe_17/pages/profile/widgets/profile_widget.dart';

import '../utils/about.dart';
import 'edit_profile_page.dart';
import '../widgets/numbers_widget.dart';

User? currentUser = FirebaseAuth.instance.currentUser;



class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  @override
  Widget build(BuildContext context) {
    var aboutInfo = AboutPreferences.myAboutInfo;

    return Scaffold(
      drawer: const DrawerComponent(),
      appBar: AppBar(
        title: const Text('Profile'),
      ),
      body: ListView(
        physics: BouncingScrollPhysics(),
        children: [
          ProfileWidget(
            imagePath: currentUser?.photoURL,
            inDrawer: false,
            onClicked: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => EditProfilePage()),
              );
            },
          ),
          const SizedBox(height: 10),
          buildName(currentUser),
          const SizedBox(height: 15),
          NumbersWidget(),
          const SizedBox(height: 15),
          buildAbout(aboutInfo),
          const SizedBox(height: 15),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 48),
            child: const Text(
                  'Watched : ',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
          ),
        ],
      ),
    );
  }

  Widget buildName(User? user) => Column(
    children: [
      Text(
        '${user?.displayName}',
        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
      ),
      const SizedBox(height: 4),
      Text(
        '${user?.email}',
        style: TextStyle(color: Colors.grey),
      )
    ],
  );

  Widget buildAbout(AboutInfo aboutInfo) => Container(
    padding: EdgeInsets.symmetric(horizontal: 48),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Bio : ',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 6),
        Text(
          '    ${aboutInfo.about}',
          style: TextStyle(fontSize: 16, height: 1.4),
        ),
        Divider()
      ],
    ),
  );
}
