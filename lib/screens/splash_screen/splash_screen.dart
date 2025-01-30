import 'package:e_connect/screens/server_connect_screen/server_connect_screen.dart';
import 'package:e_connect/utils/app_image_assets.dart';
import 'package:e_connect/utils/app_string_constants.dart';
import 'package:e_connect/utils/common/common_function.dart';
import 'package:e_connect/utils/common/common_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../cubit/splash_screen/splash_screen_cubit.dart';
import '../../utils/app_color_constants.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  final splashCubit = SplashScreenCubit();
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _startAnimations();
    splashCubit.whereToGO();
  }

  void _setupAnimations() {
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _scaleAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 0.0, end: 1.2),
        weight: 75,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.2, end: 1.0),
        weight: 25,
      ),
    ]).animate(CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.75, curve: Curves.easeOut),
    ));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.5, 1.0, curve: Curves.easeIn),
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.5),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.5, 1.0, curve: Curves.easeOut),
    ));
  }

  void _startAnimations() {
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.commonAppColor,
      body: Stack(
        fit: StackFit.expand,
        alignment: Alignment.center,
        children: [
          // Background gradient
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  AppColor.commonAppColor,
                  AppColor.commonAppColor.withOpacity(0.8),
                ],
              ),
            ),
          ),

          // Logo with scale animation
          Center(
            child: ScaleTransition(
              scale: _scaleAnimation,
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppColor.borderColor.withOpacity(0.1),
                      blurRadius: 20,
                      spreadRadius: 5,
                    ),
                  ],
                ),
                child: Image.asset(
                  AppImage.econnectLogo,
                  height: 100,
                  width: 100,
                ),
              ),
            ),
          ),

          // App name with slide and fade animation
          Positioned(
            bottom: MediaQuery.of(context).size.height * 0.15,
            child: SlideTransition(
              position: _slideAnimation,
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: Column(
                  children: [
                    commonText(
                      text: AppString.eConnect,
                      fontWeight: FontWeight.w600,
                      fontSize: 28,
                      letterSpacing: 1.2,
                    ),
                    const SizedBox(height: 8),
                    commonText(
                      text: "Connect & Collaborate",
                      fontWeight: FontWeight.w400,
                      fontSize: 16,
                      color: Colors.white.withOpacity(0.7),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Version text
          Positioned(
            bottom: 20,
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: commonText(
                text: "Version 1.0.0",
                fontSize: 12,
                color: Colors.white.withOpacity(0.5),
              ),
            ),
          ),
        ],
      ),
    );
  }
}