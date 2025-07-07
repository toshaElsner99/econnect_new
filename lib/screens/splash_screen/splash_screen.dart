import 'package:e_connect/utils/app_image_assets.dart';
import 'package:e_connect/utils/theme/theme_cubit.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../main.dart';
import '../../providers/splash_screen_provider.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Provider.of<SplashProvider>(navigatorKey.currentState!.context, listen: false).whereToGO();
    Provider.of<SplashProvider>(navigatorKey.currentState!.context, listen: false).getAllowOrNotGoogleSignIn();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(builder: (context, themeProvider, child) {
      return Scaffold(
        backgroundColor: themeProvider.themeData.appBarTheme.backgroundColor,
        body: Center(
          child: Container(
            height: 100,
            width: 100,
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage(AppImage.appLogo,),
                fit: BoxFit.contain, // Use BoxFit.cover to fill the screen
              ),
            ),
          ),
        ),
      );
    },);
  }
}
