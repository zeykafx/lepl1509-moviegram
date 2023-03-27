import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:projet_lepl1509_groupe_17/models/user_profile.dart';
import 'package:projet_lepl1509_groupe_17/pages/profile/widgets/profile_widget.dart';

import '../utils/about_preferences.dart';

class EditProfilePage extends StatefulWidget {
  @override
  _EditProfilePageState createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  var aboutInfo = AboutPreferences.myAboutInfo;

  var db = FirebaseFirestore.instance;

  User? currentUser = FirebaseAuth.instance.currentUser;

  String? _name;
  String? _bio;
  String? _photoURL;

  UserProfile? userProfile;

  TextEditingController nameController = TextEditingController();
  TextEditingController bioController = TextEditingController();

  @override
  void initState() {
    super.initState();
    readUserData();
  }

  @override
  void dispose() {
    nameController.dispose();
    bioController.dispose();

    super.dispose();
  }

  Future<void> readUserData() async {
    DocumentSnapshot<Map<String, dynamic>> value = await db.collection('users').doc(currentUser?.uid).get();
    setState(() {
      userProfile = UserProfile.fromMap(value.data() as Map<String, dynamic>);
      _name = currentUser?.displayName;
      _bio = userProfile?.bio;
      _photoURL = currentUser?.photoURL;
      nameController = TextEditingController(text: _name);
      bioController = TextEditingController(text: _bio);
    });
  }

  firebase_storage.FirebaseStorage storage = firebase_storage.FirebaseStorage.instance;

  File? _photo;
  final ImagePicker _picker = ImagePicker();

  bool _change = false;
  bool _loading = false;

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
    final destination = 'ProfilePics/${currentUser?.uid}';

    try {
      final ref = firebase_storage.FirebaseStorage.instance.ref(destination).child('image/');
      setState(() {
        _loading = true;
      });
      await ref.putFile(_photo!);
    } catch (e) {
      print('error occurred');
    }

    final url = await firebase_storage.FirebaseStorage.instance.ref('$destination/image').getDownloadURL();

    setState(() {
      _change = true;
      _photoURL = url;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) => Builder(
        builder: (context) => Scaffold(
          appBar: AppBar(
            title: const Text('Edit Profile'),
          ),
          body: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            physics: const BouncingScrollPhysics(),
            children: [
              Stack(
                children: [
                  ProfileWidget(
                    imagePath: _photoURL ?? 'http://www.gravatar.com/avatar/?d=mp',
                    inDrawer: false,
                    access: true,
                    self: true,
                    isEdit: true,
                    onClicked: () {
                      _showPicker(context);
                    },
                  ),
                  if (_loading)
                    const Positioned.fill(
                      child: Align(
                        alignment: Alignment.center,
                        child: CircularProgressIndicator(),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 24),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Full Name",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: nameController,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 1,
                    onChanged: (name) {
                      setState(() {
                        _name = name;
                        _change = true;
                      });
                    },
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "About",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: bioController,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 5,
                    onChanged: (about) {
                      setState(() {
                        _bio = about;
                        _change = true;
                      });
                    },
                  ),
                ],
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
            child: Wrap(
              children: <Widget>[
                ListTile(
                    leading: const Icon(Icons.photo_library),
                    title: const Text('Gallery'),
                    onTap: () {
                      imgFromGallery();
                      Navigator.of(context).pop();
                    }),
                ListTile(
                  leading: const Icon(Icons.photo_camera),
                  title: const Text('Camera'),
                  onTap: () {
                    imgFromCamera();
                    Navigator.of(context).pop();
                  },
                ),
              ],
            ),
          );
        });
  }

  void save() async {
    if (_change == true) {
      final db = FirebaseFirestore.instance;

      currentUser?.updateDisplayName(_name);
      currentUser?.updatePhotoURL(_photoURL);
      await db.collection('users').doc(currentUser?.uid).update({
        'bio': _bio,
        'photoURL': _photoURL,
      });
    }
  }
}
