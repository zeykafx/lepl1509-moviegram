import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
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

                    Column(
                      mainAxisSize: MainAxisSize.max,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Spacer(),
                        const Column(children: [
                          Text(
                            'Welcome to MovieGram!',
                            style: TextStyle(
                              fontSize: 30,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text("Sign in to continue", style: TextStyle(fontSize: 20)),
                        ]).animate().fadeIn(duration: 1000.ms).moveY(begin: -10),

                        // sign in with email and password
                        const Padding(
                          padding: EdgeInsets.all(20.0),
                          child: EmailSignIn(),
                        ).animate().fadeIn(delay: 300.ms, duration: 500.ms).moveY(begin: 5),

                        // stick the sign up button at the bottom of the page
                        const Spacer(),
                        // button to sign up page
                        Align(
                          alignment: Alignment.bottomCenter,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text(
                                "Don't have an account?",
                                style: TextStyle(fontSize: 20),
                              ),
                              TextButton(
                                onPressed: () => Get.to(() => const SignUpPage()),
                                child: const Text(
                                  'Sign Up',
                                  style: TextStyle(fontSize: 20),
                                ),
                              ),
                            ],
                          ),
                        ).animate().fadeIn(duration: 1000.ms),
                      ],
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

class FancyClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    // final path = Path();
    // path.lineTo(0, size.height - 80);
    // path.quadraticBezierTo(size.width / 2, size.height, size.width, size.height - 80);
    // path.lineTo(size.width, 0);
    // path.close();
    // return path;
    var path = Path();
    path.lineTo(0, 160);
    path.quadraticBezierTo(size.width / 4, 120 /*180*/, size.width / 2, 135);
    path.quadraticBezierTo(3 / 4 * size.width, 150, size.width, 100);
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => true;
}
