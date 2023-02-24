import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:projet_lepl1509_groupe_17/pages/auth/sign_up_page.dart';

import 'email_sign_in.dart';

class AuthPage extends StatefulWidget {
  const AuthPage({super.key});

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('MovieGram - Log in'),
        ),
        // we're using a layout builder to get the height of the screen
        body: LayoutBuilder(builder: (context, constraint) {
          // SingleChildScrollView is used to make the page scrollable (and not overflow when the keyboard is open)
          return SingleChildScrollView(
            // ConstrainedBox is used to make sure the column doesn't overflow the screen
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraint.maxHeight),
              // IntrinsicHeight makes sure the column takes up the full height of the screen
              child: IntrinsicHeight(
                child: Column(
                  mainAxisSize: MainAxisSize.max,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Spacer(),
                    const Text(
                      'Welcome to MovieGram!',
                      style: TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const Text("Sign in to continue", style: TextStyle(fontSize: 20)),
                    // sign in with email and password
                    const Padding(
                      padding: EdgeInsets.all(20.0),
                      child: EmailSignIn(),
                    ),

                    // stick the sign up button at the bottom of the page
                    const Spacer(),
                    // button to sign up page
                    Align(
                      alignment: Alignment.bottomCenter,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text("Don't have an account?"),
                          TextButton(
                            onPressed: () => Get.to(const SignUpPage()),
                            child: const Text('Sign Up'),
                          ),
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
