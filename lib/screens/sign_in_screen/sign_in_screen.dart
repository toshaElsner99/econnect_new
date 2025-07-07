import 'package:e_connect/providers/splash_screen_provider.dart';
import 'package:e_connect/utils/app_image_assets.dart';
import 'package:e_connect/utils/app_preference_constants.dart';
import 'package:e_connect/utils/app_string_constants.dart';
import 'package:e_connect/utils/common/common_function.dart';
import 'package:e_connect/utils/common/common_widgets.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/sign_in_provider.dart';
import '../../utils/app_color_constants.dart';
import '../../providers/forgot_password_provider.dart';

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
  final FocusNode emailNode = FocusNode();
  final FocusNode passNode = FocusNode();
  @override
  void initState() {
    super.initState();
    clearBadge();
    _setupAnimations();
    Provider.of<SignInProvider>(context, listen: false).clearField();
    /// Domain api call ///
    // WidgetsBinding.instance.addPostFrameCallback((_) {
    //   Provider.of<SignInProvider>(context, listen: false).getDomainsCall();
    // });
  }

  clearBadge() async{
    // await NotificationService.clearBadgeCount();
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
      body: Consumer2<SignInProvider,SplashProvider>(builder: (context, signInProvider,splashProvider, child) {
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
                      _buildLoginCard(signInProvider,splashProvider),
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
            AppImage.appLogo,
            height: 60,
            width: 60,
          ),
        ),
        const SizedBox(height: 24),
        Cw.commonText(
          text: AppString.welcomeTO,
          fontSize: 16,
          color: Colors.white.withOpacity(0.7),
          letterSpacing: 1.5,
        ),
        const SizedBox(height: 8),
        Cw.commonText(
          text: AppString.elsnerEconnectPortal,
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ],
    );
  }

  Widget _buildLoginCard(SignInProvider signInProvider,SplashProvider splashProvider) {
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
            Cw.commonText(
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
              fNode: emailNode,
              isEmail: true,
            ),
            const SizedBox(height: 16),
            _buildTextField(
              fNode: passNode,
              signInProvider: signInProvider,
              controller: signInProvider.passwordController,
              hintText: AppString.password,
              prefixIcon: const Icon(Icons.lock_open,color: Colors.black,),
              isPassword: true,
            ),
            // Forgot Password Link
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () => _showForgotPasswordDialog(context),
                child: Text(
                  'Forgot Your Password?',
                  style: TextStyle(
                    color: Colors.blue[800],
                    decoration: TextDecoration.underline,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            _buildSignInButton(signInProvider),
            const SizedBox(height: 20),
            splashProvider.isNeedToShowGoogleSignIn ? _buildDividerWithText() : SizedBox(),
            const SizedBox(height: 20),
            splashProvider.isNeedToShowGoogleSignIn?_buildGoogleSignInGif(signInProvider, context):SizedBox(),
            const SizedBox(height: 20),
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
    required FocusNode fNode,
    bool isEmail = false,
    bool isPassword = false,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Cw.commonTextFormField(
        focusNode: fNode,
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
            ? Cf.instance.validateEmail(value, controller)
            : Cf.instance.validatePassword(controller, value),
      ),
    );
  }

  Widget _buildSignInButton(SignInProvider signInProvider) {
    return Cw.commonElevatedButton(onPressed: () =>  signInProvider.signINCALL(), buttonText: AppString.signIN);
  }

  Widget _buildDividerWithText() {
    return Row(
      children: [
        Expanded(
          child: Divider(
            color: Colors.grey[400],
            thickness: 1,
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Cw.commonText(
            text: "OR Continue With",
            fontSize: 14,
            color: Colors.grey[600],
          ),
        ),
        Expanded(
          child: Divider(
            color: Colors.grey[400],
            thickness: 1,
          ),
        ),
      ],
    );
  }

  Widget _buildGoogleSignInGif(SignInProvider signInProvider, BuildContext context) {
    return GestureDetector(
      onTap: () {
        if(signInProvider.domainList.isNotEmpty) {
          signInProvider.signInWithGoogle(context);
        } else {
          Cw.commonShowToast("Domain not found", Colors.white);
        }
      },
      child: Image.asset(
        AppImage.googleSignIn,
        height: 50,
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
        Cw.commonText(
          text: "Secure Login",
          fontSize: 14,
          color: Colors.grey[600],
        ),
      ],
    );
  }

  void _showForgotPasswordDialog(BuildContext context) {
    final emailController = TextEditingController();
    final formKey = GlobalKey<FormState>();
    final theme = Theme.of(context);
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: AppColor.whiteColor,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text(
            'Forgot Password',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: AppColor.commonAppColor,
            ),
          ),
          content: Consumer<ForgotPasswordProvider>(
            builder: (context, forgotPasswordProvider, child) {
              return Form(
                key: formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Enter your email to receive a password reset link.',
                      style: TextStyle(color: AppColor.commonAppColor),
                    ),
                    const SizedBox(height: 16),
                    Cw.commonTextFormField(
                      controller: emailController,
                      hintText: 'Email',
                      prefixIcon: Icon(Icons.email, color: AppColor.commonAppColor),
                      validator: (value) => Cf.instance.validateEmail(value, emailController),
                    ),
                  ],
                ),
              );
            },
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Cancel',
                style: TextStyle(color: AppColor.commonAppColor),
              ),
            ),
            Consumer<ForgotPasswordProvider>(
              builder: (context, forgotPasswordProvider, child) {
                return ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColor.commonAppColor,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onPressed: () {
                    if (formKey.currentState!.validate()) {
                      forgotPasswordProvider.forgotPasswordCall(
                        email: emailController.text.trim(),
                      );
                      Navigator.of(context).pop();
                    }
                  },
                  child: Text('Send Reset Link'),
                );
              },
            ),
          ],
        );
      },
    );
  }
}