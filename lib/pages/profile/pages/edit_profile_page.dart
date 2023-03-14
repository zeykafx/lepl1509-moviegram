import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_navigation/src/routes/transitions_type.dart';
import 'package:projet_lepl1509_groupe_17/models/user_profile.dart';
import 'package:projet_lepl1509_groupe_17/pages/profile/pages/profile_page.dart';
import 'package:projet_lepl1509_groupe_17/pages/profile/widgets/profile_widget.dart';
import 'package:projet_lepl1509_groupe_17/pages/profile/widgets/textfield_widget.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:path/path.dart';
import 'package:cloud_firestore/cloud_firestore.dart';


import '../utils/about_preferences.dart';

User? currentUser = FirebaseAuth.instance.currentUser;

class EditProfilePage extends StatefulWidget {
  @override
  _EditProfilePageState createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  var aboutInfo = AboutPreferences.myAboutInfo;

  var db = FirebaseFirestore.instance;

  String? _name;
  String? _bio;
  String? _photoURL;
  String? _email;


  UserProfile? userProfile;

  @override
  void initState() {
    super.initState();
    readUserData();
  }

  Future<void> readUserData() async {
    DocumentSnapshot<Map<String, dynamic>> value = await db.collection('users').doc(currentUser?.uid).get();
    setState(() {
      userProfile = UserProfile.fromMap(value.data() as Map<String, dynamic>);
      _name = userProfile?.name;
      _bio = userProfile?.bio;
      _photoURL = userProfile?.photoURL;
      _email = userProfile?.email;
    });
  }

  firebase_storage.FirebaseStorage storage =
      firebase_storage.FirebaseStorage.instance;

  File? _photo;
  final ImagePicker _picker = ImagePicker();

  bool _change = false;



  Future imgFromGallery() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);

    setState(() {
      if (pickedFile != null) {
        _photo = File(pickedFile.path);
        uploadFile();
      } else {
        print('No image selected.');
      }
    });
  }

  Future imgFromCamera() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.camera);

    setState(() {
      if (pickedFile != null) {
        _photo = File(pickedFile.path);
        uploadFile();
      } else {
        print('No image selected.');
      }
    });
  }

  Future uploadFile() async {
    if (_photo == null) return;
    final fileName = basename(_photo!.path);
    final destination = 'ProfilePics/$fileName';

    try {
      final ref = firebase_storage.FirebaseStorage.instance
          .ref(destination)
          .child('image/');
      await ref.putFile(_photo!);
    } catch (e) {
      print('error occured');
    }

    final url = await firebase_storage.FirebaseStorage.instance
        .ref('$destination/image')
        .getDownloadURL();

    setState(() {
      _change = true;
      userProfile?.updatePhotoURL(url);
      _photoURL = url;
    });

  }

  @override
  Widget build(BuildContext context) => Builder(
    builder: (context) => Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profile'),
      ),
      body: userProfile == null ? CircularProgressIndicator() : ListView(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        physics: const BouncingScrollPhysics(),
        children: [
          ProfileWidget(
            imagePath: userProfile?.photoURL,
            inDrawer: false,
            isEdit: true,
            onClicked: () {
              _showPicker(context);
            },
          ),
          const SizedBox(height: 24),
          TextFieldWidget(
            label: 'Full Name',
            text: userProfile?.name,
            onChanged: (name) {
              setState(() {
                currentUser?.updateDisplayName(name);
                userProfile?.updateName(name);
                _name = name;
                _change = true;
              });
            },
          ),
          const SizedBox(height: 24),
          TextFieldWidget(
            label: 'Email',
            text: userProfile?.email,
            onChanged: (email) {
              currentUser?.updateEmail(email);
              setState(() {
                userProfile?.updateEmail(email);
                _email = email;
                _change = true;
              });
            },
          ),
          const SizedBox(height: 24),
          TextFieldWidget(
            label: 'About',
            text: userProfile?.bio,
            maxLines: 5,
            onChanged: (about) {
              setState(() {
                userProfile?.updateBio(about);
                _bio = about;
                _change = true;
              });
            },
          ),
          const SizedBox(height: 24),
          ElevatedButton(
              onPressed: () {
                save();
                //Navigator.pop(context);
                Get.back();
              },
              child: const Text('Save Changes'))
        ],
      ),
    ),
  );

  void _showPicker(context) {
    showModalBottomSheet(
        context: context,
        builder: (BuildContext bc) {
          return SafeArea(
            child: Container(
              child: Wrap(
                children: <Widget>[
                  ListTile(
                      leading: new Icon(Icons.photo_library),
                      title: new Text('Gallery'),
                      onTap: () {
                        imgFromGallery();
                        Navigator.of(context).pop();
                      }),
                  ListTile(
                    leading: new Icon(Icons.photo_camera),
                    title: new Text('Camera'),
                    onTap: () {
                      imgFromCamera();
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              ),
            ),
          );
        });
  }

  void save() async {
    if (_change == true){
      final db = FirebaseFirestore.instance;

      await db.collection('users').doc(currentUser?.uid).update({
        'name': _name,
        'about': _bio,
        'email': _email,
        'photoURL': _photoURL,

      });

    }
  }
}


