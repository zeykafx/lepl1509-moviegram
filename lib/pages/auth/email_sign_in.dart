import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:projet_lepl1509_groupe_17/pages/home/home_page.dart';

class EmailSignIn extends StatefulWidget {
  const EmailSignIn({super.key});

  @override
  _EmailSignInState createState() => _EmailSignInState();
}

class _EmailSignInState extends State<EmailSignIn> {
  final _formKey = GlobalKey<FormState>();
  final _dialogKey = GlobalKey<FormState>();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  String _email = "", _password = "";

  bool _isLoading = false;
  bool passwordVisible = false;

  @override
  Widget build(BuildContext context) {
    return Form(
        key: _formKey,
        child: Container(
          constraints: const BoxConstraints(maxWidth: 550),
          child: Column(
            children: [
              TextFormField(
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                    prefixIcon: Icon(Icons.email),
                    border: OutlineInputBorder(),
                    labelText: 'Email'),
                validator: (value) => value!.isEmpty ? 'Email can\'t be empty' : null,
                onSaved: (value) => _email = value!.trim(),
              ),
              const Padding(padding: EdgeInsets.all(5.0)),
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
                validator: (value) => value!.isEmpty ? 'Password can\'t be empty' : null,
                onSaved: (value) => _password = value!.trim(),
              ),

              const Padding(padding: EdgeInsets.all(10.0)),

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
            child: const Text(
              'Login',
              style: TextStyle(fontSize: 16),
            ),
          ),
        ),
        const Padding(padding: EdgeInsets.all(2.0)),
        SizedBox(
          width: double.infinity,
          child: TextButton(
            onPressed: forgotPasswordDialog,
            child: const Text(
              'Forgot Password?',
              style: TextStyle(fontSize: 15),
            ),
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
        UserCredential user =
            await _auth.signInWithEmailAndPassword(email: _email, password: _password);
        userId = user.user?.uid;

        // UserCredential user = await _auth.createUserWithEmailAndPassword(
        //     email: _email, password: _password);
        // userId = user.user?.uid;

        setState(() {
          _isLoading = false;
        });
        Get.offAll(() => const HomePage());
      } catch (e) {
        if (e is FirebaseAuthException) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('Error: Invalid email or password'),
          ));
          // if (e.code == 'user-not-found') {
          //   ScaffoldMessenger.of(context).showSnackBar(
          //       const SnackBar(content: Text('No user found for that email.')));
          // } else if (e.code == 'invalid-email') {
          //   ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          //       content: Text('Your email address appears to be malformed.')));
          // } else if (e.code == 'wrong-password') {
          //   ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          //       content: Text('Your password is wrong.')));
          // }
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

  void forgotPasswordDialog() {
    // show a dialog to enter the email
    showDialog(
        context: context,
        builder: (context) {
          String resetEmail = "";
          return StatefulBuilder(builder: (context, setState) {
            return AlertDialog(
              title: const Text('Reset Password'),
              content: Form(
                key: _dialogKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'Enter your email to reset your password',
                    ),
                    const Padding(padding: EdgeInsets.all(8.0)),
                    TextFormField(
                      keyboardType: TextInputType.emailAddress,
                      decoration: const InputDecoration(
                          border: OutlineInputBorder(), labelText: 'Email'),
                      validator: (value) =>
                          value!.isEmpty ? 'Email can\'t be empty' : null,
                      onSaved: (value) {
                        setState(() {
                          resetEmail = value!.trim();
                        });
                      },
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(onPressed: () => Get.back(), child: const Text('Cancel')),
                TextButton(
                  onPressed: () {
                    final form = _dialogKey.currentState;
                    if (form!.validate()) {
                      form.save();
                      print(resetEmail);

                      _auth.sendPasswordResetEmail(email: resetEmail).then((val) {
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                          content: Text('Password reset email sent'),
                        ));
                        Navigator.of(context).pop();
                      }).catchError((e) {
                        if (e is FirebaseAuthException) {
                          if (e.code == 'user-not-found') {
                            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                                content: Text('No user found for that email.')));
                          } else if (e.code == 'invalid-email') {
                            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                                content:
                                    Text('Your email address appears to be malformed.')));
                          }
                        }
                      });
                    }
                  },
                  child: const Text('Reset Password'),
                ),
              ],
            );
          });
        });
  }
}
