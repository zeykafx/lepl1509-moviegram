import 'package:flutter/material.dart';
import 'package:projet_lepl1509_groupe_17/components/drawer/drawer.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const DrawerComponent(),
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: const Center(
        child: Text("Settings"),
      ),
    );
  }
}
