import 'package:flutter/cupertino.dart';
// import 'package:meta/meta.dart';

import '../bottom_nav_tabs/home_screen.dart';
import '../bottom_nav_tabs/profile_screen.dart';
import '../bottom_nav_tabs/setting_screen.dart';


class BottomNavigationProvider extends ChangeNotifier {
  int currentIndex = 0;
  final List<Widget> screens = [
    HomeScreen(),
    SearchMessage(),
    SettingScreen()
  ];

  updateCurrentIndex(int index){
    currentIndex = index;
    notifyListeners();
  }

}
