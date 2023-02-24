import 'package:flutter/material.dart';
import 'package:projet_lepl1509_groupe_17/components/drawer/drawer.dart';

class FriendsPage extends StatefulWidget {
  const FriendsPage({super.key});

  @override
  _FriendsPageState createState() => _FriendsPageState();
}

class _FriendsPageState extends State<FriendsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const DrawerComponent(),
      appBar: AppBar(
        title: const Text('Friends'),
      ),
      body: const Center(
        child: Text("Friends"),
      ),
    );
  }
}
