import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:projet_lepl1509_groupe_17/pages/profile/widgets/profile_widget.dart';
import 'package:projet_lepl1509_groupe_17/pages/profile/widgets/textfield_widget.dart';
import '../utils/about_preferences.dart';

User? currentUser = FirebaseAuth.instance.currentUser;


class EditProfilePage extends StatefulWidget {
  @override
  _EditProfilePageState createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {

  var aboutInfo = AboutPreferences.myAboutInfo;

  @override
  Widget build(BuildContext context) => Builder(
      builder: (context) => Scaffold(
        appBar: AppBar(
          title: const Text('Edit Profile'),
        ),
        body: ListView(
          padding: EdgeInsets.symmetric(horizontal: 32),
          physics: BouncingScrollPhysics(),
          children: [
            ProfileWidget(
              imagePath: currentUser?.photoURL,
              inDrawer: false,
              isEdit: true,
              onClicked: () async {},
            ),
            const SizedBox(height: 24),
            TextFieldWidget(
              label: 'Full Name',
              text: currentUser?.displayName,
              onChanged: (name) {},
            ),
            const SizedBox(height: 24),
            TextFieldWidget(
              label: 'Email',
              text: currentUser?.email,
              onChanged: (email) {},
            ),
            const SizedBox(height: 24),
            TextFieldWidget(
              label: 'About',
              text: aboutInfo.about,
              maxLines: 5,
              onChanged: (about) {},
            ),
          ],
        ),
      ),
    );
}