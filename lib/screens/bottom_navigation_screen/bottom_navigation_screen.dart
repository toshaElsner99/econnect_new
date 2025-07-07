import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../model/sign_in_model.dart';
import '../../main.dart';

import '../../providers/common_provider.dart';
import 'bottom_navigation_screen_cubit.dart';

class BottomNavigationScreen extends StatefulWidget {
  const BottomNavigationScreen({super.key});

  @override
  State<BottomNavigationScreen> createState() => _BottomNavigationScreenState();
}

class _BottomNavigationScreenState extends State<BottomNavigationScreen> {
  final commonProvider = Provider.of<CommonProvider>(navigatorKey.currentState!.context,listen: false);
  final bottomNavigationProvider = Provider.of<CommonProvider>(navigatorKey.currentState!.context,listen: false);



  @override
  void initState() {
    super.initState();
    load();
  }

  load() async {
    try {
      await commonProvider.getUserByIDCall();
      signInModel = (await SignInModel.loadFromPrefs())!;
    } catch (e) {
      print("Error loading user data in bottom navigation: $e");
      // Optionally show user feedback or handle gracefully
    }
  }
  @override
  Widget build(BuildContext context) {
    return Consumer<BottomNavigationProvider>(builder: (context, bottomNavigationProvider, child) {
      return Scaffold(
        body: bottomNavigationProvider.screens[bottomNavigationProvider.currentIndex],
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: bottomNavigationProvider.currentIndex,
          onTap: (index) => bottomNavigationProvider.updateCurrentIndex(index),
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
    },);
  }
}
