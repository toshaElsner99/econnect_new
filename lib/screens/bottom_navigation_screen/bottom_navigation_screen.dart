import 'package:e_connect/screens/bottom_nav_tabs/home_screen.dart';
import 'package:e_connect/screens/bottom_nav_tabs/profile_screen.dart';
import 'package:e_connect/screens/bottom_nav_tabs/setting_screen.dart';
import 'package:e_connect/utils/api_service/api_string_constants.dart';
import 'package:flutter/material.dart';

import '../../cubit/sign_in/sign_in_model.dart';
import '../../main.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

class BottomNavigationScreen extends StatefulWidget {
  const BottomNavigationScreen({super.key});

  @override
  State<BottomNavigationScreen> createState() => _BottomNavigationScreenState();
}

class _BottomNavigationScreenState extends State<BottomNavigationScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    HomeScreen(),
    SearchMessage(),
    SettingScreen()
  ];

  @override
  void initState() {
    super.initState();
    load();
  }

  load() async {
    await commonCubit.getUserByIDCall();
    signInModel = (await SignInModel.loadFromPrefs())!;
    print("signIn>>>>> ${signInModel.data?.user?.fullName}");
    print("signIn>>>>> ${signInModel.data?.user?.avatarUrl}");
  }
  connect() {
    ApiString.socket = IO.io(ApiString.baseUrl, <String, dynamic>{
      "transports": ["websocket"],
      "autoConnect": false,
    });

    ApiString.socket?.connect();
    ApiString.socket?.onConnect((data) {
      print('Socket-ID:------->${ApiString.socket?.id}');
      print('connectivity :---->${ApiString.socket?.connected}');
    });
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
            icon: Icon(Icons.settings),
            label: "Settings",
          ),
        ],
      ),
    );
  }
}
