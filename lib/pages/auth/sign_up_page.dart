import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:crypto/crypto.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';

import '../home/home_page.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  _SignUpPageState createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Back'),
        ),
        body: LayoutBuilder(builder: (context, constraint) {
          return SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraint.maxHeight),
              child: IntrinsicHeight(
                child: Stack(
                  children: [
                    // background shape
                    Positioned(
                      bottom: -20,
                      left: 0,
                      right: 0,
                      child: Transform.flip(
                        flipX: true,
                        flipY: true,
                        child: ClipPath(
                          clipper: FancyClipper(),
                          child: Container(
                            height: 300,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  Theme.of(context).colorScheme.tertiaryContainer,
                                  Theme.of(context).colorScheme.primaryContainer,
                                ],
                                begin: const Alignment(-0.7, 12),
                                end: const Alignment(1, -2),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ).animate().fadeIn(duration: 500.ms, delay: 300.ms).moveY(begin: 10),

                    // content
                    Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.max,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Column(
                            children: [
                              Text(
                                'Sign up to MovieGram',
                                style: TextStyle(
                                  fontSize: 30,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              Text("Create your account to get started!", style: TextStyle(fontSize: 20)),
                            ],
                          ).animate().fadeIn(duration: 500.ms).moveY(begin: -5),
                          const Padding(
                            padding: EdgeInsets.all(20.0),
                            child: EmailSignUp(),
                          ).animate().fadeIn(delay: 200.ms, duration: 500.ms).moveY(begin: 2)
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}

class EmailSignUp extends StatefulWidget {
  const EmailSignUp({Key? key}) : super(key: key);

  @override
  State<EmailSignUp> createState() => _EmailSignUpState();
}

class _EmailSignUpState extends State<EmailSignUp> {
  final _formKey = GlobalKey<FormState>();
  final _dialogKey = GlobalKey<FormState>();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  FirebaseFirestore db = FirebaseFirestore.instance;

  String _email = "";
  String _password = "";
  String _name = "";
  int _dob = 0; // date of birth

  bool _isLoading = false;
  bool passwordVisible = false;

  TextEditingController dateCtl = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Form(
        key: _formKey,
        child: Container(
          constraints: const BoxConstraints(maxWidth: 550),
          child: Column(
            children: [
              // name
              TextFormField(
                keyboardType: TextInputType.name,
                decoration: const InputDecoration(
                    prefixIcon: Icon(Icons.person), border: OutlineInputBorder(), labelText: 'Name'),
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Please enter your name';
                  } else if (value.split(" ").length < 2) {
                    return 'Please enter your full name';
                  }
                  return null;
                },
                onSaved: (value) => _name = value!.trim(),
              ),
              const Padding(padding: EdgeInsets.all(8.0)),

              // date of birth
              // TextFormField(
              //   controller: dateCtl,
              //   keyboardType: TextInputType.none,
              //   onTap: () {
              //     showDatePicker(
              //       context: context,
              //       initialDate: DateTime.now(),
              //       firstDate: DateTime(1900),
              //       lastDate: DateTime.now(),
              //     ).then((value) {
              //       if (value != null) {
              //         setState(() {
              //           _dob = value.millisecondsSinceEpoch;
              //           // extract the date part only
              //           dateCtl.text = value.toIso8601String().substring(0, 10);
              //         });
              //       }
              //     });
              //   },
              //   decoration: const InputDecoration(
              //       prefixIcon: Icon(Icons.calendar_month),
              //       border: OutlineInputBorder(),
              //       labelText: 'Date of Birth'),
              //   validator: (value) =>
              //       value!.isEmpty ? 'Please enter your date of birth' : null,
              //   onSaved: (value) => _dob = int.parse(value!),
              // ),
              // const Padding(padding: EdgeInsets.all(8.0)),

              // email
              TextFormField(
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                    prefixIcon: Icon(Icons.email), border: OutlineInputBorder(), labelText: 'Email'),
                validator: (value) => value!.isEmpty ? 'Email can\'t be empty' : null,
                onSaved: (value) => _email = value!.trim(),
              ),

              const Padding(padding: EdgeInsets.all(8.0)),
              // password
              TextFormField(
                obscureText: !passwordVisible,
                decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.password),
                    border: const OutlineInputBorder(),
                    labelText: 'Password',
                    suffixIcon: IconButton(
                      icon: passwordVisible
                          ? const Icon(Icons.visibility_off_rounded)
                          : const Icon(Icons.visibility_rounded),
                      onPressed: () {
                        setState(() {
                          passwordVisible = !passwordVisible;
                        });
                      },
                    )),
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Password can\'t be empty';
                  } else if (value.length < 8) {
                    return 'Password must be at least 8 characters long';
                  } else if (!value.contains(RegExp(r'[A-Z]'))) {
                    return 'Password must contain at least one upper case letter';
                  } else if (!value.contains(RegExp(r'[a-z]'))) {
                    return 'Password must contain at least one lower case letter';
                  } else if (!value.contains(RegExp(r'[0-9]'))) {
                    return 'Password must contain at least one number';
                  } else if (!value.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) {
                    return 'Password must contain at least one special character';
                  }
                  return null;
                },
                onSaved: (value) => _password = value!.trim(),
              ),

              const Text(
                  "Password must be at least 8 characters long & contain a mix of upper & lower case letters, numbers and symbols",
                  style: TextStyle(fontSize: 13, color: Colors.grey)),

              const Padding(padding: EdgeInsets.all(15.0)),

              // spread the list returned by buildSubmitButtons()
              ...buildSubmitButtons(),
            ],
          ),
        ));
  }

  List<Widget> buildSubmitButtons() {
    if (_isLoading) {
      return [
        const Center(
          child: CircularProgressIndicator(),
        )
      ];
    } else {
      return [
        SizedBox(
          width: double.infinity,
          child: FilledButton.tonal(
            onPressed: validateAndSubmit,
            child: const Text('Create an account'),
          ),
        ),
      ];
    }
  }

  void validateAndSubmit() async {
    final form = _formKey.currentState;
    if (form!.validate()) {
      form.save();
      setState(() {
        _isLoading = true;
      });
      String? userId = '';
      try {
        UserCredential user = await _auth.createUserWithEmailAndPassword(email: _email, password: _password);
        userId = user.user?.uid;

        // update the user's display name and photo URL
        await user.user!.updateDisplayName(_name);

        String emailHash = md5.convert(utf8.encode(_email)).toString();
        String photoURL = "http://www.gravatar.com/avatar/$emailHash?d=identicon";
        await user.user!.updatePhotoURL(photoURL);

        await db.collection("users").doc(userId).set({
          "email": _email,
          "uid": userId,
          "photoURL": photoURL,
          "name": _name,
          "createdAt": DateTime.now().millisecondsSinceEpoch,
          "updatedAt": DateTime.now().millisecondsSinceEpoch,
          "bio": "Hello I'm new here!",
          "followers": 0,
          "following": 0,
          "ranking": 0,
        });

        setState(() {
          _isLoading = false;
        });
        Get.offAll(() => const HomePage());
      } catch (e) {
        print(e.toString());
        if (e is FirebaseAuthException) {
          if (e.code == 'invalid-email') {
            ScaffoldMessenger.of(context)
                .showSnackBar(const SnackBar(content: Text('Your email address appears to be malformed.')));
          } else if (e.code == "email-already-in-use") {
            ScaffoldMessenger.of(context)
                .showSnackBar(const SnackBar(content: Text('The email address is already in use by another account.')));
          } else if (e.code == "weak-password") {
            ScaffoldMessenger.of(context)
                .showSnackBar(const SnackBar(content: Text('The password must be 6 characters long or more.')));
          } else {
            ScaffoldMessenger.of(context)
                .showSnackBar(const SnackBar(content: Text('Error: Invalid email or password')));
          }
        } else {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('Error: Invalid email or password'),
          ));
        }

        setState(() {
          _isLoading = false;
        });
      }
    }
  }
}

class FancyClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    var path = Path();
    path.lineTo(0, 120);
    path.quadraticBezierTo(size.width / 5, 130, size.width, 10);
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => true;
}
