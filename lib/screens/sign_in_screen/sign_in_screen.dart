import 'package:e_connect/utils/app_image_assets.dart';
import 'package:e_connect/utils/app_preference_constants.dart';
import 'package:e_connect/utils/app_string_constants.dart';
import 'package:e_connect/utils/common/common_function.dart';
import 'package:e_connect/utils/common/common_widgets.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../notificationServices/pushNotificationService.dart';
import '../../providers/sign_in_provider.dart';
import '../../utils/app_color_constants.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> with SingleTickerProviderStateMixin {
  // final signInCubit = SignInCubit();
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    clearBadge();
    _setupAnimations();
  }

  clearBadge() async{
    await NotificationService.clearBadgeCount();
  }

  void _setupAnimations() {
    _controller = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeIn,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    ));

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
      backgroundColor: AppPreferenceConstants.themeModeBoolValueGet ? AppColor.darkAppBarColor : AppColor.appBarColor,
      resizeToAvoidBottomInset: true,
      body: Consumer<SignInProvider>(builder: (context, signInProvider, child) {
        return SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: SlideTransition(
                  position: _slideAnimation,
                  child: Column(
                    children: [
                      const SizedBox(height: 40),
                      _buildHeader(),
                      const SizedBox(height: 40),
                      _buildLoginCard(signInProvider),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white.withOpacity(0.1),
          ),
          child: Image.asset(
            AppImage.econnectLogo,
            height: 60,
            width: 60,
          ),
        ),
        const SizedBox(height: 24),
        commonText(
          text: AppString.welcomeTO,
          fontSize: 16,
          color: Colors.white.withOpacity(0.7),
          letterSpacing: 1.5,
        ),
        const SizedBox(height: 8),
        commonText(
          text: AppString.elsnerEconnectPortal,
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ],
    );
  }

  Widget _buildLoginCard(SignInProvider signInProvider) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Form(
        key: signInProvider.formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            commonText(
              text: AppString.signIN,
              fontSize: 28,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
            const SizedBox(height: 24),
            _buildTextField(
              signInProvider: signInProvider,
              controller: signInProvider.emailController,
              hintText: AppString.loginId,
              prefixIcon: const Icon(CupertinoIcons.person,color: Colors.black,),
              isEmail: true,
            ),
            const SizedBox(height: 16),
            _buildTextField(
              signInProvider: signInProvider,
              controller: signInProvider.passwordController,
              hintText: AppString.password,
              prefixIcon: const Icon(Icons.lock_open,color: Colors.black,),
              isPassword: true,
            ),
            const SizedBox(height: 24),
            _buildSignInButton(signInProvider),
            // const SizedBox(height: 16),
            // _buildHRMSButton(),
            const SizedBox(height: 24),
            _buildFooter(),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required SignInProvider signInProvider,
    required TextEditingController controller,
    required String hintText,
    required Icon prefixIcon,
    bool isEmail = false,
    bool isPassword = false,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
      ),
      child: commonTextFormField(
        controller: controller,
        hintText: hintText,
        prefixIcon: prefixIcon,
        isInputFormatForEmail: isEmail,
        obscureText: isPassword ? signInProvider.isVisible : false,
        textStyle: TextStyle(color: Colors.black,),
        suffixIcon: isPassword
            ? InkWell(
          onTap: () => signInProvider.toggleEyeVisibility(),
          child: Icon(
            signInProvider.isVisible
                ? CupertinoIcons.eye_slash
                : CupertinoIcons.eye,
            color: AppColor.commonAppColor,
          ),
        )
            : null,
        validator: (value) => isEmail
            ? validateEmail(value, controller)
            : validatePassword(controller, value),
      ),
    );
  }

  Widget _buildSignInButton(SignInProvider signInProvider) {
    return commonElevatedButton(onPressed: () => signInProvider.signINCALL(), buttonText: AppString.signIN);
  }


  Widget _buildFooter() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.security,
          size: 16,
          color: Colors.grey[400],
        ),
        const SizedBox(width: 8),
        commonText(
          text: "Secure Login",
          fontSize: 14,
          color: Colors.grey[600],
        ),
      ],
    );
  }
}