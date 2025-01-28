import 'package:e_connect/screens/bottom_nav_tabs/setting_screen.dart';
import 'package:e_connect/screens/profile_screen.dart';
import 'package:flutter/material.dart';

import '../../cubit/sign_in/sign_in_model.dart';
import '../../main.dart';
import '../../utils/api_service/api_string_constants.dart';

class BottomNavigationScreen extends StatefulWidget {
  const BottomNavigationScreen({super.key});

  @override
  State<BottomNavigationScreen> createState() => _BottomNavigationScreenState();
}

class _BottomNavigationScreenState extends State<BottomNavigationScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    Center(child: Text("Home Screen")),
    Center(child: Text("Search Screen")),
    Center(child: Text("Notifications Screen")),
    ProfileScreen(),
    SettingScreen()
  ];

  @override
  void initState() {
    super.initState();
    load();
  }

  load() async {
      signInModel = (await SignInModel.loadFromPrefs())!;
    print("signIn>>>>> ${signInModel.data?.user?.fullName}");
    print("signIn>>>>> ${signInModel.data?.user?.avatarUrl}");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: "Home",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search),
            label: "Search",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.notifications),
            label: "Notifications",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: "Profile",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: "Settings",
          ),
        ],
      ),
    );
  }
}
