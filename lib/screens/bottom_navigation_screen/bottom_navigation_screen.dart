import 'package:e_connect/utils/app_color_constants.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';

import '../../cubit/common_cubit/common_cubit.dart';
import '../../cubit/sign_in/sign_in_model.dart';
import '../../main.dart';

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
    await commonProvider.getUserByIDCall();
    signInModel = (await SignInModel.loadFromPrefs())!;
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
