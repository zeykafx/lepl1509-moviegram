import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:projet_lepl1509_groupe_17/main.dart';
import 'package:projet_lepl1509_groupe_17/pages/friends/friends_page.dart';
import 'package:projet_lepl1509_groupe_17/pages/home/home_page.dart';
import 'package:projet_lepl1509_groupe_17/pages/settings/settings_page.dart';

class DrawerComponent extends StatefulWidget {
  const DrawerComponent({super.key});

  @override
  State<DrawerComponent> createState() => _DrawerState();
}

class _DrawerState extends State<DrawerComponent> {
  final DrawerPageController drawerPageController = Get.put(DrawerPageController());

  final List<Destination> destinations = [
    const Destination(
      "Home",
      Icon(Icons.home),
      HomePage(),
    ),
    const Destination(
      "Friends",
      Icon(Icons.people),
      FriendsPage(),
    ),
    const Destination(
      "Settings",
      Icon(Icons.settings),
      SettingsPage(),
    ),
  ];

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
              const DrawerHeader(
                child: Column(
                  children: [
                    Padding(
                      padding: EdgeInsets.fromLTRB(0, 0, 0, 5),
                      child: CircleAvatar(
                        radius: 40,
                      ),
                    ),
                    Text(
                      'Hello, John Doe!',
                      style: TextStyle(
                        fontSize: 20,
                      ),
                    ),
                  ],
                ),
              ),

              Padding(
                padding: const EdgeInsets.fromLTRB(28, 16, 16, 10),
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
              child: ListTile(
                  onTap: () => Get.changeTheme(Get.isDarkMode
                      ? lightTheme(lightColorScheme)
                      : darkTheme(darkColorScheme)),
                  leading: Get.isDarkMode
                      ? const Icon(
                          Icons.light_mode,
                          size: 20,
                        )
                      : const Icon(Icons.dark_mode, size: 20),
                  dense: true,
                  title: Get.isDarkMode
                      ? const Text('Enable Light Mode')
                      : const Text('Enable Dark Mode')),
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
