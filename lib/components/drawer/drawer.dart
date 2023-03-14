import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:projet_lepl1509_groupe_17/pages/auth/auth_page.dart';
import 'package:projet_lepl1509_groupe_17/pages/friends/friends_page.dart';
import 'package:projet_lepl1509_groupe_17/pages/home/home_page.dart';
import 'package:projet_lepl1509_groupe_17/pages/profile/pages/profile_page.dart';
import 'package:projet_lepl1509_groupe_17/pages/profile/widgets/profile_widget.dart';
import 'package:projet_lepl1509_groupe_17/pages/settings/settings_page.dart';

import '../../models/user_profile.dart';

class DrawerComponent extends StatefulWidget {
  const DrawerComponent({super.key});

  @override
  State<DrawerComponent> createState() => _DrawerState();
}

class _DrawerState extends State<DrawerComponent> {
  final DrawerPageController drawerPageController = Get.put(DrawerPageController());

  var db = FirebaseFirestore.instance;

  UserProfile? userProfile;

  @override
  void initState() {
    super.initState();
    readUserData();
  }

  Future<void> readUserData() async {
    await db.collection('users').doc(currentUser?.uid).get().then((value) {
      setState(() {
        userProfile = UserProfile.fromMap(value.data() as Map<String, dynamic>);
      });
    });
  }

  final List<Destination> destinations = [
    const Destination(
      "Home",
      Icon(Icons.home),
      HomePage(),
    ),
    // const Destination(
    //   "Friends",
    //   Icon(Icons.people),
    //   FriendsPage(),
    // ),
    // const Destination(
    //   "Settings",
    //   Icon(Icons.settings),
    //   SettingsPage(),
    // ),
  ];

  User? currentUser = FirebaseAuth.instance.currentUser;

  String timeOfDayToGreeting() {
    final int hour = DateTime.now().hour;
    if (hour < 12) {
      return 'Good morning';
    } else if (hour < 18) {
      return 'Good afternoon';
    } else {
      return 'Good evening';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Obx(
      // stack used to align the drawer and the dark mode button
      () => Stack(
        children: [
          // drawer
          NavigationDrawer(
            selectedIndex: drawerPageController.currentPage.value,
            onDestinationSelected: (selectedIndex) {
              Get.to(destinations[selectedIndex].page, transition: Transition.fadeIn);
              setState(() {
                drawerPageController.changeCurrentPage(selectedIndex);
              });
            },
            children: <Widget>[
              // user header with profile picture
              DrawerHeader(
                child: InkWell(
                  onTap: () => Get.to(() => const ProfilePage(), transition: Transition.fadeIn),
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(0, 0, 0, 5),
                        child: ProfileWidget(
                          imagePath: userProfile?.photoURL ??
                              'http://www.gravatar.com/avatar/?d=mp',
                          inDrawer: true,
                          onClicked: () {Navigator.of(context).push(MaterialPageRoute(
                            builder:
                                (context) => ProfilePage(),
                          ),
                          ).then((_) {
                            //setState(() {
                            //  readUserData();
                            //});
                            Get.back();
                          });
                          },
                        ),
                      ),
                      const Padding(padding: EdgeInsets.all(5.0)),
                      Text(
                        '${timeOfDayToGreeting()}, ${currentUser?.displayName?.split(" ").first}!',
                        style: const TextStyle(
                          fontSize: 20,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              Padding(
                padding: const EdgeInsets.fromLTRB(28, 9, 16, 10),
                child: Text(
                  'Pages',
                  style: Theme.of(context).textTheme.titleSmall,
                ),
              ),

              ...destinations.map((Destination destination) {
                return NavigationDrawerDestination(
                  label: Text(destination.label),
                  icon: destination.icon,
                );
              }),
            ],
          ),

          // Dark mode button, it is aligned to the bottom left of the drawer
          Align(
            alignment: Alignment.bottomLeft,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Container(
                constraints: const BoxConstraints(maxWidth: 200),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ListTile(
                      onTap: () {
                        Get.changeThemeMode(Get.isDarkMode ? ThemeMode.light : ThemeMode.dark);
                      },
                      leading: Get.isDarkMode
                          ? const Icon(
                              Icons.light_mode,
                              size: 20,
                            )
                          : const Icon(Icons.dark_mode, size: 20),
                      dense: true,
                      title: Get.isDarkMode ? const Text('Enable Light Mode') : const Text('Enable Dark Mode'),
                    ),
                    ListTile(
                      onTap: () {
                        // log out the user
                        showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                                  title: const Text('Log out'),
                                  content: const Text('Are you sure you want to log out?'),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Get.back(),
                                      child: const Text('Cancel'),
                                    ),
                                    TextButton(
                                      onPressed: () {
                                        FirebaseAuth.instance.signOut();
                                        Get.offAll(() => const AuthPage());
                                      },
                                      child: const Text('Log out'),
                                    ),
                                  ],
                                ));
                      },
                      leading: const Icon(
                        Icons.logout,
                        size: 20,
                      ),
                      dense: true,
                      title: const Text('Log out'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class Destination {
  const Destination(this.label, this.icon, this.page);

  final String label;
  final Widget icon;
  final Widget page;
}

class DrawerPageController extends GetxController {
  RxInt currentPage = 0.obs;

  void changeCurrentPage(int newPage) {
    currentPage.value = newPage;
  }
}
