import 'package:flutter/material.dart';
import 'package:projet_lepl1509_groupe_17/components/drawer/drawer.dart';

class AuthPage extends StatefulWidget {
  const AuthPage({super.key});

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const DrawerComponent(),
      appBar: AppBar(
        title: const Text('MovieGram'),
      ),
      body: const Center(
        child: Text('Login/Register'),
      ),
    );
  }
}
