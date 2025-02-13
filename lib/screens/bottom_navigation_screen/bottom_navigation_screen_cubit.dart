// import 'package:bloc/bloc.dart';
import 'package:flutter/cupertino.dart';
// import 'package:meta/meta.dart';

import '../bottom_nav_tabs/home_screen.dart';
import '../bottom_nav_tabs/profile_screen.dart';
import '../bottom_nav_tabs/setting_screen.dart';

part 'bottom_navigation_screen_state.dart';

// class BottomNavigationScreenCubit extends Cubit<BottomNavigationScreenState> {
//   BottomNavigationScreenCubit() : super(BottomNavigationScreenInitial());
class BottomNavigationProvider extends ChangeNotifier {
  int currentIndex = 0;
  final List<Widget> screens = [
    HomeScreen(),
    SearchMessage(),
    SettingScreen()
  ];

  updateCurrentIndex(int index){
    currentIndex = index;
    // emit(BottomNavigationScreenInitial());
    notifyListeners();
  }

}
