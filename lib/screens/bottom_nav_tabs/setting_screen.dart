import 'package:e_connect/cubit/sign_in/sign_in_cubit.dart';
import 'package:e_connect/main.dart';
import 'package:e_connect/utils/app_color_constants.dart';
import 'package:e_connect/utils/app_image_assets.dart';
import 'package:e_connect/utils/app_string_constants.dart';
import 'package:e_connect/utils/common/common_widgets.dart';
import 'package:e_connect/utils/theme/theme_cubit.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../utils/app_preference_constants.dart';
import '../../widgets/status_bottom_sheet.dart';

class SettingScreen extends StatefulWidget {
  const SettingScreen({super.key});

  @override
  State<SettingScreen> createState() => _SettingScreenState();
}
final signInCubit = SignInCubit();
// final themeCubit = ThemeCubit();

void _showStatusBottomSheet(BuildContext context) {
  showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    builder: (context) =>  StatusBottomSheet(),
  );
}

class _SettingScreenState extends State<SettingScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocBuilder<ThemeCubit, ThemeState>(
        // bloc: themeCubit,
        builder: (context, state) {
          final themeCubit = context.read<ThemeCubit>();
          return Column(
            children: [
              Container(
                height: MediaQuery.of(context).size.height * 0.3,
                color: AppColor.commonAppColor,
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    commonImageHolder(radius: 50),
                    SizedBox(width: 10),
                    Flexible(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                        commonText(text: "${signInModel.data?.user?.fullName}",color: Colors.white,fontWeight: FontWeight.w600),
                          SizedBox(height: 5),
                        commonText(text: "@${signInModel.data?.user?.username}",color: Colors.white,fontWeight: FontWeight.w600),
                      ],),
                    )
                  ],
                ),

              ),
              Container(
                padding: EdgeInsets.all(20),
                decoration: BoxDecoration(
                  border: Border(bottom: BorderSide(color: AppColor.borderColor))
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                  Row(children: [
                    getCommonStatusIcons(),
                    SizedBox(width: 10,),
                    commonText(text: "Online")
                  ],),
                  SizedBox(height: 15),
                  GestureDetector(
                    onTap: (){
                      _showStatusBottomSheet(context);
                    },
                    child: Row(children: [
                      Image.asset(AppImage.setStatusIcon,scale: 2.5,),
                      SizedBox(width: 10,),
                      commonText(text: AppString.setACustomStatus)
                    ],),
                  )
                ],),
              ),
              Container(
                padding: EdgeInsets.all(20),
                decoration: BoxDecoration(
                    border: Border(bottom: BorderSide(color: AppColor.borderColor))
                ),
                child: Column(
                  children: [
                    Row(children: [
                      Icon(CupertinoIcons.person,color: AppColor.borderColor,),
                      SizedBox(width: 15,),
                      commonText(text: AppString.profile)
                    ],),
                    SizedBox(height: 15),
                    Row(children: [
                      Image.asset(AppPreferenceConstants.themeModeBoolValueGet ? AppImage.darkModeIcon : AppImage.lightModeIcon,height: 25,width: 25,color: AppPreferenceConstants.themeModeBoolValueGet ? Colors.white : AppColor.borderColor,),
                      SizedBox(width: 15,),
                      commonText(text: AppString.themMode),
                      Spacer(),
                      SizedBox(
                        height: 0,
                        child: Switch(
                          activeColor: AppColor.commonAppColor,
                            value: AppPreferenceConstants.themeModeBoolValueGet,
                            onChanged: (value) => themeCubit.toggleTheme(),
                          ),
                      ),
                    ],),
                  ],
                ),
              ),
              GestureDetector(
                onTap: () => commonLogoutDialog(context),
                child: Container(
                  padding: EdgeInsets.all(20),
                  decoration: BoxDecoration(
                      border: Border(bottom: BorderSide(color: AppColor.borderColor))
                  ),
                  child: Row(children: [
                    Image.asset(AppImage.logOut,height: 20,width: 20,color: AppColor.borderColor,),
                    SizedBox(width: 15,),
                    commonText(text: AppString.logOut)
                  ],),
                ),
              )

              // Text(
              //   AppPreferenceConstants.themeModeBoolValueGet ? "Dark Mode Theme" : "Light Mode Theme",
              //   style: Theme.of(context).textTheme.bodyLarge,
              // ),
              // ListTile(
              //   title: const Text('Dark Mode'),
              //   trailing: Switch(
              //     value: AppPreferenceConstants.themeModeBoolValueGet,
              //     onChanged: (value) => themeCubit.toggleTheme(),
              //   ),
              // ),
              // commonElevatedButton(onPressed: () => signInCubit.logOut(), buttonText: "Logout")
            ],
          );
        },
      ),
    );
  }
}
