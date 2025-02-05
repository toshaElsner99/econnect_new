import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

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
  var commonCubit = CommonCubit();
  var bottomNavigationScreenCubit = BottomNavigationScreenCubit();



  @override
  void initState() {
    super.initState();
    load();
  }

  load() async {
    await commonCubit.getUserByIDCall();
    signInModel = (await SignInModel.loadFromPrefs())!;
  }
  @override
  Widget build(BuildContext context) {
    return BlocBuilder(
      bloc: bottomNavigationScreenCubit,
      builder: (context, state) {
      return Scaffold(
        body: bottomNavigationScreenCubit.screens[bottomNavigationScreenCubit.currentIndex],
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: bottomNavigationScreenCubit.currentIndex,
          onTap: (index) => bottomNavigationScreenCubit.updateCurrentIndex(index),
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
