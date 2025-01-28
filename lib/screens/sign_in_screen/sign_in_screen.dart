import 'package:e_connect/cubit/sign_in/sign_in_cubit.dart';
import 'package:e_connect/utils/app_image_assets.dart';
import 'package:e_connect/utils/app_string_constants.dart';
import 'package:e_connect/utils/common/common_function.dart';
import 'package:e_connect/utils/common/common_widgets.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final signInCubit = SignInCubit();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: BlocBuilder(
        bloc: signInCubit,
        builder: (context, state) {
        return Center(
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 10.0),
            height: MediaQuery.of(context).size.height * 0.92,
            padding: EdgeInsets.all(15),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.3),
                  spreadRadius: 2,
                  blurRadius: 8,
                  offset: Offset(0, 1),
                ),
              ],
            ),
            child: Form(
              key: signInCubit.formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Image.asset(AppImage.econnectLogo,height: 50,width: 50,),
                  Container(
                      margin: EdgeInsets.only(top: 10,bottom: 30),
                      alignment: Alignment.center,
                      child: commonText(text: AppString.signIN,fontSize: 28,fontWeight: FontWeight.w600)),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 15.0),
                    child: commonTextFormField(controller: signInCubit.emailController, hintText: AppString.loginId,prefixIcon: Icon(CupertinoIcons.person),
                      isInputFormatForEmail: true,
                      validator: (value) => validateEmail(value, signInCubit.emailController),
                    ),
                  ),
                  commonTextFormField(controller: signInCubit.passwordController, hintText: AppString.password,prefixIcon: Icon(Icons.lock_open),obscureText: signInCubit.isVisible,suffixIcon: InkWell(
                    onTap: () {
                      signInCubit.toggleEyeVisibility();
                    },
                    child: Icon(
                        color: Colors.blue,
                        signInCubit.isVisible
                            ? CupertinoIcons.eye_slash
                            : CupertinoIcons.eye),
                  ),
                    validator: (value) => validatePassword(signInCubit.passwordController,value),),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 15.0),
                    child: commonElevatedButton(onPressed: () => signInCubit.signINCALL(), buttonText: AppString.signIN),
                  ),
                  commonElevatedButton(onPressed: () => Null, buttonText: AppString.signINWithHRMS),
                ],),
            ),
          ),
        );
      },),
    );
  }
}
