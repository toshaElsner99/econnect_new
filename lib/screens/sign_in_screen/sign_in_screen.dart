import 'package:e_connect/cubit/sign_in/sign_in_cubit.dart';
import 'package:e_connect/utils/app_image_assets.dart';
import 'package:e_connect/utils/app_string_constants.dart';
import 'package:e_connect/utils/common/common_function.dart';
import 'package:e_connect/utils/common/common_widgets.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../utils/app_color_constants.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> with SingleTickerProviderStateMixin {
  final signInCubit = SignInCubit();
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
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
      backgroundColor: AppColor.commonAppColor,
      resizeToAvoidBottomInset: true,
      body: BlocBuilder(
        bloc: signInCubit,
        builder: (context, state) {
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
                        _buildLoginCard(),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
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

  Widget _buildLoginCard() {
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
        key: signInCubit.formKey,
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
              controller: signInCubit.emailController,
              hintText: AppString.loginId,
              prefixIcon: const Icon(CupertinoIcons.person),
              isEmail: true,
            ),
            const SizedBox(height: 16),
            _buildTextField(
              controller: signInCubit.passwordController,
              hintText: AppString.password,
              prefixIcon: const Icon(Icons.lock_open),
              isPassword: true,
            ),
            const SizedBox(height: 24),
            _buildSignInButton(),
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
        obscureText: isPassword ? signInCubit.isVisible : false,
        suffixIcon: isPassword
            ? InkWell(
          onTap: () => signInCubit.toggleEyeVisibility(),
          child: Icon(
            signInCubit.isVisible
                ? CupertinoIcons.eye_slash
                : CupertinoIcons.eye,
            color: Colors.blue,
          ),
        )
            : null,
        validator: (value) => isEmail
            ? validateEmail(value, controller)
            : validatePassword(controller, value),
      ),
    );
  }

  Widget _buildSignInButton() {
    return ElevatedButton(
      onPressed: () => signInCubit.signINCALL(),
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColor.commonAppColor,
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        elevation: 0,
      ),
      child: commonText(
        text: AppString.signIN,
        color: Colors.white,
        fontSize: 16,
        fontWeight: FontWeight.w600,
      ),
    );
  }

  Widget _buildHRMSButton() {
    return OutlinedButton(
      onPressed: () {},
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 16),
        side: BorderSide(color: AppColor.commonAppColor),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            CupertinoIcons.building_2_fill,
            color: AppColor.commonAppColor,
            size: 20,
          ),
          const SizedBox(width: 8),
          commonText(
            text: AppString.signINWithHRMS,
            color: AppColor.commonAppColor,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ],
      ),
    );
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