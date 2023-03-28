import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:projet_lepl1509_groupe_17/components/drawer/drawer.dart';
import 'package:projet_lepl1509_groupe_17/pages/home/explore_feed.dart';
import 'package:projet_lepl1509_groupe_17/pages/home/home_feed.dart';
import 'package:projet_lepl1509_groupe_17/pages/search/search_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      initialIndex: 0,
      length: 2,
      child: Scaffold(
        drawer: const DrawerComponent(),
        appBar: AppBar(
          title: const Text('MovieGram'),
          actions: [
            IconButton(
              onPressed: () {
                Get.to(() => const SearchPage());
              },
              icon: const Icon(Icons.search),
            ),
          ],
          bottom: const TabBar(
            tabs: [
              Tab(
                text: "Following",
              ),
              Tab(
                text: "Explore",
              ),
            ],
          ),
        ),
        body: Center(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 700),
            child: const TabBarView(
              children: [
                HomeFeed(),
                ExploreFeed(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
