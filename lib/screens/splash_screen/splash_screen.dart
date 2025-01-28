import 'package:e_connect/screens/server_connect_screen/server_connect_screen.dart';
import 'package:e_connect/utils/app_image_assets.dart';
import 'package:e_connect/utils/app_string_constants.dart';
import 'package:e_connect/utils/common/common_function.dart';
import 'package:e_connect/utils/common/common_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../cubit/splash_screen/splash_screen_cubit.dart';
import '../../utils/loading_widget/loading_cubit.dart';
import '../sign_in_screen/sign_in_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final splashCubit = SplashScreenCubit();

  @override
  void initState() {
    splashCubit.whereToGO();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        alignment: Alignment.center,
        children: [
          Container(
           margin: EdgeInsets.all(150),
            child: Image.asset(
              AppImage.econnectLogo,
              height: 50,
              width: 50,
            ),
          ),
          Positioned(bottom: 35, child: commonText(text: AppString.eConnect,fontWeight: FontWeight.w600,fontSize: 25))
        ],
      ),
    );
  }
}
