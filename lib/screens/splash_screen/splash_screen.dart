// import 'package:e_connect/socket_io/socket_io.dart';
// import 'package:e_connect/utils/app_image_assets.dart';
// import 'package:e_connect/utils/app_preference_constants.dart';
// import 'package:e_connect/utils/app_string_constants.dart';
// import 'package:e_connect/utils/common/common_widgets.dart';
// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import '../../main.dart';
// import '../../providers/common_provider.dart';
// import '../../providers/splash_screen_provider.dart';
// import '../../utils/app_color_constants.dart';
//
// class SplashScreen extends StatefulWidget {
//   const SplashScreen({super.key});
//
//   @override
//   State<SplashScreen> createState() => _SplashScreenState();
// }
//
// class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
//   final splashProvider = Provider.of<SplashProvider>(navigatorKey.currentState!.context,listen: false);
//   final commonProvider = Provider.of<CommonProvider>(navigatorKey.currentState!.context,listen: false);
//   late AnimationController _controller;
//   late Animation<double> _scaleAnimation;
//   late Animation<double> _fadeAnimation;
//   late Animation<Offset> _slideAnimation;
//
//
//   @override
//   void initState() {
//     super.initState();
//     _setupAnimations();
//     _startAnimations();
//     Provider.of<SplashProvider>(navigatorKey.currentState!.context,listen: false).whereToGO();
//   }
//
//   void _setupAnimations() {
//     _controller = AnimationController(
//       duration: const Duration(milliseconds: 1500),
//       vsync: this,
//     );
//
//     _scaleAnimation = TweenSequence<double>([
//       TweenSequenceItem(
//         tween: Tween<double>(begin: 0.0, end: 1.2),
//         weight: 75,
//       ),
//       TweenSequenceItem(
//         tween: Tween<double>(begin: 1.2, end: 1.0),
//         weight: 25,
//       ),
//     ]).animate(CurvedAnimation(
//       parent: _controller,
//       curve: const Interval(0.0, 0.75, curve: Curves.easeOut),
//     ));
//
//     _fadeAnimation = Tween<double>(
//       begin: 0.0,
//       end: 1.0,
//     ).animate(CurvedAnimation(
//       parent: _controller,
//       curve: const Interval(0.5, 1.0, curve: Curves.easeIn),
//     ));
//
//     _slideAnimation = Tween<Offset>(
//       begin: const Offset(0, 0.5),
//       end: Offset.zero,
//     ).animate(CurvedAnimation(
//       parent: _controller,
//       curve: const Interval(0.5, 1.0, curve: Curves.easeOut),
//     ));
//   }
//
//   void _startAnimations() {
//     _controller.forward();
//   }
//
//   @override
//   void dispose() {
//     _controller.dispose();
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       // backgroundColor: AppColor.commonAppColor,
//       body: Stack(
//         fit: StackFit.expand,
//         alignment: Alignment.center,
//         children: [
//           // Background gradient
//           Container(
//             decoration: BoxDecoration(
//               gradient: LinearGradient(
//                 begin: Alignment.topCenter,
//                 end: Alignment.bottomCenter,
//                 colors: AppPreferenceConstants.themeModeBoolValueGet ? [
//                   AppColor.darkAppBarColor,
//                   AppColor.darkAppBarColor.withOpacity(0.8),
//                 ]: [
//                   AppColor.appBarColor,
//                   AppColor.appBarColor.withOpacity(0.8),
//                 ],
//               ),
//             ),
//           ),
//
//           // Logo with scale animation
//           Center(
//             child: ScaleTransition(
//               scale: _scaleAnimation,
//               child: Container(
//                 padding: const EdgeInsets.all(20),
//                 decoration: BoxDecoration(
//                   shape: BoxShape.circle,
//                   boxShadow: [
//                     BoxShadow(
//                       color: AppColor.borderColor.withOpacity(0.1),
//                       blurRadius: 20,
//                       spreadRadius: 5,
//                     ),
//                   ],
//                 ),
//                 child: Image.asset(
//                   AppImage.econnectLogo,
//                   height: 100,
//                   width: 100,
//                 ),
//               ),
//             ),
//           ),
//
//           // App name with slide and fade animation
//           Positioned(
//             bottom: MediaQuery.of(context).size.height * 0.15,
//             child: SlideTransition(
//               position: _slideAnimation,
//               child: FadeTransition(
//                 opacity: _fadeAnimation,
//                 child: Column(
//                   children: [
//                     commonText(
//                       text: AppString.eConnect,
//                       fontWeight: FontWeight.w600,
//                       color: Colors.white,
//                       fontSize: 28,
//                       letterSpacing: 1.2,
//                     ),
//                     const SizedBox(height: 8),
//                     commonText(
//                       text: "Connect & Collaborate",
//                       fontWeight: FontWeight.w400,
//                       fontSize: 16,
//                       color: Colors.white.withOpacity(0.7),
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//           ),
//
//           // Version text
//           Positioned(
//             bottom: 20,
//             child: FadeTransition(
//               opacity: _fadeAnimation,
//               child: commonText(
//                 text: "Version 1.0.0",
//                 fontSize: 12,
//                 color: Colors.white.withOpacity(0.5),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
// /
import 'package:e_connect/providers/common_provider.dart';
import 'package:e_connect/utils/app_color_constants.dart';
import 'package:e_connect/utils/app_image_assets.dart';
import 'package:e_connect/utils/app_preference_constants.dart';
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
    Provider.of<SplashProvider>(navigatorKey.currentState!.context, listen: false).checkForForceUpdate(context);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(builder: (context, themeProvider, child) {
      return Scaffold(
        backgroundColor: themeProvider.themeData.appBarTheme.backgroundColor,
        body: Center(
          child: Container(
            // height: double.infinity,
            // width: double.infinity,
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
